//
//  AccountsManager.h
//  ElasticsPreferences
//
//  Created by Dmitri Goutnik on 26/07/2011.
//  Copyright 2011 Tundra Bot. All rights reserved.
//

#import "Account.h"

@interface AccountsManager : NSObject {
    NSMutableArray  *_accounts;
}

@property (nonatomic, retain, readonly) NSMutableArray *accounts;

- (void)loadAccounts;
- (void)saveAccounts;

- (OSStatus)addAccountWithName:(NSString *)name
                   accessKeyId:(NSString *)accessKeyId
               secretAccessKey:(NSString *)secretAccessKey
             sshPrivateKeyFile:(NSString *)sshPrivateKeyFile
                   sshUserName:(NSString *)sshUserName
                       sshPort:(NSUInteger)sshPort
                    sshOptions:(NSString *)sshOptions;

- (OSStatus)updateAccountAtIndex:(NSUInteger)idx
                        withName:(NSString *)name
                     accessKeyId:(NSString *)accessKeyId
                 secretAccessKey:(NSString *)secretAccessKey
               sshPrivateKeyFile:(NSString *)sshPrivateKeyFile
                     sshUserName:(NSString *)sshUserName
                         sshPort:(NSUInteger)sshPort
                      sshOptions:(NSString *)sshOptions;

- (void)removeAccountAtIndex:(NSUInteger)idx;

- (Account *)accountWithId:(NSInteger)id;

@end
