//
//  MonitoringRequest.m
//  Cloudwatch
//
//  Created by Dmitri Goutnik on 22/12/2010.
//  Copyright 2010 Tundra Bot. All rights reserved.
//

#import "MonitoringRequest.h"

@implementation MonitoringRequest

- (id)initWithOptions:(NSDictionary *)options delegate:(id<AWSRequestDelegate>)delegate
{
	self = [super initWithOptions:options delegate:delegate];
	if (self) {
		self.service = kAWSMonitoringService;
	}
	return self;
}

@end
