//
//  MonitoringGetMetricStatisticsRequest.h
//  Cloudwatch
//
//  Created by Dmitri Goutnik on 22/12/2010.
//  Copyright 2010 Tundra Bot. All rights reserved.
//

#import "MonitoringRequest.h"
#import "MonitoringGetMetricStatisticsResponse.h"

@interface MonitoringGetMetricStatisticsRequest : MonitoringRequest {
	NSString								*_metric;
	NSString								*_instanceId;
	NSUInteger								_range;
	MonitoringGetMetricStatisticsResponse	*_response;
}

- (BOOL)start;

@property (nonatomic, retain) NSString *metric;
@property (nonatomic, retain) NSString *instanceId;
@property (nonatomic, assign) NSUInteger range;

@property (nonatomic, retain, readonly) MonitoringGetMetricStatisticsResponse *response;

@end
