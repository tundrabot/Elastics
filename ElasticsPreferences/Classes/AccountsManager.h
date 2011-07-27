//
//  AccountsManager.h
//  ElasticsPreferences
//
//  Created by Dmitri Goutnik on 26/07/2011.
//  Copyright 2011 Tundra Bot. All rights reserved.
//


@interface AccountsManager : NSObject {
    NSMutableArray  *_accounts;
}

@property (nonatomic, readonly) NSMutableArray *accounts;

- (void)loadAccounts;
- (void)saveAccounts;

@end
