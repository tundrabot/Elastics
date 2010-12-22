//
//  EC2DescribeInstansesRequest.m
//  Cloudwatch
//
//  Created by Dmitri Goutnik on 01/12/2010.
//  Copyright 2010 Tundra Bot. All rights reserved.
//

#import "EC2DescribeInstancesRequest.h"

@interface EC2DescribeInstancesRequest ()
@property (nonatomic, retain) EC2DescribeInstancesResponse *response;
@end

@implementation EC2DescribeInstancesRequest

@synthesize response = _response;

- (void)dealloc
{
	[_response release];
	[super dealloc];
}

//
//	InstanceId	-> array
//	Filter		-> name/value hash
//
- (BOOL)startWithParameters:(NSDictionary *)parameters
{
	NSMutableDictionary *requestParameters = [NSMutableDictionary dictionary];
	
	NSArray *instanceId = [parameters valueForKey:kAWSInstanceIdParameter];
	[requestParameters addEntriesFromDictionary:[self _parameterListFromArray:instanceId key:kAWSInstanceIdParameter]];
	
	return [self _startRequestWithAction:@"DescribeInstances" parameters:requestParameters];
}

- (void)_parseResponseData
{
	TBXML *tbxml = [TBXML tbxmlWithXMLData:self.responseData];
	self.response = [EC2DescribeInstancesResponse responseWithRootXMLElement:tbxml.rootXMLElement];
}

@end
