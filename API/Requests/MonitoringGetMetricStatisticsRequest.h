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
	MonitoringGetMetricStatisticsResponse	*_response;
}

- (BOOL)startWithParameters:(NSDictionary *)parameters;
@property (nonatomic, retain, readonly) MonitoringGetMetricStatisticsResponse *response;

@end
