//
//  DataSource.h
//  Elastic
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
	NSMutableDictionary				*_runningRequests;
	EC2DescribeInstancesRequest		*_instancesRequest;
//	NSMutableDictionary				*_compositeMonitoringRequests;
	NSMutableDictionary				*_instanceMonitoringRequests;
}

+ (DataSource *)sharedInstance;

+ (NSDictionary *)defaultRequestOptions;
+ (void)setDefaultRequestOptions:(NSDictionary *)options;

// Set of metric names to monitor globally
@property (nonatomic, retain) NSSet *compositeMonitoringMetrics;
// Set of metric names to monitor for each instance
@property (nonatomic, retain) NSSet *instanceMonitoringMetrics;

// Refresh instance info and monitoring stats
- (void)refresh;
- (void)refreshInstance:(NSString *)instanceId;

// All instances (array of EC2Instance)
@property (nonatomic, retain, readonly) NSArray *instances;
// Returns an instance with given id
- (EC2Instance *)instance:(NSString *)instanceId;
// All statistics for metric (array of MonitoringDatapoint)
//- (NSArray *)statisticsForMetric:(NSString *)metric;

// Returns statistics for metric for given instance id
- (NSArray *)statisticsForMetric:(NSString *)metric forInstance:(NSString *)instanceId;

// Max/Min/Average metric values
//- (CGFloat)maximumValueForMetric:(NSString *)metric forRange:(NSUInteger)range;
//- (CGFloat)minimumValueForMetric:(NSString *)metric forRange:(NSUInteger)range;
//- (CGFloat)averageValueForMetric:(NSString *)metric forRange:(NSUInteger)range;
- (CGFloat)maximumValueForMetric:(NSString *)metric forInstance:(NSString *)instanceId forRange:(NSUInteger)range;
- (CGFloat)minimumValueForMetric:(NSString *)metric forInstance:(NSString *)instanceId forRange:(NSUInteger)range;
- (CGFloat)averageValueForMetric:(NSString *)metric forInstance:(NSString *)instanceId forRange:(NSUInteger)range;

@end
