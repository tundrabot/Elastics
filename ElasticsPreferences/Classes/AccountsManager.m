//
//  AccountsManager.m
//  ElasticsPreferences
//
//  Created by Dmitri Goutnik on 26/07/2011.
//  Copyright 2011 Tundra Bot. All rights reserved.
//

#import "AccountsManager.h"
#import "Account.h"
#import "Constants.h"
#include <Security/Security.h>


@interface AccountsManager ()
- (void)insertObject:(Account *)accont inAccountsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromAccountsAtIndex:(NSUInteger)idx;
@end


@implementation AccountsManager

@synthesize accounts = _accounts;

- (id)init
{
    self = [super init];
    if (self) {
        _accounts = [[NSMutableArray alloc] init];
		[self loadAccounts];

		// XXX >>
//		[self saveAccounts];
//		[self loadAccounts];
		// << XXX
    }
    return self;
}

- (void)dealloc
{
	TBRelease(_accounts);
	[super dealloc];
}

- (void)loadAccounts
{
    const char *serviceNameUTF8 = [kElasticsSecServiceName UTF8String];
	
	OSStatus status;
	SecKeychainItemRef itemRef = NULL;
    SecKeychainSearchRef searchRef = NULL;
	
    // set up the attribute vector for search (each attribute consists of {tag, length, data})
    SecKeychainAttribute attributes[] = {
        { kSecServiceItemAttr, (UInt32)strlen(serviceNameUTF8), (char *)serviceNameUTF8 },
    };
    SecKeychainAttributeList attributeList = {
        sizeof(attributes) / sizeof(attributes[0]), attributes
    };
    
    status = SecKeychainSearchCreateFromAttributes(NULL,
                                                   kSecGenericPasswordItemClass,
                                                   &attributeList,
                                                   &searchRef);
    
    if (status == noErr) {
		[_accounts removeAllObjects];
        
        while (SecKeychainSearchCopyNext(searchRef, &itemRef) != errSecItemNotFound) {
			[_accounts addObject:[Account accountWithKeychainItemRef:itemRef]];
            CFRelease(itemRef);
        }
        
		CFRelease(searchRef);
    }
}

- (void)saveAccounts
{
	for (Account *account in _accounts) {
		[account save];
	}
}

- (void)addAccountWithName:(NSString *)name accessKeyId:(NSString *)accessKeyId secretAccessKey:(NSString *)secretAccessKey sshPrivateKeyFile:(NSString *)sshPrivateKeyFile sshUserName:(NSString *)sshUserName
{
	// make new account id to be max(existing IDs) + 1
	NSInteger __block maxAccountId = -1;
	[_accounts enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		Account *account = (Account *)obj;
		maxAccountId = MAX(account.id, maxAccountId);
	}];
	NSInteger newAccountId = maxAccountId + 1;
	
	Account *newAccount = [Account accountWithID:newAccountId
											name:name
									 accessKeyId:accessKeyId
								 secretAccessKey:secretAccessKey
							   sshPrivateKeyFile:sshPrivateKeyFile
									 sshUserName:sshUserName];
	[self insertObject:newAccount inAccountsAtIndex:[_accounts count]];
	[newAccount save];
}

- (void)removeAccountAtIndex:(NSUInteger)idx
{
	[self removeObjectFromAccountsAtIndex:idx];
}

- (Account *)accountWithId:(NSInteger)anId
{
	Account __block *result = nil;
	
	[_accounts enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		Account *account = (Account *)obj;
		if (account.id == anId) {
			result = account;
			*stop = YES;
		}
	}];
	
	return result;
}


#pragma mark -
#pragma mark KVC magic methods

- (void)insertObject:(Account *)accont inAccountsAtIndex:(NSUInteger)idx
{
	[_accounts insertObject:accont atIndex:idx];
}

- (void)removeObjectFromAccountsAtIndex:(NSUInteger)idx
{
	Account *account = [_accounts objectAtIndex:idx];
	[account remove];
	
	[_accounts removeObjectAtIndex:idx];
}

@end
