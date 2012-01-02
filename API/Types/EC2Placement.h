//
//  EC2Placement.h
//  Elastics
//
//  Created by Dmitri Goutnik on 01/03/2012.
//  Copyright 2012 Invisible Llama. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AWSType.h"

@interface EC2Placement : AWSType {
@private
	NSString	*_availabilityZone;
	NSString	*_groupName;
}

@property (nonatomic, retain, readonly) NSString *availabilityZone;
@property (nonatomic, retain, readonly) NSString *groupName;

@end
