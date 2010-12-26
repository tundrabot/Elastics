//
//  NSData+CommonCryptor.m
//
//  Created by Dmitri Goutnik on 6/28/08.
//  Copyright 2008 Dmitri Goutnik. All rights reserved.
//

#import "NSData+CommonCryptor.h"
#include <CommonCrypto/CommonCryptor.h>

@implementation NSData (CommonCryptor)

+ (id)dataWithEncryptedFile:(NSString *)path key:(NSData *)key
{
	NSData *data = [[self alloc] initWithEncryptedFile:path key:key];
	return [data autorelease];
}

+ (id)dataWithEncryptedData:(NSData *)data key:(NSData *)key
{
	NSData *decryptedData = [[self alloc] initWithEncryptedData:data key:key];
	return [decryptedData autorelease];
}

- (id)initWithEncryptedFile:(NSString *)path key:(NSData *)key
{
	[self release];
	self = nil;
	NSData *cryptedData = [NSData dataWithContentsOfFile:path];
	if (cryptedData) {
		size_t dataOutMoved = 0;
		CCCryptorStatus status = CCCrypt(kCCDecrypt,
										 kCCAlgorithmAES128,
										 0,
										 [key bytes],
										 [key length],
										 NULL,
										 [cryptedData bytes],
										 [cryptedData length],
										 NULL,
										 0,
										 &dataOutMoved);
		if (status == kCCBufferTooSmall) {
			NSMutableData *decryptedData = [[NSMutableData alloc] initWithLength:dataOutMoved];
			status = CCCrypt(kCCDecrypt,
							 kCCAlgorithmAES128,
							 kCCOptionPKCS7Padding,
							 [key bytes],
							 [key length],
							 NULL,
							 [cryptedData bytes],
							 [cryptedData length],
							 [decryptedData mutableBytes],
							 [decryptedData length],
							 &dataOutMoved);
			if (status == kCCSuccess) {
				self = [[NSData alloc] initWithBytes:[decryptedData bytes] length:dataOutMoved];
			}
			[decryptedData release];
		}
	}
	return self;
}

- (BOOL)writeToEncryptedFile:(NSString *)path key:(NSData *)key atomically:(BOOL)flag
{
	BOOL result = FALSE;
	size_t dataOutMoved = 0;
	CCCryptorStatus status = CCCrypt(kCCEncrypt,
									 kCCAlgorithmAES128,
									 kCCOptionPKCS7Padding,
									 [key bytes],
									 [key length],
									 NULL,
									 [self bytes],
									 [self length],
									 NULL,
									 0,
									 &dataOutMoved);
	if (status == kCCBufferTooSmall) {
		NSMutableData *encryptedData = [[NSMutableData alloc] initWithLength:dataOutMoved];
		status = CCCrypt(kCCEncrypt,
						 kCCAlgorithmAES128,
						 kCCOptionPKCS7Padding,
						 [key bytes],
						 [key length],
						 NULL,
						 [self bytes],
						 [self length],
						 [encryptedData mutableBytes],
						 [encryptedData length],
						 &dataOutMoved);
		if (status == kCCSuccess) {
			NSAssert(dataOutMoved == [encryptedData length], @"data size and buffer size are different");
			result = [encryptedData writeToFile:path atomically:flag];
		}
		[encryptedData release];
	}
	return result;
}

- (id)initWithEncryptedData:(NSData *)data key:(NSData *)key
{
	[self release];
	self = nil;
	if (data) {
		size_t dataOutMoved = 0;
		CCCryptorStatus status = CCCrypt(kCCDecrypt,
										 kCCAlgorithmAES128,
										 0,
										 [key bytes],
										 [key length],
										 NULL,
										 [data bytes],
										 [data length],
										 NULL,
										 0,
										 &dataOutMoved);
		if (status == kCCBufferTooSmall) {
			NSMutableData *decryptedData = [[NSMutableData alloc] initWithLength:dataOutMoved];
			status = CCCrypt(kCCDecrypt,
							 kCCAlgorithmAES128,
							 kCCOptionPKCS7Padding,
							 [key bytes],
							 [key length],
							 NULL,
							 [data bytes],
							 [data length],
							 [decryptedData mutableBytes],
							 [decryptedData length],
							 &dataOutMoved);
			if (status == kCCSuccess) {
				self = [[NSData alloc] initWithBytes:[decryptedData bytes] length:dataOutMoved];
			}
			[decryptedData release];
		}
	}
	return self;
}

- (NSData *)encryptWithKey:(NSData *)key
{
	NSMutableData *result = nil;
	size_t dataOutMoved = 0;
	CCCryptorStatus status = CCCrypt(kCCEncrypt,
									 kCCAlgorithmAES128,
									 kCCOptionPKCS7Padding,
									 [key bytes],
									 [key length],
									 NULL,
									 [self bytes],
									 [self length],
									 NULL,
									 0,
									 &dataOutMoved);
	if (status == kCCBufferTooSmall) {
		result = [[NSMutableData alloc] initWithLength:dataOutMoved];
		status = CCCrypt(kCCEncrypt,
						 kCCAlgorithmAES128,
						 kCCOptionPKCS7Padding,
						 [key bytes],
						 [key length],
						 NULL,
						 [self bytes],
						 [self length],
						 [result mutableBytes],
						 [result length],
						 &dataOutMoved);
		if (status == kCCSuccess)
			NSAssert(dataOutMoved == [result length], @"result size and buffer size are different");
	}
	return [result autorelease];
}

@end
