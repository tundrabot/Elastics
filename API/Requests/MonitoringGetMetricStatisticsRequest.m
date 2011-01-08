//
//  MonitoringGetMetricStatisticsRequest.m
//  Elastic
//
//  Created by Dmitri Goutnik on 22/12/2010.
//  Copyright 2010 Tundra Bot. All rights reserved.
//

#import "MonitoringGetMetricStatisticsRequest.h"

@implementation MonitoringGetMetricStatisticsRequest
@synthesize metric = _metric;
@synthesize instanceId = _instanceId;
@synthesize range = _range;

- (id)initWithOptions:(NSDictionary *)options delegate:(id<AWSRequestDelegate>)delegate
{
	self = [super initWithOptions:options delegate:delegate];
	if (self) {
		_range = kAWSLastHourRange;
	}
	return self;
}

- (void)dealloc
{
	[_metric release];
	[_instanceId release];
	[super dealloc];
}

- (BOOL)startWithParameters:(NSDictionary *)parameters
{
	NSDate *now = [NSDate date];
	
//	TBTrace(@"%@", parameters);

	// Default parameter values
	NSMutableDictionary *requestParameters = [NSMutableDictionary dictionaryWithObjectsAndKeys:
											  @"CPUUtilization", kAWSMetricNameParameter,
											  @"Minimum", @"Statistics.member.1",
											  @"Maximum", @"Statistics.member.2",
											  @"Average", @"Statistics.member.3",
											  @"AWS/EC2", kAWSNamespaceParameter,
											  [[now dateByAddingTimeInterval:-3600.0] iso8601String], kAWSStartTimeParameter,
											  [now iso8601String], kAWSEndTimeParameter,
											  @"60", kAWSPeriodParameter,
											  nil];
	[requestParameters addEntriesFromDictionary:parameters];
	
//	TBTrace(@"%@", requestParameters);
	
	return [self startRequestWithAction:@"GetMetricStatistics" parameters:requestParameters];
}

- (BOOL)start
{
	NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
	
	if (_metric) {
		[parameters setObject:_metric forKey:kAWSMetricNameParameter];
	}
	
	if (_instanceId) {
		NSDictionary *filter = [NSDictionary dictionaryWithObjectsAndKeys:
								[NSArray arrayWithObject:_instanceId], kAWSInstanceIdParameter,
								nil];
		[parameters addEntriesFromDictionary:[self dimensionListFromDictionary:filter]];
	}
	
	NSString *period = nil;
	switch (_range) {
		case kAWSLastHourRange:
		case kAWSLast3HoursRange:
			period = @"60";
			break;
		case kAWSLast6HoursRange:
			period = @"120";
			break;
		case kAWSLast12HoursRange:
			period = @"180";
			break;
		case kAWSLast24HoursRange:
			period = @"360";
			break;
		default:
			NSAssert(FALSE, @"Unsuported range value: %d", _range);
			break;
	}
	[parameters setObject:[[[NSDate date] dateByAddingTimeInterval:-((NSTimeInterval)_range + 360.0)] iso8601String] forKey:kAWSStartTimeParameter];
	[parameters setObject:period forKey:kAWSPeriodParameter];

	return [self startWithParameters:parameters];
}

- (MonitoringGetMetricStatisticsResponse *)response
{
	return (MonitoringGetMetricStatisticsResponse *)[super response];
}

- (AWSResponse *)parseResponse
{
	return [MonitoringGetMetricStatisticsResponse responseWithRootXMLElement:self.responseParser.rootXMLElement];
}

@end
