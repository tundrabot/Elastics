//
//  EC2Monitoring.h
//  Cloudwatch
//
//  Created by Dmitri Goutnik on 01/12/2010.
//  Copyright 2010 Invisible Llama. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AWSType.h"

@interface EC2Monitoring : AWSType {
@private
	NSString	*_state;
}

@property (nonatomic, retain, readonly) NSString *state;

- (NSString *)monitoringType;

@end
