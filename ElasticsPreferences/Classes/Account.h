//
//  Account.h
//  ElasticsPreferences
//
//  Created by Dmitri Goutnik on 7/26/11.
//  Copyright 2011 Tundra Bot. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <Security/Security.h>

// Notication set by Account when account data changes
extern NSString *const kAccountDidChangeNotification;

@interface Account : NSObject {
@private
	SecKeychainItemRef	_itemRef;
	NSString			*_accessKeyID;
	NSString			*_secretAccessKey;
	NSString			*_name;
	NSInteger			_defaultRegion;
	NSInteger			_order;
}

+ (id)accountWithName:(NSString *)name accessKeyId:(NSString *)accessKeyId secretAccessKey:(NSString *)secretAccessKey;
+ (id)accountWithKeychainItemRef:(SecKeychainItemRef)itemRef;

- (id)initWithName:(NSString *)name accessKeyId:(NSString *)accessKeyId secretAccessKey:(NSString *)secretAccessKey;
- (id)initWithKeychainItemRef:(SecKeychainItemRef)itemRef;

- (void)save;
- (void)remove;

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *accessKeyID;
@property (nonatomic, copy) NSString *secretAccessKey;
@property (nonatomic, assign) NSInteger defaultRegion;
@property (nonatomic, assign) NSInteger order;

@end
