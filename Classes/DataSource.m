//
//  DataSource.m
//  Cloudwatch
//
//  Created by Dmitri Goutnik on 21/12/2010.
//  Copyright 2010 Tundra Bot. All rights reserved.
//

#import "DataSource.h"

NSString *const kDataSourceAllRequestsCompletedNotification = @"DataSourceAllRequestsCompletedNotification";

@interface DataSource ()
@property (nonatomic, retain) NSDate *startedAt;
@property (nonatomic, retain) NSDate *completedAt;
@property (nonatomic, retain) NSMutableSet *runningRequests;
@property (nonatomic, retain) EC2DescribeInstancesRequest *describeInstancesRequest;
@property (nonatomic, retain) MonitoringGetMetricStatisticsRequest *getMetricStatisticsRequest;
@end

@implementation DataSource

@synthesize startedAt = _startedAt;
@synthesize completedAt = _completedAt;
@synthesize runningRequests = _runningRequests;
@synthesize describeInstancesRequest = _describeInstancesRequest;
@synthesize getMetricStatisticsRequest = _getMetricStatisticsRequest;

#pragma mark -
#pragma mark Initialization

- (DataSource *)init
{
	self = [super init];
	if (self) {
		_runningRequests = [[NSMutableSet alloc] init];
	}
	return self;
}

- (void)dealloc
{
	TB_RELEASE(_startedAt);
	TB_RELEASE(_completedAt);
	TB_RELEASE(_runningRequests);
	TB_RELEASE(_describeInstancesRequest);
	TB_RELEASE(_getMetricStatisticsRequest);
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
	return [EC2Request defaultOptions];
}

+ (void)setDefaultRequestOptions:(NSDictionary *)options
{
	[EC2Request setDefaultOptions:options];
}

#pragma mark -
#pragma mark 

- (void)startAllRequests
{
	self.startedAt = [NSDate date];
	[_runningRequests removeAllObjects];
	
	[self describeInstances:nil];
	[self getMetricStatistics:nil];
}

#pragma mark -
#pragma mark Instances

- (void)describeInstances:(NSDictionary *)parameters
{
	@synchronized(self) {
		if (!_describeInstancesRequest)
			self.describeInstancesRequest = [[EC2DescribeInstancesRequest alloc] initWithOptions:nil delegate:self];
		[_runningRequests addObject:_describeInstancesRequest];
	}
	[_describeInstancesRequest startWithParameters:parameters];
}

- (NSArray *)reservations
{
	return _describeInstancesRequest.response.reservationSet;
}
- (NSArray *)instances
{
	return _describeInstancesRequest.response.instancesSet;
}

#pragma mark -
#pragma mark Monitoring

- (void)getMetricStatistics:(NSDictionary *)parameters
{
	@synchronized(self) {
		if (!_getMetricStatisticsRequest)
			self.getMetricStatisticsRequest = [[MonitoringGetMetricStatisticsRequest alloc] initWithOptions:nil delegate:self];
		[_runningRequests addObject:_getMetricStatisticsRequest];
	}
	[_getMetricStatisticsRequest startWithParameters:parameters];
}

- (NSArray *)datapoints
{
	return _getMetricStatisticsRequest.response.result.datapoints;
}

#pragma mark -
#pragma mark Request delegate

- (void)requestDidStartLoading:(EC2Request *)request
{
	TB_TRACE(@"requestDidStartLoading: %@", NSStringFromClass([request class]));
}

- (void)requestDidFinishLoading:(EC2Request *)request
{
	TB_TRACE(@"requestDidFinishLoading: %@", NSStringFromClass([request class]));
	
	// notify observers that data is ready, notification name is the name of the request class
	[[NSNotificationCenter defaultCenter] postNotificationName:NSStringFromClass([request class]) object:self];

	[_runningRequests removeObject:request];
	if ([_runningRequests count] == 0) {
		// notify observers that refresh is completed
		self.completedAt = [NSDate date];
		TB_TRACE(@"kDataSourceAllRequestsCompletedNotification: %@ (duration %.2f sec)", _completedAt, [_completedAt timeIntervalSinceDate:_startedAt]);
		[[NSNotificationCenter defaultCenter] postNotificationName:kDataSourceAllRequestsCompletedNotification object:self];
	}
}

- (void)request:(EC2Request *)request didFailWithError:(NSError *)error
{
	TB_TRACE(@"request:didFailWithError: %@", error);
	
	// TODO: error notification
	
	[_runningRequests removeObject:request];
	if ([_runningRequests count] == 0) {
		// notify observers that refresh is completed
		self.completedAt = [NSDate date];
		TB_TRACE(@"kDataSourceAllRequestsCompletedNotification: %@ (duration %.2f sec)", _completedAt, [_completedAt timeIntervalSinceDate:_startedAt]);
		[[NSNotificationCenter defaultCenter] postNotificationName:kDataSourceAllRequestsCompletedNotification object:self];
	}
}

@end
