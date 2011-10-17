//
//  DataSource.h
//  Elastics
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

+ (DataSource *)sharedDataSource;

+ (NSDictionary *)defaultRequestOptions;
+ (void)setDefaultRequestOptions:(NSDictionary *)options;

@property (nonatomic, retain) NSSet *compositeMonitoringMetrics;	// set of metric names to monitor globally
@property (nonatomic, retain) NSSet *instanceMonitoringMetrics;		// set of metric names to monitor for each instance

- (void)refresh;									// refresh all instances info and monitoring stats
- (void)refreshInstance:(NSString *)instanceId;		// refresh instances info and monitoring stats for selected instance

- (NSArray *)instances;								// all instances (array of EC2Instance)
- (NSArray *)sortedInstances;						// all instances (array of EC2Instance), sorted by title
- (EC2Instance *)instance:(NSString *)instanceId;	// instance with given id

//- (NSArray *)statisticsForMetric:(NSString *)metric;										// composite statistics for metric (array of MonitoringDatapoint)
- (NSArray *)statisticsForMetric:(NSString *)metric forInstance:(NSString *)instanceId;		// instance statistics for metric (array of MonitoringDatapoint)

// Max/Min/Average metric values
//- (CGFloat)maximumValueForMetric:(NSString *)metric forRange:(NSUInteger)range;
//- (CGFloat)minimumValueForMetric:(NSString *)metric forRange:(NSUInteger)range;
//- (CGFloat)averageValueForMetric:(NSString *)metric forRange:(NSUInteger)range;
- (CGFloat)maximumValueForMetric:(NSString *)metric forInstance:(NSString *)instanceId forRange:(NSUInteger)range;
- (CGFloat)minimumValueForMetric:(NSString *)metric forInstance:(NSString *)instanceId forRange:(NSUInteger)range;
- (CGFloat)averageValueForMetric:(NSString *)metric forInstance:(NSString *)instanceId forRange:(NSUInteger)range;

@end
