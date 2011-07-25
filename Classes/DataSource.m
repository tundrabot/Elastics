//
//  DataSource.m
//  Elastic
//
//  Created by Dmitri Goutnik on 21/12/2010.
//  Copyright 2010 Tundra Bot. All rights reserved.
//

#import "DataSource.h"

#define MAX_STATISTICS_AGE	60.f

NSString *const kDataSourceRefreshCompletedNotification = @"DataSourceRefreshCompletedNotification";

NSString *const kDataSourceInstanceIdInfoKey = @"DataSourceInstanceIdInfo";
NSString *const kDataSourceErrorInfoKey = @"DataSourceErrorInfo";

//@interface DataSource ()
//@property (nonatomic, retain) NSDate *startedAt;
//@property (nonatomic, retain) NSDate *completedAt;
//@property (nonatomic, retain) EC2DescribeInstancesRequest *instancesRequest;
//@end

@implementation DataSource

@synthesize compositeMonitoringMetrics = _compositeMonitoringMetrics;
@synthesize instanceMonitoringMetrics = _instanceMonitoringMetrics;
//@synthesize instancesRequest = _instancesRequest;

#pragma mark -
#pragma mark Initialization

- (DataSource *)init
{
	self = [super init];
	if (self) {
		_runningRequests = [[NSMutableDictionary alloc] init];
		_compositeMonitoringMetrics = [[NSSet alloc] initWithObjects:kAWSCPUUtilizationMetric, nil];
		_instanceMonitoringMetrics = [[NSSet alloc] initWithObjects:kAWSCPUUtilizationMetric, nil];
//		_compositeMonitoringRequests = [[NSMutableDictionary alloc] init];
		_instanceMonitoringRequests = [[NSMutableDictionary alloc] init];
	}
	return self;
}

- (void)dealloc
{
	TBRelease(_compositeMonitoringMetrics);
	TBRelease(_instanceMonitoringMetrics);
	TBRelease(_runningRequests);
	TBRelease(_instancesRequest);
//	TBRelease(_compositeMonitoringRequests);
	TBRelease(_instanceMonitoringRequests);
	[super dealloc];
}

#pragma mark -
#pragma mark Singleton

static DataSource * _sharedInstance = nil;

+ (DataSource *)sharedInstance
{
	@synchronized(self) {
		if (_sharedInstance == nil) {
			[[self alloc] init];
		}
	}
	return _sharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone
{
	@synchronized(self) {
		if (_sharedInstance == nil) {
			_sharedInstance = [super allocWithZone:zone];
		}
	}
	return _sharedInstance;
}

- (id)copyWithZone:(NSZone *)data
{
	return self;
}

- (id)retain
{
	return self;
}

- (NSUInteger)retainCount
{
	return NSUIntegerMax;
}

- (oneway void)release
{
}

- (id)autorelease
{
	return self;
}

#pragma mark -
#pragma mark Request handling

+ (NSDictionary *)defaultRequestOptions
{
	return [AWSRequest defaultOptions];
}

+ (void)setDefaultRequestOptions:(NSDictionary *)options
{
	[AWSRequest setDefaultOptions:options];
}

- (void)refresh
{
	@synchronized(self) {

		NSMutableDictionary *requestInfo = [_runningRequests objectForKey:@"r"];
		if (requestInfo) {
			TBTrace("refresh is already in progress !!!");
			return;
		}
		requestInfo = [NSMutableDictionary dictionary];

		[requestInfo setObject:[NSDate date] forKey:@"kStartedAt"];

		NSMutableSet *requestSet = [NSMutableSet set];
		[requestInfo setObject:requestSet forKey:@"kRequestSet"];

		if (!_instancesRequest) {
			_instancesRequest = [[EC2DescribeInstancesRequest alloc] initWithOptions:nil delegate:self];
		}
		[requestSet addObject:_instancesRequest];
	

//		// schedule composite monitoring stats refresh
//		for (NSString *metric in _compositeMonitoringMetrics) {
//			MonitoringGetMetricStatisticsRequest *monitoringRequest = [_compositeMonitoringRequests objectForKey:metric];
//
//			if (!monitoringRequest) {
//				monitoringRequest = [[MonitoringGetMetricStatisticsRequest alloc] initWithOptions:nil delegate:self];
//				[_compositeMonitoringRequests setObject:monitoringRequest forKey:metric];
//			}
//
//			// Only refresh monitoring data if it is first request or it is older than MAX_STATISTICS_AGE
//			if (![monitoringRequest completedAt] || (-[[monitoringRequest completedAt] timeIntervalSinceNow] > MAX_STATISTICS_AGE)) {
//				[_runningRequests addObject:monitoringRequest];
//			}
//			else {
//				TBTrace(@"skipping composite stats request with age: %.2f", -[[monitoringRequest completedAt] timeIntervalSinceNow]);
//			}
//
//		}

		// do we have anything scheduled? then add requestInfo to running requests and start requests
		if ([requestSet count] > 0) {
			[_runningRequests setObject:requestInfo forKey:@"r"];
			
			for (AWSRequest *request in requestSet) {
				[request start];
			}
		}
	}
}

- (void)refreshInstance:(NSString *)instanceId
{
	@synchronized(self) {
		
		NSMutableDictionary *requestInfo = [_runningRequests objectForKey:instanceId];
		if (requestInfo) {
			TBTrace("refresh for %@ is already in progress !!!", instanceId);
			return;
		}
		requestInfo = [NSMutableDictionary dictionary];
		
		[requestInfo setObject:instanceId forKey:kDataSourceInstanceIdInfoKey];
		[requestInfo setObject:[NSDate date] forKey:@"kStartedAt"];
		
		NSMutableSet *requestSet = [NSMutableSet set];
		[requestInfo setObject:requestSet forKey:@"kRequestSet"];

		NSMutableDictionary *instanceMonitoringRequests = [_instanceMonitoringRequests objectForKey:instanceId];
		if (!instanceMonitoringRequests) {
			instanceMonitoringRequests = [NSMutableDictionary dictionary];
			[_instanceMonitoringRequests setObject:instanceMonitoringRequests forKey:instanceId];
		}

		for (NSString *metric in _instanceMonitoringMetrics) {
			MonitoringGetMetricStatisticsRequest *monitoringRequest = [instanceMonitoringRequests objectForKey:metric];

			if (!monitoringRequest) {
				monitoringRequest = [[MonitoringGetMetricStatisticsRequest alloc] initWithOptions:nil delegate:self];
				monitoringRequest.instanceId = instanceId;
				monitoringRequest.metric = metric;
				[instanceMonitoringRequests setObject:monitoringRequest forKey:metric];
				[monitoringRequest release];
			}

			// only schedule monitoring data refresh when it is first request
			//	or it is older than MAX_STATISTICS_AGE
			//	or it has no datapoints
			if (![monitoringRequest completedAt]
				|| (-[[monitoringRequest completedAt] timeIntervalSinceNow] > MAX_STATISTICS_AGE)
				|| ![monitoringRequest.response.result.datapoints count])
				[requestSet addObject:monitoringRequest];
			else
				TBTrace("skipping instance %@ stats request with age: %.2f", instanceId, -[[monitoringRequest completedAt] timeIntervalSinceNow]);
		}
	
		// do we have anything scheduled? then add requestInfo to running requests and start requests
		if ([requestSet count] > 0) {
			[_runningRequests setObject:requestInfo forKey:instanceId];
			
			for (AWSRequest *request in requestSet) {
				[request start];
			}
		}
	}
}

#pragma mark -
#pragma mark Request delegate

- (void)requestDidStartLoading:(AWSRequest *)request
{
	//	TBTrace(@"");
}

- (void)requestDidFinishLoading:(AWSRequest *)request
{
	//	TBTrace(@"");
	
	NSMutableDictionary *finishedRequest = nil;
	
//	@synchronized(self) {
		NSArray *keys = [_runningRequests allKeys];
		
		for (NSString *key in keys) {
			NSMutableDictionary *requestInfo = [_runningRequests objectForKey:key];
			NSMutableSet *requestSet = [requestInfo objectForKey:@"kRequestSet"];
			
			[requestSet removeObject:request];
			
			if ([requestSet count] == 0) {
				[requestInfo setObject:[NSDate date] forKey:@"kFinishedAt"];
				finishedRequest = [requestInfo retain];
				[_runningRequests removeObjectForKey:key];
				
				break;
			}
		}
//	}
	
	NSAssert(finishedRequest != nil, @"requestDidFinishLoading: but no finished request was found.");
	
#ifdef TB_DEBUG
	NSDate *startedAt = [finishedRequest objectForKey:@"kStartedAt"];
	NSDate *finishedAt = [finishedRequest objectForKey:@"kFinishedAt"];
	NSString *instanceId = [finishedRequest objectForKey:kDataSourceInstanceIdInfoKey];
	if (instanceId)
		TBTrace("%.2fs, instance %@", [finishedAt timeIntervalSinceDate:startedAt], instanceId);
	else
		TBTrace("%.2fs, all instances", [finishedAt timeIntervalSinceDate:startedAt]);
#endif
		
	[[NSNotificationCenter defaultCenter] postNotificationName:kDataSourceRefreshCompletedNotification
														object:self
													  userInfo:finishedRequest];
	
	[finishedRequest release];
}

- (void)request:(AWSRequest *)request didFailWithError:(NSError *)error
{
	//	TBTrace(@"");
	
	NSMutableDictionary *finishedRequest = nil;
	
//	@synchronized(self) {
		NSArray *keys = [_runningRequests allKeys];
		
		for (NSString *key in keys) {
			NSMutableDictionary *requestInfo = [_runningRequests objectForKey:key];
			NSMutableSet *requestSet = [requestInfo objectForKey:@"kRequestSet"];
			
			[requestSet removeObject:request];
			
			if ([requestSet count] == 0) {
				[requestInfo setObject:[NSDate date] forKey:@"kFinishedAt"];
				finishedRequest = [requestInfo retain];
				[_runningRequests removeObjectForKey:key];
				
				break;
			}
		}
//	}
	
	NSAssert(finishedRequest != nil, @"requestDidFinishLoading: but no finished request was found.");
	
#ifdef TB_DEBUG
	NSDate *startedAt = [finishedRequest objectForKey:@"kStartedAt"];
	NSDate *finishedAt = [finishedRequest objectForKey:@"kFinishedAt"];
	TBTrace("%.2fs, error: %@", [finishedAt timeIntervalSinceDate:startedAt], error);
#endif
	
	[finishedRequest setObject:error forKey:kDataSourceErrorInfoKey];
	[[NSNotificationCenter defaultCenter] postNotificationName:kDataSourceRefreshCompletedNotification
														object:self
													  userInfo:finishedRequest];
	
	[finishedRequest release];
}

#pragma mark -
#pragma mark Data accessors and helpers

- (NSArray *)instances
{
	return _instancesRequest.response.instancesSet;
}

- (EC2Instance *)instance:(NSString *)instanceId
{
	NSUInteger instanceIdx = [self.instances indexOfObjectPassingTest:^(id obj, NSUInteger idx, BOOL *stop) {
		*stop = [[obj instanceId] isEqualToString:instanceId];
		return *stop;
	}];
	
	return instanceIdx != NSNotFound ? [self.instances objectAtIndex:instanceIdx] : nil;
}

//- (NSArray *)statisticsForMetric:(NSString *)metric
//{
//	MonitoringGetMetricStatisticsRequest *monitoringRequest = [_compositeMonitoringRequests objectForKey:metric];
//	return monitoringRequest.response.result.datapoints;
//}

- (NSArray *)statisticsForMetric:(NSString *)metric forInstance:(NSString *)instanceId
{
	NSDictionary *instanceMonitoringRequests = [_instanceMonitoringRequests objectForKey:instanceId];
	MonitoringGetMetricStatisticsRequest *monitoringRequest = [instanceMonitoringRequests objectForKey:metric];
	return monitoringRequest.response.result.datapoints;
}

//- (CGFloat)maximumValueForMetric:(NSString *)metric forRange:(NSUInteger)range
//{
//	NSArray *stats = [self statisticsForMetric:metric];
//
//	if ([stats count] > 0) {
//		NSTimeInterval startTimestamp = [[NSDate date] timeIntervalSinceReferenceDate] - (NSTimeInterval)range;
//		__block CGFloat result = 0;
//
//		[stats enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//			MonitoringDatapoint *datapoint = (MonitoringDatapoint *)obj;
//			if (datapoint.timestamp > startTimestamp && datapoint.maximum > result) {
//				result = datapoint.maximum;
//			}
//		}];
//
//		return result;
//	}
//	else
//		return 0;
//}

//- (CGFloat)minimumValueForMetric:(NSString *)metric forRange:(NSUInteger)range
//{
//	NSArray *stats = [self statisticsForMetric:metric];
//
//	if ([stats count] > 0) {
//		NSTimeInterval startTimestamp = [[NSDate date] timeIntervalSinceReferenceDate] - (NSTimeInterval)range;
//		__block CGFloat result = MAXFLOAT;
//
//		[stats enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//			MonitoringDatapoint *datapoint = (MonitoringDatapoint *)obj;
//			if (datapoint.timestamp > startTimestamp && datapoint.minimum < result) {
//				result = datapoint.minimum;
//			}
//		}];
//
//		return result;
//	}
//	else
//		return 0;
//}

//- (CGFloat)averageValueForMetric:(NSString *)metric forRange:(NSUInteger)range
//{
//	NSArray *stats = [self statisticsForMetric:metric];
//
//	if ([stats count] > 0) {
//		NSTimeInterval startTimestamp = [[NSDate date] timeIntervalSinceReferenceDate] - (NSTimeInterval)range;
//		__block CGFloat sum = 0;
//		__block NSUInteger count = 0;
//
//		[stats enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//			MonitoringDatapoint *datapoint = (MonitoringDatapoint *)obj;
//			if (datapoint.timestamp > startTimestamp) {
//				sum += datapoint.average;
//				count++;
//			}
//		}];
//
//		return sum/count;
//	}
//	else
//		return 0;
//}

- (CGFloat)maximumValueForMetric:(NSString *)metric forInstance:(NSString *)instanceId forRange:(NSUInteger)range
{
	NSArray *stats = [self statisticsForMetric:metric forInstance:instanceId];

	if ([stats count] > 0) {
		NSTimeInterval startTimestamp = [[NSDate date] timeIntervalSinceReferenceDate] - (NSTimeInterval)range;
		__block CGFloat result = 0;

		[stats enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
			MonitoringDatapoint *datapoint = (MonitoringDatapoint *)obj;
			if (datapoint.timestamp > startTimestamp && datapoint.maximum > result) {
				result = datapoint.maximum;
			}
		}];

		return result;
	}
	else
		return 0;
}

- (CGFloat)minimumValueForMetric:(NSString *)metric forInstance:(NSString *)instanceId forRange:(NSUInteger)range
{
	NSArray *stats = [self statisticsForMetric:metric forInstance:instanceId];

	if ([stats count] > 0) {
		NSTimeInterval startTimestamp = [[NSDate date] timeIntervalSinceReferenceDate] - (NSTimeInterval)range;
		__block CGFloat result = 0;

		[stats enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
			MonitoringDatapoint *datapoint = (MonitoringDatapoint *)obj;
			if (datapoint.timestamp > startTimestamp && datapoint.minimum < result) {
				result = datapoint.minimum;
			}
		}];

		return result;
	}
	else
		return 0;
}

- (CGFloat)averageValueForMetric:(NSString *)metric forInstance:(NSString *)instanceId forRange:(NSUInteger)range
{
	NSArray *stats = [self statisticsForMetric:metric forInstance:instanceId];

	if ([stats count] > 0) {
		NSTimeInterval startTimestamp = [[NSDate date] timeIntervalSinceReferenceDate] - (NSTimeInterval)range;
		__block CGFloat sum = 0;
		__block NSUInteger count = 0;

		[stats enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
			MonitoringDatapoint *datapoint = (MonitoringDatapoint *)obj;
			if (datapoint.timestamp > startTimestamp) {
				sum += datapoint.average;
				count++;
			}
		}];

		return count != 0 ? sum/count : 0;
	}
	else
		return 0;
}

@end
