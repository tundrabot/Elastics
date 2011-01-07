//
//  Keychain.m
//  CloudwatchPreferences
//
//  Created by Dmitri Goutnik on 07/01/2011.
//  Copyright 2011 Tundra Bot. All rights reserved.
//

#import "Keychain.h"
#include <Security/Security.h>

static NSString *const _secServiceName			= @"com.tundrabot.Cloudwatch";
static NSString *const _mainAppBundleIdentifier = @"com.tundrabot.Cloudwatch";

@interface Keychain ()
- (void)_getAwsCredentials;
- (void)_setAwsAccessKeyId:(NSString *)accessKeyId secretAccessKey:(NSString *)secretAccessKey;
@end

@implementation Keychain

@dynamic awsAccessKeyId;
@dynamic awsSecretAccessKey;

- (void)dealloc
{
	TBRelease(_awsAccessKeyId);
	TBRelease(_awsSecretAccessKey);
	[super dealloc];
}

- (NSString *)awsAccessKeyId
{
	[self _getAwsCredentials];
	TBTrace(@"%@", _awsAccessKeyId);
	return _awsAccessKeyId;
}

- (void)setAwsAccessKeyId:(NSString *)value
{
	if (_awsAccessKeyId != value) {
		[_awsAccessKeyId release];
		_awsAccessKeyId = [value copy];
		
		[self _setAwsAccessKeyId:_awsAccessKeyId secretAccessKey:_awsSecretAccessKey];
	}
}

- (NSString *)awsSecretAccessKey
{
	[self _getAwsCredentials];
	TBTrace(@"%@", _awsSecretAccessKey);
	return _awsSecretAccessKey;
}

- (void)setAwsSecretAccessKey:(NSString *)value
{
	if (_awsSecretAccessKey != value) {
		[_awsSecretAccessKey release];
		_awsSecretAccessKey = [value copy];
		
		[self _setAwsAccessKeyId:_awsAccessKeyId secretAccessKey:value];
	}
}

- (void)_getAwsCredentials
{
    const char *serviceNameUTF8 = [_secServiceName UTF8String];
	
	OSStatus			status;
	SecKeychainItemRef	itemRef = NULL;
	
	status = SecKeychainFindGenericPassword(
				NULL,
				strlen(serviceNameUTF8),
				serviceNameUTF8,
				0,
				NULL,
				0,
				NULL,
				&itemRef
			);
	
	if (status == noErr) {
		
		// Set up the attribute vector (each attribute consists of {tag, length, data})
		SecKeychainAttribute attrs[] = {
			{ kSecAccountItemAttr, 0, NULL },
		};
		SecKeychainAttributeList attributes = {
			sizeof(attrs) / sizeof(attrs[0]), attrs
		};
		
		UInt32	length; 
		void	*data;
		
		status = SecKeychainItemCopyContent(
					itemRef,
					NULL,
					&attributes,
					&length,
					&data
				);
		if (status == noErr) {
			// attr.data is the Access Key Id and data is the password Secret Access Key
			
			TBRelease(_awsAccessKeyId);
			if (attrs[0].length > 0)
				_awsAccessKeyId = [[NSString alloc] initWithBytes:attrs[0].data length:attrs[0].length encoding:NSUTF8StringEncoding];
			
			TBRelease(_awsSecretAccessKey);
			if (length > 0)
				_awsSecretAccessKey = [[NSString alloc] initWithBytes:data length:length encoding:NSUTF8StringEncoding];
			
			SecKeychainItemFreeContent(&attributes, data);
		}
		
		CFRelease(itemRef);
	}
}

- (void)_setAwsAccessKeyId:(NSString *)accessKeyId secretAccessKey:(NSString *)secretAccessKey;
{
	const char *label			= "Cloudwatch";
    const char *serviceNameUTF8 = [_secServiceName UTF8String];
    const char *accountUTF8		= accessKeyId ? [accessKeyId UTF8String] : "";
    const char *passwordUTF8	= secretAccessKey ? [secretAccessKey UTF8String] : "";
	
	// Set up the attribute vector (each attribute consists of {tag, length, data})
	SecKeychainAttribute attrs[] = {
		{ kSecLabelItemAttr, strlen(label), (char *)label },
		{ kSecServiceItemAttr, strlen(serviceNameUTF8), (char *)serviceNameUTF8 },
		{ kSecAccountItemAttr, strlen(accountUTF8), (char *)accountUTF8 },
	};
	SecKeychainAttributeList attributes = {
		sizeof(attrs) / sizeof(attrs[0]), attrs
	};
	
    OSStatus			status;
    SecKeychainItemRef	itemRef = NULL;
	SecAccessRef		accessRef = NULL;

	status = SecKeychainFindGenericPassword(
				NULL,
				strlen(serviceNameUTF8),
				serviceNameUTF8,
				0,
				NULL,
				0,
				NULL,
				&itemRef
			);
	
	if (status == noErr) {
		if (itemRef == NULL) {
			// Create new item

			// Create ACL
			NSArray *trustedApplications = nil;
			
			// Make list of trusted applications
			SecTrustedApplicationRef preferencesApp, mainApp;
			
			// Get path to main application bundle
			NSString *mainAppBundlePath = [[NSWorkspace sharedWorkspace] absolutePathForAppBundleWithIdentifier:_mainAppBundleIdentifier];
			
			status = SecTrustedApplicationCreateFromPath(NULL, &preferencesApp);
			status = SecTrustedApplicationCreateFromPath([mainAppBundlePath UTF8String], &mainApp);
			trustedApplications = [NSArray arrayWithObjects:(id)preferencesApp, (id)mainApp, nil];
			
			// Create an access object
			status = SecAccessCreate((CFStringRef)_secServiceName, (CFArrayRef)trustedApplications, &accessRef);
			if (status == noErr) {
				status = SecKeychainItemCreateFromContent(
							  kSecGenericPasswordItemClass,
							  &attributes,
							  strlen(passwordUTF8),
							  passwordUTF8,
							  NULL,
							  accessRef,
							  &itemRef
						  );
			
				CFRelease(accessRef);
			}
		}
		else {
			// Update an existing item
			
			status = SecKeychainItemModifyAttributesAndData(
						itemRef,
						&attributes,
						strlen(passwordUTF8),
						passwordUTF8
					);
		}
		
		CFRelease(itemRef);
	}
}

@end
