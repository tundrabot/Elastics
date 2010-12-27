//
//  AWSError.h
//  Cloudwatch
//
//  Created by Dmitri Goutnik on 27/12/2010.
//  Copyright 2010 Tundra Bot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AWSType.h"

@interface AWSError : AWSType {
@private
	NSString		*_type;
	NSString		*_code;
	NSString		*_message;
}

@property (nonatomic, retain, readonly) NSString *type;
@property (nonatomic, retain, readonly) NSString *code;
@property (nonatomic, retain, readonly) NSString *message;

@end
