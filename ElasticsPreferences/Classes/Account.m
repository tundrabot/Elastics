//
//  Account.m
//  ElasticsPreferences
//
//  Created by Dmitri Goutnik on 7/26/11.
//  Copyright 2011 Tundra Bot. All rights reserved.
//

#import "Account.h"

NSString *const kAccountDidChangeNotification	= @"kAccountsDidChangeNotification";

static NSString *const _secServiceName			= @"com.tundrabot.Elastics";
static NSString *const _mainAppBundleIdentifier	= @"com.tundrabot.Elastics";


@interface Account ()
- (NSString *)_keychainItemTitle;
- (NSData *)_archiveGenericAttributes;
- (void)_unarchiveGenericAttributes:(NSData *)data;
@end


@implementation Account

@synthesize id = _id;
@synthesize name = _name;
@synthesize accessKeyID = _accessKeyID;
@synthesize secretAccessKey = _secretAccessKey;
@synthesize defaultRegion = _defaultRegion;

+ (id)accountWithID:(NSInteger)id name:(NSString *)name accessKeyId:(NSString *)accessKeyId secretAccessKey:(NSString *)secretAccessKey
{
	return [[[self alloc] initWithID:id name:name accessKeyId:accessKeyId secretAccessKey:secretAccessKey] autorelease];
}

+ (id)accountWithKeychainItemRef:(SecKeychainItemRef)itemRef
{
	return [[[self alloc] initWithKeychainItemRef:itemRef] autorelease];
}

- (id)initWithID:(NSInteger)id name:(NSString *)name accessKeyId:(NSString *)accessKeyId secretAccessKey:(NSString *)secretAccessKey
{
    self = [super init];
    if (self) {
		_id = id;
		_name = [name copy];
		_accessKeyID = [accessKeyId copy];
		_secretAccessKey = [secretAccessKey copy];
		_defaultRegion = 0;
		_itemRef = NULL;
    }
    
    return self;
}

- (id)initWithKeychainItemRef:(SecKeychainItemRef)itemRef
{
	self = [super init];
	if (self) {
		
		_itemRef = (SecKeychainItemRef)CFRetain(itemRef);
		
		OSStatus status;
		UInt32 length; 
		void *data;
		
		SecKeychainAttribute attrs[] = {
			{ kSecAccountItemAttr, 0, NULL },
			{ kSecGenericItemAttr, 0, NULL },
		};
		SecKeychainAttributeList attributes = {
			sizeof(attrs) / sizeof(attrs[0]), attrs
		};
		
		status = SecKeychainItemCopyContent(itemRef,
											NULL,
											&attributes,
											&length,
											&data);
		if (status == noErr) {
			
			// attr.data is the Access Key Id and data is the password Secret Access Key
			
			TBRelease(_accessKeyID);
			_accessKeyID = [[NSString alloc] initWithBytes:attrs[0].data length:attrs[0].length encoding:NSUTF8StringEncoding];
			
			TBRelease(_secretAccessKey);
			_secretAccessKey = [[NSString alloc] initWithBytes:data length:length encoding:NSUTF8StringEncoding];
			
			[self _unarchiveGenericAttributes:[NSData dataWithBytes:attrs[1].data length:attrs[1].length]];
			
			SecKeychainItemFreeContent(&attributes, data);
		}
	}
	return self;
}

- (void)dealloc
{
	[_name release];
	[_accessKeyID release];
	[_secretAccessKey release];

	if (_itemRef) {
		CFRelease(_itemRef);
	}
	
	[super dealloc];
}


#pragma mark -
#pragma mark Account operations

- (void)save
{
	if (![_accessKeyID length] || ![_secretAccessKey length]) {
		// we cannot save keychain item with blank account or password
		return;
	}

    const char *serviceNameUTF8		= [_secServiceName UTF8String];
	const char *titleUTF8			= [[self _keychainItemTitle]  UTF8String];
	const char *accountUTF8			= [_accessKeyID UTF8String];
	const char *passwordUTF8		= [_secretAccessKey UTF8String];
	NSData *genericAttributesData	= [self _archiveGenericAttributes];
	
	// set up the attribute vector for item create/update (each attribute consists of {tag, length, data})
	SecKeychainAttribute attrs[] = {
		{ kSecServiceItemAttr, (UInt32)strlen(serviceNameUTF8), (char *)serviceNameUTF8 },
		{ kSecLabelItemAttr,   (UInt32)strlen(titleUTF8), (char *)titleUTF8 },
		{ kSecAccountItemAttr, (UInt32)strlen(accountUTF8), (char *)accountUTF8 },
		{ kSecGenericItemAttr, (UInt32)[genericAttributesData length], (char *)[genericAttributesData bytes] },
	};
	SecKeychainAttributeList attributes = {
		sizeof(attrs) / sizeof(attrs[0]), attrs
	};
	
	OSStatus status;
	SecAccessRef accessRef = NULL;
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	
	if (_itemRef) {
		// update an existing item
		
		status = SecKeychainItemModifyAttributesAndData(_itemRef,
														&attributes,
														(UInt32)strlen(passwordUTF8),
														passwordUTF8);
		if (status == noErr) {
			// notify observers that Acoount info just changed
			[notificationCenter postNotificationName:kAccountDidChangeNotification object:self];
		}
	}
	else {
		// create a new item
		
		// create ACL
		NSArray *trustedApplications = nil;
		
		// make list of trusted applications
		SecTrustedApplicationRef preferencesApp, mainApp;
		
		// get path to main application bundle
		NSString *mainAppBundlePath = [[NSWorkspace sharedWorkspace] absolutePathForAppBundleWithIdentifier:_mainAppBundleIdentifier];
		
		status = SecTrustedApplicationCreateFromPath(NULL, &preferencesApp);
		status = SecTrustedApplicationCreateFromPath([mainAppBundlePath UTF8String], &mainApp);
		trustedApplications = [NSArray arrayWithObjects:(id)preferencesApp, (id)mainApp, nil];
		
		// create an access object
		status = SecAccessCreate((CFStringRef)_secServiceName, (CFArrayRef)trustedApplications, &accessRef);
		if (status == noErr) {
			status = SecKeychainItemCreateFromContent(kSecGenericPasswordItemClass,
													  &attributes,
													  (UInt32)strlen(passwordUTF8),
													  passwordUTF8,
													  NULL,
													  accessRef,
													  &_itemRef);
			CFRetain(_itemRef);
			CFRelease(accessRef);
			
			if (status == noErr) {
				// notify observers that Acoount info just changed
				[notificationCenter postNotificationName:kAccountDidChangeNotification object:self];
			}
		}
	}
}

- (void)remove
{
	// remove account keychain item
	if (_itemRef) {
		OSStatus status;

		status = SecKeychainItemDelete(_itemRef);
		CFRelease(_itemRef), _itemRef = NULL;
	
		if (status == noErr) {
			// notify observers that Acoount info just changed
			[[NSNotificationCenter defaultCenter] postNotificationName:kAccountDidChangeNotification object:self];
		}
	}
}

#pragma mark -
#pragma mark Properties

- (void)setName:(NSString *)name
{
	if (_name != name) {
		[_name release];
		_name = [name copy];
		
		[self save];
	}
}

- (void)setAccessKeyID:(NSString *)accessKeyID
{
	if (_accessKeyID != accessKeyID) {
		[_accessKeyID release];
		_accessKeyID = [accessKeyID copy];
		
		[self save];
	}
}

- (void)setSecretAccessKey:(NSString *)secretAccessKey
{
	if (_secretAccessKey != secretAccessKey) {
		[_secretAccessKey release];
		_secretAccessKey = [secretAccessKey copy];
		
		[self save];
	}
}

- (void)setDefaultRegion:(NSInteger)defaultRegion
{
	if (_defaultRegion != defaultRegion) {
		_defaultRegion = defaultRegion;
		
		[self save];
	}
}

- (NSString *)title
{
	if ([_name length] > 0) {
		return _name;
	}
	else if ([_accessKeyID length] > 0) {
		if ([_accessKeyID length] > 10) {
			return [NSString stringWithFormat:@"%@...%@",
					[_accessKeyID substringToIndex:5],
					[_accessKeyID substringFromIndex:[_accessKeyID length] - 5]];
		}
		else
			return _accessKeyID;
	}
	else
		return @"Untitled";		// should not happen
}

- (NSString *)_keychainItemTitle
{
	return [NSString stringWithFormat:@"Elastics.%@", _accessKeyID];
}


static NSString *const kAccountAttributeIDKey				= @"id";
static NSString *const kAccountAttributeNameKey				= @"name";
static NSString *const kAccountAttributeDefaultRegionKey	= @"defaultRegion";

- (NSData *)_archiveGenericAttributes
{
	NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
								[NSNumber numberWithInteger:_id], kAccountAttributeIDKey,
								_name, kAccountAttributeNameKey,
								[NSNumber numberWithInteger:_defaultRegion], kAccountAttributeDefaultRegionKey,
								nil];
	return [NSKeyedArchiver archivedDataWithRootObject:attributes];
}

- (void)_unarchiveGenericAttributes:(NSData *)data
{
	if (data && [data length] > 0) {
		NSDictionary *attributes = [NSKeyedUnarchiver unarchiveObjectWithData:data];

		_id = [[attributes objectForKey:kAccountAttributeIDKey] integerValue];
		TBRelease(_name);
		_name = [[attributes objectForKey:kAccountAttributeNameKey] retain];
		_defaultRegion = [[attributes objectForKey:kAccountAttributeDefaultRegionKey] integerValue];
	}
}

@end
