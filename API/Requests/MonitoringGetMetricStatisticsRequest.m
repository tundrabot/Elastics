//
//  MonitoringGetMetricStatisticsRequest.m
//  Cloudwatch
//
//  Created by Dmitri Goutnik on 22/12/2010.
//  Copyright 2010 Tundra Bot. All rights reserved.
//

#import "MonitoringGetMetricStatisticsRequest.h"

@interface MonitoringGetMetricStatisticsRequest ()
@property (nonatomic, retain) MonitoringGetMetricStatisticsResponse *response;
@end

@implementation MonitoringGetMetricStatisticsRequest

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
	NSDate *now = [NSDate date];
	
	NSMutableDictionary *requestParameters = [NSMutableDictionary dictionaryWithObjectsAndKeys:
											  @"CPUUtilization", kAWSMetricNameParameter,
											  @"Minimum", @"Statistics.member.1",
											  @"Maximum", @"Statistics.member.2",
											  @"Average", @"Statistics.member.3",
											  @"AWS/EC2", kAWSNamespaceParameter,
											  [[now dateByAddingTimeInterval:-3660.0] iso8601String], kAWSStartTimeParameter,
											  [now iso8601String], kAWSEndTimeParameter,
											  @"60", kAWSPeriodParameter,
											  nil];
	[requestParameters addEntriesFromDictionary:parameters];
	
	return [self _startRequestWithAction:@"GetMetricStatistics" parameters:requestParameters];
}

- (void)_parseResponseData
{
	TBXML *tbxml = [TBXML tbxmlWithXMLData:self.responseData];
	self.response = [MonitoringGetMetricStatisticsResponse responseWithRootXMLElement:tbxml.rootXMLElement];
}

@end
