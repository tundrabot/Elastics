//
//	ValidateReceipt.m
//	Elastic
//
//	Created by Dmitri Goutnik on 10/01/2011.
//	Copyright 2011 Tundra Bot. All rights reserved.
//

#import "ValidateReceipt.h"
#import "Constants.h"

// link with Foundation.framework, IOKit.framework, Security.framework and libCrypto.dylib

#import <IOKit/IOKitLib.h>
#import <Foundation/Foundation.h>

#import <Security/Security.h>

#include <openssl/pkcs7.h>
#include <openssl/objects.h>
#include <openssl/sha.h>
#include <openssl/x509.h>
#include <openssl/err.h>

#ifdef TB_USE_SAMPLE_RECEIPT
#warning *************(***********************
#warning ******* USING SAMPLE RECEIPT! *******
#warning **************(**********************
#endif

NSString *const kReceiptBundleIdentifer		= @"BundleIdentifier";
NSString *const kReceiptBundleIdentiferData = @"BundleIdentifierData";
NSString *const kReceiptVersion				= @"Version";
NSString *const kReceiptOpaqueValue			= @"OpaqueValue";
NSString *const kReceiptHash				= @"Hash";

NSData* appleRootCert(void);
NSDictionary* dictionaryWithAppStoreReceipt(NSString *path);
CFDataRef copyMACAddress(void);

NSData* appleRootCert(void)
{
	OSStatus status;
	
	SecKeychainRef keychain = nil;
	status = SecKeychainOpen("/System/Library/Keychains/SystemRootCertificates.keychain", &keychain);
	if (status != noErr)
	{
		if (keychain)
			CFRelease(keychain);
		return nil;
	}
	
	CFArrayRef searchList = CFArrayCreate(kCFAllocatorDefault, (const void **)&keychain, 1, &kCFTypeArrayCallBacks);
	
//	// For some reason we get a malloc reference underflow warning message when garbage collection
//	// is on. Perhaps a bug in SecKeychainOpen where the keychain reference isn't actually retained
//	// in GC?
//#ifndef __OBJC_GC__
	if (keychain)
		CFRelease(keychain);
//#endif
	
	SecKeychainSearchRef searchRef = nil;
	status = SecKeychainSearchCreateFromAttributes(searchList, kSecCertificateItemClass, NULL, &searchRef);
	if (status != noErr)
	{
		if (searchRef)
			CFRelease(searchRef);
		if (searchList)
			CFRelease(searchList);
		return nil;
	}
	
	SecKeychainItemRef itemRef = nil;
	NSData* resultData = nil;
	
	while (SecKeychainSearchCopyNext(searchRef, &itemRef) == noErr && resultData == nil)
	{
		// Grab the name of the certificate
		SecKeychainAttributeList list;
		SecKeychainAttribute attributes[1];
		
		attributes[0].tag = kSecLabelItemAttr;
		
		list.count = 1;
		list.attr = attributes;
		
		SecKeychainItemCopyContent(itemRef, nil, &list, nil, nil);
//		NSData *nameData = [NSData dataWithBytesNoCopy:attributes[0].data length:attributes[0].length freeWhenDone:NO];
//		NSString *name = [[NSString alloc] initWithData:nameData encoding:NSUTF8StringEncoding];
		NSString *name = [[NSString alloc] initWithBytes:attributes[0].data
												  length:attributes[0].length
												encoding:NSUTF8StringEncoding];
		
		if ([name isEqualToString:@"Apple Root CA"])
		{
			CSSM_DATA certData;
			status = SecCertificateGetData((SecCertificateRef)itemRef, &certData);
			if (status != noErr)
			{
				if (itemRef)
					CFRelease(itemRef);
				[name release];
				return nil;
			}
			
			resultData = [NSData dataWithBytes:certData.Data length:certData.Length];
			
			SecKeychainItemFreeContent(&list, NULL);
			if (itemRef)
				CFRelease(itemRef);
			[name release];
			break;
		}
		
		[name release];
	}

	if (searchList)
		CFRelease(searchList);
	if (searchRef)
		CFRelease(searchRef);
	
	return resultData;
}

NSDictionary* dictionaryWithAppStoreReceipt(NSString *path)
{
	NSData* rootCertData = appleRootCert();
	
	enum ATTRIBUTES
	{
		ATTR_START = 1,
		BUNDLE_ID,
		VERSION,
		OPAQUE_VALUE,
		HASH,
		ATTR_END
	};
	
	ERR_load_PKCS7_strings();
	ERR_load_X509_strings();
	OpenSSL_add_all_digests();
	
	// Expected input is a PKCS7 container with signed data containing
	// an ASN.1 SET of SEQUENCE structures. Each SEQUENCE contains
	// two INTEGERS and an OCTET STRING.
	
	const char *receiptPath = [[path stringByStandardizingPath] fileSystemRepresentation];
	FILE *fp = fopen(receiptPath, "rb");
	if (!fp)
		return nil;
	
	PKCS7 *p7 = d2i_PKCS7_fp(fp, NULL);
	fclose(fp);
	
	// Check if the receipt file was invalid (otherwise we go crashing and burning)
	if (!p7)
		return nil;
	
	if (!PKCS7_type_is_signed(p7))
	{
		PKCS7_free(p7);
		return nil;
	}
	
	if (!PKCS7_type_is_data(p7->d.sign->contents))
	{
		PKCS7_free(p7);
		return nil;
	}
	
	int verifyReturnValue = 0;
	X509_STORE *store = X509_STORE_new();
	
	if (store)
	{
		unsigned char const *data = (unsigned char *)(rootCertData.bytes);
		X509 *appleCA = d2i_X509(NULL, &data, (long)rootCertData.length);
		
		if (appleCA)
		{
			BIO *payload = BIO_new(BIO_s_mem());
			X509_STORE_add_cert(store, appleCA);
			
			if (payload)
			{
				verifyReturnValue = PKCS7_verify(p7,NULL,store,NULL,payload,0);
				BIO_free(payload);
			}
			
			// this code will come handy when the first real receipts arrive
#if 0
			unsigned long err = ERR_get_error();
			if (err)
				printf("%lu: %s\n", err, ERR_error_string(err,NULL));
			else
			{
				STACK_OF(X509) *stack = PKCS7_get0_signers(p7, NULL, 0);
				for(NSUInteger i = 0; i < sk_num(stack); i++) {
					const X509 *signer = (X509*)sk_value(stack, i);
					NSLog(@"name = %s", signer->name);
				}
			}
#endif
			
			X509_free(appleCA);
		}
		X509_STORE_free(store);
	}
	EVP_cleanup();
	
	if (verifyReturnValue != 1)
	{
		PKCS7_free(p7);
		return nil; 
	}
	
	ASN1_OCTET_STRING *octets = p7->d.sign->contents->d.data;	
	unsigned char const *p = octets->data;
	const unsigned char *end = p + octets->length;
	
	int type = 0;
	int xclass = 0;
	long length = 0;
	
	ASN1_get_object(&p, &length, &type, &xclass, end - p);
	if (type != V_ASN1_SET)
	{
		PKCS7_free(p7);
		return nil;
	}
	
	NSMutableDictionary *info = [NSMutableDictionary dictionary];
	
	while (p < end)
	{
		ASN1_get_object(&p, &length, &type, &xclass, end - p);
		if (type != V_ASN1_SEQUENCE)
			break;
		
		const unsigned char *seq_end = p + length;
		
		int attr_type = 0;
		int attr_version = 0;
		
		// Attribute type
		ASN1_get_object(&p, &length, &type, &xclass, seq_end - p);
		if (type == V_ASN1_INTEGER && length == 1)
		{
			attr_type = p[0];
		}
		p += length;
		
		// Attribute version
		ASN1_get_object(&p, &length, &type, &xclass, seq_end - p);
		if (type == V_ASN1_INTEGER && length == 1)
		{
			attr_version = p[0];
			attr_version = attr_version;
		}
		p += length;
		
		// Only parse attributes we're interested in
		if (attr_type > ATTR_START && attr_type < ATTR_END)
		{
			NSString *key;
			
			ASN1_get_object(&p, &length, &type, &xclass, seq_end - p);
			if (type == V_ASN1_OCTET_STRING)
			{
				// Bytes
				if (attr_type == BUNDLE_ID || attr_type == OPAQUE_VALUE || attr_type == HASH)
				{
					NSData *data = [NSData dataWithBytes:p length:(NSUInteger)length];
					
					switch (attr_type)
					{
						case BUNDLE_ID:
							// This is included for hash generation
							key = kReceiptBundleIdentiferData;
							break;
						case OPAQUE_VALUE:
							key = kReceiptOpaqueValue;
							break;
						case HASH:
							key = kReceiptHash;
							break;
					}
					
					[info setObject:data forKey:key];
				}
				
				// Strings
				if (attr_type == BUNDLE_ID || attr_type == VERSION)
				{
					int str_type = 0;
					long str_length = 0;
					unsigned char const *str_p = p;
					ASN1_get_object(&str_p, &str_length, &str_type, &xclass, seq_end - str_p);
					if (str_type == V_ASN1_UTF8STRING)
					{
						NSString *string = [[[NSString alloc] initWithBytes:str_p
																	 length:(NSUInteger)str_length
																   encoding:NSUTF8StringEncoding] autorelease];
						
						switch (attr_type)
						{
							case BUNDLE_ID:
								key = kReceiptBundleIdentifer;
								break;
							case VERSION:
								key = kReceiptVersion;
								break;
						}
						
						[info setObject:string forKey:key];
					}
				}
			}
			p += length;
		}
		
		// Skip any remaining fields in this SEQUENCE
		while (p < seq_end)
		{
			ASN1_get_object(&p, &length, &type, &xclass, seq_end - p);
			p += length;
		}
	}
	
	PKCS7_free(p7);
	
	return info;
}

CFDataRef copyMACAddress(void)
{
	kern_return_t			  kernResult;
	mach_port_t				  master_port;
	CFMutableDictionaryRef	  matchingDict;
	io_iterator_t			  iterator;
	io_object_t				  service;
	CFDataRef				  macAddress = nil;
	
	kernResult = IOMasterPort(MACH_PORT_NULL, &master_port);
	if (kernResult != KERN_SUCCESS)
	{
		NSLog(@"IOMasterPort returned %d", kernResult);
		return nil;
	}
	
	matchingDict = IOBSDNameMatching(master_port, 0, "en0");
	if (!matchingDict)
	{
		NSLog(@"IOBSDNameMatching returned empty dictionary");
		return nil;
	}
	
	kernResult = IOServiceGetMatchingServices(master_port, matchingDict, &iterator);
	if (kernResult != KERN_SUCCESS)
	{
		NSLog(@"IOServiceGetMatchingServices returned %d", kernResult);
		return nil;
	}
	
	while((service = IOIteratorNext(iterator)) != 0)
	{
		io_object_t		   parentService;
		
		kernResult = IORegistryEntryGetParentEntry(service, kIOServicePlane, &parentService);
		if (kernResult == KERN_SUCCESS)
		{
			if (macAddress)
				CFRelease(macAddress);
			
			macAddress = IORegistryEntryCreateCFProperty(parentService, CFSTR("IOMACAddress"), kCFAllocatorDefault, 0);
			IOObjectRelease(parentService);
		}
		else
		{
			NSLog(@"IORegistryEntryGetParentEntry returned %d", kernResult);
		}
		
		IOObjectRelease(service);
	}
	
	return macAddress;
}

#define VALIDATION_FAIL_EXITCODE	173

void validateReceiptAtPath(NSString *path)
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

	NSDictionary *receipt = dictionaryWithAppStoreReceipt(path);
	if (!receipt) {
		[pool drain];
		exit(VALIDATION_FAIL_EXITCODE);
	}
	
	NSData *guidData = nil;
	
	// it turns out, it's a bad idea, to use these two NSBundle methods in your app:
	//
	// bundleVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
	// bundleIdentifer = [[NSBundle mainBundle] bundleIdentifier];
	//
	// http://www.craftymind.com/2011/01/06/mac-app-store-hacked-how-developers-can-better-protect-themselves/
	NSString *bundleVersion = nil;
	NSString *bundleIdentifer = nil;

//#undef TB_USE_SAMPLE_RECEIPT
#ifdef TB_USE_SAMPLE_RECEIPT
	bundleVersion = @"1.0.2";
	bundleIdentifer = @"com.example.SampleApp";

	// Example GUID for use with example receipt
	unsigned char guid[] = { 0x00, 0x17, 0xf2, 0xc4, 0xbc, 0xc0 };		
	guidData = [NSData dataWithBytes:guid length:sizeof(guid)];
#else
	bundleVersion = kElasticBundleShortVersionString;
	bundleIdentifer = kElasticBundleIdentifier;

	guidData = (NSData *)copyMACAddress();
	
	if ([NSGarbageCollector defaultCollector])
		[[NSGarbageCollector defaultCollector] enableCollectorForPointer:guidData];
	else 
		[guidData autorelease];
	
	if (!guidData) {
		[pool drain];
		exit(VALIDATION_FAIL_EXITCODE);
	}
	
	// double-check that hardcoded values match
	if (![bundleVersion isEqualToString:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]]) {
		NSLog(@"CFBundleShortVersionString mismatch !");
		abort();
	}
	if (![bundleIdentifer isEqualToString:[[NSBundle mainBundle] bundleIdentifier]]) {
		NSLog(@"CFBundleIdentifier mismatch");
		abort();
	}
#endif
	
	NSMutableData *input = [NSMutableData data];
	[input appendData:guidData];
	[input appendData:[receipt objectForKey:kReceiptOpaqueValue]];
	[input appendData:[receipt objectForKey:kReceiptBundleIdentiferData]];
	
	NSMutableData *hash = [NSMutableData dataWithLength:SHA_DIGEST_LENGTH];
	SHA1([input bytes], [input length], [hash mutableBytes]);
	
	if ([bundleIdentifer isEqualToString:[receipt objectForKey:kReceiptBundleIdentifer]] == NO
		|| [bundleVersion isEqualToString:[receipt objectForKey:kReceiptVersion]] == NO
		|| [hash isEqualToData:[receipt objectForKey:kReceiptHash]] == NO)
	{
		[pool drain];
		exit(VALIDATION_FAIL_EXITCODE);
	}
	
	[pool drain];
//	exit(VALIDATION_FAIL_EXITCODE);
}
