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

extern NSString *const kDataSourceRefreshTypeInfoKey;
extern NSString *const kDataSourceErrorInfoKey;

extern NSString *const kDataSourceCurrentRegionRefreshType;
extern NSString *const kDataSourceAllRegionsRefreshType;

@interface DataSource : NSObject <AWSRequestDelegate> {
@private
	NSMutableDictionary				*_runningRefreshes;
	NSMutableDictionary             *_instanceRequests;                 // region -> EC2DescribeInstancesRequest
	NSMutableDictionary				*_instanceMonitoringRequests;       // instanceID -> MonitoringGetMetricStatisticsRequest
	NSSet							*_instanceMonitoringMetrics;
}

+ (DataSource *)sharedDataSource;

+ (NSDictionary *)defaultRequestOptions;
+ (void)setDefaultRequestOptions:(NSDictionary *)options;

//@property (nonatomic, retain) NSSet *compositeMonitoringMetrics;	// set of metric names to monitor globally
@property (nonatomic, retain) NSSet *instanceMonitoringMetrics;		// set of metric names to monitor for each instance

- (void)reset;

- (BOOL)refreshCurrentRegionIgnoringAge:(BOOL)ignoreAge;                    // begin refresh all instances in current region
- (BOOL)refreshAllRegionsIgnoringAge:(BOOL)ignoreAge;                       // begin refresh all instances in all regions
- (BOOL)refreshInstance:(NSString *)instanceId ignoringAge:(BOOL)ignoreAge; // begin refresh instance info and monitoring stats for selected instance in current region

- (NSArray *)instances;								// all instances (array of EC2Instance), for current region
- (NSArray *)sortedInstances;                       // all instances, sorted by title, for current region
- (NSArray *)runningInstances;                      // all instances except terminated, for current region
- (NSArray *)sortedRunningInstances;                // all instances except terminated, sorted by title, for current region
- (EC2Instance *)instance:(NSString *)instanceId;	// instance with given id

- (NSUInteger)instanceCountInRegion:(NSString *)awsRegion hideTerminatedInstances:(BOOL)hideTerminated;                      // instance count in given region
- (NSString *)instanceCountInRegionStringRepresentation:(NSString *)awsRegion hideTerminatedInstances:(BOOL)hideTerminated;  // instance count in given region as string

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
