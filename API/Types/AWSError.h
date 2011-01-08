//
//  AWSError.h
//  Elastic
//
//  Created by Dmitri Goutnik on 27/12/2010.
//  Copyright 2010 Tundra Bot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AWSType.h"

// dictionaryRepresentation dictionary keys
extern NSString *const kAWSErrorTypeKey;
extern NSString *const kAWSErrorCodeKey;
extern NSString *const kAWSErrorMessageKey;

@interface AWSError : AWSType {
@private
	NSString		*_type;
	NSString		*_code;
	NSString		*_message;
}

@property (nonatomic, retain, readonly) NSString *type;
@property (nonatomic, retain, readonly) NSString *code;
@property (nonatomic, retain, readonly) NSString *message;

- (NSDictionary *)dictionaryRepresentation;

@end
