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

@interface DataSource ()
@property (nonatomic, retain) NSDate *startedAt;
@property (nonatomic, retain) NSDate *completedAt;
@property (nonatomic, retain) NSMutableDictionary *completionNotificationUserInfo;
@property (nonatomic, retain) EC2DescribeInstancesRequest *instancesRequest;
@end

@implementation DataSource

@synthesize compositeMonitoringMetrics = _compositeMonitoringMetrics;
@synthesize instanceMonitoringMetrics = _instanceMonitoringMetrics;
@synthesize startedAt = _startedAt;
@synthesize completedAt = _completedAt;
@synthesize completionNotificationUserInfo = _completionNotificationUserInfo;
@synthesize instancesRequest = _instancesRequest;

#pragma mark -
#pragma mark Initialization

- (DataSource *)init
{
	self = [super init];
	if (self) {
		_runningRequests = [[NSMutableSet alloc] init];
		_compositeMonitoringMetrics = [[NSSet alloc] initWithObjects:kAWSCPUUtilizationMetric, nil];
		_instanceMonitoringMetrics = [[NSSet alloc] initWithObjects:kAWSCPUUtilizationMetric, nil];
		_compositeMonitoringRequests = [[NSMutableDictionary alloc] init];
		_instanceMonitoringRequests = [[NSMutableDictionary alloc] init];
	}
	return self;
}

- (void)dealloc
{
	TBRelease(_compositeMonitoringMetrics);
	TBRelease(_instanceMonitoringMetrics);
	TBRelease(_startedAt);
	TBRelease(_completedAt);
	TBRelease(_runningRequests);
	TBRelease(_completionNotificationUserInfo);
	TBRelease(_compositeMonitoringRequests);
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

- (void)release
{
}

- (id)autorelease
{
	return self;
}

#pragma mark -
#pragma mark Request options

+ (NSDictionary *)defaultRequestOptions
{
	return [AWSRequest defaultOptions];
}

+ (void)setDefaultRequestOptions:(NSDictionary *)options
{
	[AWSRequest setDefaultOptions:options];
}

#pragma mark -
#pragma mark Requests

- (void)refresh
{
	@synchronized(self) {
		if ([_runningRequests count] > 0) {
			TBTrace(@"refresh is already in progress !!!");
			return;
		}

		self.startedAt = [NSDate date];
		self.completionNotificationUserInfo = [NSMutableDictionary dictionary];
		[_runningRequests removeAllObjects];

		// schedule instances refresh
		if (!_instancesRequest)
			self.instancesRequest = [[EC2DescribeInstancesRequest alloc] initWithOptions:nil delegate:self];
		[_runningRequests addObject:_instancesRequest];

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
	}

	// start scheduled requests
	for (AWSRequest *request in _runningRequests) {
		[request start];
	}
}

- (void)refreshInstance:(NSString *)instanceId
{
	@synchronized(self) {
		if ([_runningRequests count] > 0) {
			TBTrace(@"refresh for %@ is already in progress !!!", instanceId);
			return;
		}

		self.startedAt = [NSDate date];
		self.completionNotificationUserInfo = [NSMutableDictionary dictionaryWithObject:instanceId forKey:kDataSourceInstanceIdInfoKey];
		[_runningRequests removeAllObjects];

		// schedule instance monitoring stats refresh
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
			}

			// only refresh monitoring data if it is first request or it is older than MAX_STATISTICS_AGE
			if (![monitoringRequest completedAt] || (-[[monitoringRequest completedAt] timeIntervalSinceNow] > MAX_STATISTICS_AGE)) {
				[_runningRequests addObject:monitoringRequest];
			}
			else {
				TBTrace(@"skipping instance stats request with age: %.2f", -[[monitoringRequest completedAt] timeIntervalSinceNow]);
			}
		}
	}

	for (AWSRequest *request in _runningRequests) {
		[request start];
	}
}

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

- (NSArray *)statisticsForMetric:(NSString *)metric
{
	MonitoringGetMetricStatisticsRequest *monitoringRequest = [_compositeMonitoringRequests objectForKey:metric];
	return monitoringRequest.response.result.datapoints;
}

- (NSArray *)statisticsForMetric:(NSString *)metric forInstance:(NSString *)instanceId
{
	NSDictionary *instanceMonitoringRequests = [_instanceMonitoringRequests objectForKey:instanceId];
	MonitoringGetMetricStatisticsRequest *monitoringRequest = [instanceMonitoringRequests objectForKey:metric];
	return monitoringRequest.response.result.datapoints;
}

- (CGFloat)maximumValueForMetric:(NSString *)metric forRange:(NSUInteger)range
{
	NSArray *stats = [self statisticsForMetric:metric];

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

- (CGFloat)minimumValueForMetric:(NSString *)metric forRange:(NSUInteger)range
{
	NSArray *stats = [self statisticsForMetric:metric];

	if ([stats count] > 0) {
		NSTimeInterval startTimestamp = [[NSDate date] timeIntervalSinceReferenceDate] - (NSTimeInterval)range;
		__block CGFloat result = MAXFLOAT;

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

- (CGFloat)averageValueForMetric:(NSString *)metric forRange:(NSUInteger)range
{
	NSArray *stats = [self statisticsForMetric:metric];

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

		return sum/count;
	}
	else
		return 0;
}

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
		__block CGFloat result = MAXFLOAT;

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

		return sum/count;
	}
	else
		return 0;
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

	BOOL refreshCompleted = NO;
	@synchronized(self) {
		[_runningRequests removeObject:request];
		if ([_runningRequests count] == 0) {
			refreshCompleted = YES;
			self.completedAt = [NSDate date];
		}
	}

	if (refreshCompleted) {
		// notify observers that refresh has been completed
		TBTrace(@"%.2fs", [_completedAt timeIntervalSinceDate:_startedAt]);

		[[NSNotificationCenter defaultCenter] postNotificationName:kDataSourceRefreshCompletedNotification
															object:self
														  userInfo:_completionNotificationUserInfo];
		self.completionNotificationUserInfo = nil;
	}
}

- (void)request:(AWSRequest *)request didFailWithError:(NSError *)error
{
	TBTrace(@"%@", error);

	BOOL refreshCompleted = NO;
	@synchronized(self) {
		[_runningRequests removeObject:request];
		if ([_runningRequests count] == 0) {
			refreshCompleted = YES;
			self.completedAt = [NSDate date];
		}
	}

	if (refreshCompleted) {
		// notify observers that refresh has been completed
		TBTrace(@"%.2fs, error: %@", [_completedAt timeIntervalSinceDate:_startedAt], error);

		[_completionNotificationUserInfo setObject:error forKey:kDataSourceErrorInfoKey];
		[[NSNotificationCenter defaultCenter] postNotificationName:kDataSourceRefreshCompletedNotification
															object:self
														  userInfo:_completionNotificationUserInfo];
		self.completionNotificationUserInfo = nil;
	}
}

@end
