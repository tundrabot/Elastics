//
//  EC2Tag.h
//  Cloudwatch
//
//  Created by Dmitri Goutnik on 02/12/2010.
//  Copyright 2010 Tundra Bot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EC2Type.h"

@interface EC2Tag : EC2Type {
@private
	NSString	*_key;
	NSString	*_value;
}

@property (nonatomic, retain, readonly) NSString *key;
@property (nonatomic, retain, readonly) NSString *value;

@end
