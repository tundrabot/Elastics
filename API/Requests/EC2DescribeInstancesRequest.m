//
//  EC2DescribeInstansesRequest.m
//  Cloudwatch
//
//  Created by Dmitri Goutnik on 01/12/2010.
//  Copyright 2010 Tundra Bot. All rights reserved.
//

#import "EC2DescribeInstancesRequest.h"

@implementation EC2DescribeInstancesRequest

- (BOOL)start
{
	return [self _startRequestWithAction:@"DescribeInstances" parameters:nil];
}

- (EC2DescribeInstancesResponse *)response
{
	return (EC2DescribeInstancesResponse *)[super response];
}

- (void)_parseResponseData
{
	TBXMLElement *root = self.responseXML.rootXMLElement;
	_response = [[EC2DescribeInstancesResponse responseWithRootXMLElement:root] retain];
}

@end
