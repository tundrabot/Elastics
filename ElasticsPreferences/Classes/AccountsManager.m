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

- (Account *)findAccountWithKeychainItemRef:(SecKeychainItemRef)itemRef;
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
//        TBTrace(@"loading accounts");
		[_accounts removeAllObjects];
        
        while (1) {
            status = SecKeychainSearchCopyNext(searchRef, &itemRef);
            
            if (status == noErr) {
                
                // NOTE: for some reason unknown, SecKeychainSearchCopyNext sometimes returns the same item multiple times
                // HACK: to avoid adding duplicates, lets see if we already added account with the same itemRef
                
                Account *account = [self findAccountWithKeychainItemRef:itemRef];
                
                if (account) {
//                    TBTrace(@"found existing account item, skipping");
                }
                else {
//                    TBTrace(@"adding account item");
                    account = [Account accountWithKeychainItemRef:itemRef];
                    [_accounts addObject:account];
//                    TBTrace(@"account %p: %@", account, account);
                }
                
                TBCFRelease(itemRef);
            }
            else if (status == errSecItemNotFound) {
//                TBTrace(@"done loading accounts");
                break;
            }
            else {
                NSString *errorMessage = [NSMakeCollectable(SecCopyErrorMessageString(status, NULL)) autorelease];
                TBLog(@"error loading keychain item: %d, \"%@\"", status, errorMessage);
                break;
            }
        }
        
		TBCFRelease(searchRef);
    }
}

- (void)saveAccounts
{
	for (Account *account in _accounts) {
		[account save];
	}
}

- (OSStatus)addAccountWithName:(NSString *)name
                   accessKeyId:(NSString *)accessKeyId
               secretAccessKey:(NSString *)secretAccessKey
             sshPrivateKeyFile:(NSString *)sshPrivateKeyFile
                   sshUserName:(NSString *)sshUserName
                       sshPort:(NSUInteger)sshPort
                    sshOptions:(NSString *)sshOptions
{
	// make new account id to be max(existing IDs) + 1
	NSInteger __block maxAccountId = -1;
	[_accounts enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		Account *account = (Account *)obj;
		maxAccountId = MAX(account.accountId, maxAccountId);
	}];
	NSInteger newAccountId = maxAccountId + 1;
	
	Account *newAccount = [Account accountWithID:newAccountId
											name:name
									 accessKeyId:accessKeyId
								 secretAccessKey:secretAccessKey
							   sshPrivateKeyFile:sshPrivateKeyFile
									 sshUserName:sshUserName
                                         sshPort:sshPort
                                      sshOptions:sshOptions];
    
    OSStatus status = [newAccount save];

    if (status == noErr)
        [self insertObject:newAccount inAccountsAtIndex:[_accounts count]];
    
    return status;
}

- (OSStatus)updateAccountAtIndex:(NSUInteger)idx
                        withName:(NSString *)name
                     accessKeyId:(NSString *)accessKeyId
                 secretAccessKey:(NSString *)secretAccessKey
               sshPrivateKeyFile:(NSString *)sshPrivateKeyFile
                     sshUserName:(NSString *)sshUserName
                         sshPort:(NSUInteger)sshPort
                      sshOptions:(NSString *)sshOptions
{
    Account *account = [_accounts objectAtIndex:idx];
    
    // keep old values for undo (TODO: is there a better way?)
    NSString *nameCopy = [account.name copy];
    NSString *accessKeyIDCopy = [account.accessKeyID copy];
    NSString *secretAccessKeyCopy = [account.secretAccessKey copy];
    NSString *sshPrivateKeyFileCopy = [account.sshPrivateKeyFile copy];
    NSString *sshUserNameCopy = [account.sshUserName copy];
    NSUInteger sshPortCopy = account.sshPort;
    NSString *sshOptionsCopy = [account.sshOptions copy];

    account.name = name;
    account.accessKeyID = accessKeyId;
    account.secretAccessKey = secretAccessKey;
    account.sshPrivateKeyFile = sshPrivateKeyFile;
    account.sshUserName = sshUserName;
    account.sshPort = sshPort;
    account.sshOptions = sshOptions;

    OSStatus status = [account save];
    
    if (status != noErr) {
        // save failed, restore old values
        account.name = nameCopy;
        account.accessKeyID = accessKeyIDCopy;
        account.secretAccessKey = secretAccessKeyCopy;
        account.sshPrivateKeyFile = sshPrivateKeyFileCopy;
        account.sshUserName = sshUserNameCopy;
        account.sshPort = sshPortCopy;
        account.sshOptions = sshOptionsCopy;
    }
    
    [nameCopy release];
    [accessKeyIDCopy release];
    [secretAccessKeyCopy release];
    [sshPrivateKeyFileCopy release];
    [sshUserNameCopy release];
    [sshOptions release];

    return status;
}

- (void)removeAccountAtIndex:(NSUInteger)idx
{
	[self removeObjectFromAccountsAtIndex:idx];
}

- (Account *)accountWithId:(NSInteger)anId
{
	__block Account *result = nil;
	
	[_accounts enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		Account *account = (Account *)obj;
		if (account.accountId == anId) {
			result = account;
			*stop = YES;
		}
	}];
	
	return result;
}


- (Account *)findAccountWithKeychainItemRef:(SecKeychainItemRef)itemRef
{
	__block Account *result = nil;
	
	[_accounts enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		Account *account = (Account *)obj;
		if (account.itemRef == itemRef) {
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
