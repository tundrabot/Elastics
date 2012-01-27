//
//  EC2Group.h
//  Elastics
//
//  Created by Dmitri Goutnik on 27/01/2012.
//  Copyright 2012 Tundra Bot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AWSType.h"

@interface EC2Group : AWSType {
@private
	NSString	*_groupId;
}

@property (nonatomic, retain, readonly) NSString *groupId;

@end
