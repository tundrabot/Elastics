//
//  EC2Request.m
//  Elastic
//
//  Created by Dmitri Goutnik on 22/12/2010.
//  Copyright 2010 Tundra Bot. All rights reserved.
//

#import "EC2Request.h"
#import "EC2ErrorResponse.h"

@implementation EC2Request

- (id)initWithOptions:(NSDictionary *)options delegate:(id<AWSRequestDelegate>)delegate
{
	self = [super initWithOptions:options delegate:delegate];
	if (self) {
		self.service = kAWSEC2Service;
	}
	return self;
}

- (AWSErrorResponse *)parseErrorResponse
{
	return [EC2ErrorResponse responseWithRootXMLElement:self.responseParser.rootXMLElement];
}

@end
