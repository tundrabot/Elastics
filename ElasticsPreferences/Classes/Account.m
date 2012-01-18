//
//  Account.m
//  ElasticsPreferences
//
//  Created by Dmitri Goutnik on 7/26/11.
//  Copyright 2011 Tundra Bot. All rights reserved.
//

#import "Account.h"
#import "Constants.h"

NSString *const kAccountDidChangeNotification	= @"kAccountsDidChangeNotification";

@interface Account ()
- (NSString *)_keychainItemTitle;
- (NSData *)_archiveGenericAttributes;
- (void)_unarchiveGenericAttributes:(NSData *)data;
@end

@implementation Account

@synthesize accountId = _accountId;
@synthesize name = _name;
@synthesize accessKeyID = _accessKeyID;
@synthesize secretAccessKey = _secretAccessKey;
@synthesize defaultRegion = _defaultRegion;
@synthesize sshPrivateKeyFile = _sshPrivateKeyFile;
@synthesize sshUserName = _sshUserName;
@synthesize sshPort = _sshPort;
@synthesize itemRef = _itemRef;

+ (id)accountWithID:(NSInteger)accountId name:(NSString *)name accessKeyId:(NSString *)accessKeyId secretAccessKey:(NSString *)secretAccessKey sshPrivateKeyFile:(NSString *)sshPrivateKeyFile sshUserName:(NSString *)sshUserName sshPort:(NSUInteger)sshPort
{
	return [[[self alloc] initWithID:accountId
								name:name
						 accessKeyId:accessKeyId
					 secretAccessKey:secretAccessKey
				   sshPrivateKeyFile:sshPrivateKeyFile
						 sshUserName:sshUserName
                             sshPort:sshPort]
			autorelease];
}

+ (id)accountWithKeychainItemRef:(SecKeychainItemRef)itemRef
{
	return [[[self alloc] initWithKeychainItemRef:itemRef] autorelease];
}

- (id)initWithID:(NSInteger)accountId name:(NSString *)name accessKeyId:(NSString *)accessKeyId secretAccessKey:(NSString *)secretAccessKey sshPrivateKeyFile:(NSString *)sshPrivateKeyFile sshUserName:(NSString *)sshUserName sshPort:(NSUInteger)sshPort
{
    self = [super init];
    if (self) {
		_accountId = accountId;
		_name = [name copy];
		_accessKeyID = [accessKeyId copy];
		_secretAccessKey = [secretAccessKey copy];
		_defaultRegion = 0;
		_sshPrivateKeyFile = [sshPrivateKeyFile copy];
		_sshUserName = [_sshUserName copy];
        _sshPort = sshPort;
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
	[_sshPrivateKeyFile release];
	[_sshUserName release];

	TBCFRelease(_itemRef);
	
	[super dealloc];
}

#pragma mark - Account operations

- (OSStatus)save
{
	if (![_accessKeyID length] || ![_secretAccessKey length]) {
		// we cannot save keychain item with blank account or password
		return errSecParam;
	}

    const char *serviceNameUTF8		= [kElasticsSecServiceName UTF8String];
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
		if (status != noErr)
            return status;

        // notify observers that Acoount info just changed
		[notificationCenter postNotificationName:kAccountDidChangeNotification object:self];
	}
	else {
		// create a new item
		
		// create ACL
		NSArray *trustedApplications = nil;
		
		// make list of trusted applications
		SecTrustedApplicationRef preferencesApp, mainApp;
		
		// get path to main application bundle
		NSString *mainAppBundlePath = [[NSWorkspace sharedWorkspace] absolutePathForAppBundleWithIdentifier:kElasticsBundleIdentifier];
		
		status = SecTrustedApplicationCreateFromPath(NULL, &preferencesApp);
		if (status != noErr)
            return status;

		status = SecTrustedApplicationCreateFromPath([mainAppBundlePath UTF8String], &mainApp);
		if (status != noErr)
            return status;

		trustedApplications = [NSArray arrayWithObjects:(id)preferencesApp, (id)mainApp, nil];
		
		// create an access object
		status = SecAccessCreate((CFStringRef)kElasticsSecServiceName, (CFArrayRef)trustedApplications, &accessRef);
		if (status == noErr) {
			status = SecKeychainItemCreateFromContent(kSecGenericPasswordItemClass,
													  &attributes,
													  (UInt32)strlen(passwordUTF8),
													  passwordUTF8,
													  NULL,
													  accessRef,
													  &_itemRef);
            TBCFRelease(accessRef);

            if (status != noErr)
                return status;
            
            CFRetain(_itemRef);
        
            // notify observers that Acoount info just changed
            [notificationCenter postNotificationName:kAccountDidChangeNotification object:self];
		}
	}
    
    return noErr;
}

- (OSStatus)remove
{
	// remove account keychain item
	if (_itemRef) {
		OSStatus status;

		status = SecKeychainItemDelete(_itemRef);
		TBCFRelease(_itemRef);
	
		if (status != noErr)
            return status;
        
        // notify observers that Acoount info just changed
        [[NSNotificationCenter defaultCenter] postNotificationName:kAccountDidChangeNotification object:self];
	}
    
    return noErr;
}


#pragma mark - Properties

//- (void)setName:(NSString *)value
//{
//	if (_name != value) {
//		[_name release];
//		_name = [value copy];
//		
//		[self save];
//	}
//}
//
//- (void)setAccessKeyID:(NSString *)value
//{
//	if (_accessKeyID != value) {
//		[_accessKeyID release];
//		_accessKeyID = [value copy];
//		
//		[self save];
//	}
//}
//
//- (void)setSecretAccessKey:(NSString *)value
//{
//	if (_secretAccessKey != value) {
//		[_secretAccessKey release];
//		_secretAccessKey = [value copy];
//		
//		[self save];
//	}
//}
//
//- (void)setDefaultRegion:(NSInteger)value
//{
//	if (_defaultRegion != value) {
//		_defaultRegion = value;
//		
//		[self save];
//	}
//}
//
//- (void)setSshPrivateKeyFile:(NSString *)value
//{
//	if (_sshPrivateKeyFile != value) {
//		[_sshPrivateKeyFile release];
//		_sshPrivateKeyFile = [value copy];
//		
//		[self save];
//	}
//}
//
//- (void)setSshUserName:(NSString *)value
//{
//	if (_sshUserName != value) {
//		[_sshUserName release];
//		_sshUserName = [value copy];
//		
//		[self save];
//	}
//}

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

- (NSString *)description
{
    return [NSString stringWithFormat:@"{\n"
            "    _accountId = %d,\n"
            "    _name = %@,\n"
            "    _accessKeyID = %@,\n"
            "    _itemRef = %p\n"
            "}",
            _accountId,
            _name,
            _accessKeyID,
            _itemRef];
}


#pragma mark -

- (NSString *)_keychainItemTitle
{
	return [NSString stringWithFormat:@"Elastics.%@", _accessKeyID];
}


static NSString *const kAccountAttributeIDKey				= @"id";
static NSString *const kAccountAttributeNameKey				= @"name";
static NSString *const kAccountAttributeDefaultRegionKey	= @"defaultRegion";
static NSString *const kAccountSshPrivateKeyFileKey			= @"sshPrivateKeyFile";
static NSString *const kAccountSshUserNameKey				= @"sshUserName";
static NSString *const kAccountSshPortKey                   = @"sshPort";

- (NSData *)_archiveGenericAttributes
{
	NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
								[NSNumber numberWithInteger:_accountId], kAccountAttributeIDKey,
								_name, kAccountAttributeNameKey,
								[NSNumber numberWithInteger:_defaultRegion], kAccountAttributeDefaultRegionKey,
								_sshPrivateKeyFile, kAccountSshPrivateKeyFileKey,
								_sshUserName, kAccountSshUserNameKey,
                                [NSNumber numberWithInteger:_sshPort], kAccountSshPortKey,
								nil];
    
//    TBTrace(@"attributes: %@", attributes);

	return [NSKeyedArchiver archivedDataWithRootObject:attributes];
}

- (void)_unarchiveGenericAttributes:(NSData *)data
{
	if (data && [data length] > 0) {
		NSDictionary *attributes = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        
//        TBTrace(@"attributes: %@", attributes);

		_accountId = [[attributes objectForKey:kAccountAttributeIDKey] integerValue];
		_name = [[attributes objectForKey:kAccountAttributeNameKey] copy];
		_defaultRegion = [[attributes objectForKey:kAccountAttributeDefaultRegionKey] integerValue];
		_sshPrivateKeyFile = [[attributes objectForKey:kAccountSshPrivateKeyFileKey] copy];
		_sshUserName = [[attributes objectForKey:kAccountSshUserNameKey] copy];
		_sshPort = [[attributes objectForKey:kAccountSshPortKey] integerValue];
	}
    else {
        TBTrace(@"data dictionary is empty");
    }
}

@end
