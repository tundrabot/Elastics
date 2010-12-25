//
//  DataSource.h
//  Cloudwatch
//
//  Created by Dmitri Goutnik on 21/12/2010.
//  Copyright 2010 Tundra Bot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EC2DescribeInstancesRequest.h"
#import "EC2Instance.h"
#import "MonitoringGetMetricStatisticsRequest.h"
#import "MonitoringDatapoint.h"

// Notifies observers that all requests started by refresh have been completed
extern NSString *const kDataSourceRefreshCompletedNotification;

extern NSString *const kDataSourceInstanceIdInfoKey;
extern NSString *const kDataSourceErrorInfoKey;

@interface DataSource : NSObject <AWSRequestDelegate> {
@private
	NSSet							*_compositeMonitoringMetrics;
	NSSet							*_instanceMonitoringMetrics;
	NSDate							*_startedAt;
	NSDate							*_completedAt;
	NSMutableSet					*_runningRequests;
	NSMutableDictionary				*_completionNotificationUserInfo;
	EC2DescribeInstancesRequest		*_instancesRequest;
	NSMutableDictionary				*_compositeMonitoringRequests;
	NSMutableDictionary				*_instanceMonitoringRequests;
}

+ (DataSource *)sharedInstance;

+ (NSDictionary *)defaultRequestOptions;
+ (void)setDefaultRequestOptions:(NSDictionary *)options;

// Set of metric names to monitor globally
@property (nonatomic, retain) NSSet *compositeMonitoringMetrics;
// Set of metric names to monitor for each instance
@property (nonatomic, retain) NSSet *instanceMonitoringMetrics;

// Refresh instances and global monitoring stats
- (void)refresh;

// Refresh instance monitoring stats
- (void)refreshInstance:(NSString *)instanceId;

// Array of EC2Instance
@property (nonatomic, retain, readonly) NSArray *instances;

// Array of MonitoringDatapoint
- (NSArray *)statisticsForMetric:(NSString *)metric;
- (NSArray *)statisticsForMetric:(NSString *)metric forInstance:(NSString *)instanceId;

- (CGFloat)maximumValueForMetric:(NSString *)metric forRange:(NSUInteger)range;
- (CGFloat)minimumValueForMetric:(NSString *)metric forRange:(NSUInteger)range;
- (CGFloat)averageValueForMetric:(NSString *)metric forRange:(NSUInteger)range;
- (CGFloat)maximumValueForMetric:(NSString *)metric forInstance:(NSString *)instanceId forRange:(NSUInteger)range;
- (CGFloat)minimumValueForMetric:(NSString *)metric forInstance:(NSString *)instanceId forRange:(NSUInteger)range;
- (CGFloat)averageValueForMetric:(NSString *)metric forInstance:(NSString *)instanceId forRange:(NSUInteger)range;

@end
