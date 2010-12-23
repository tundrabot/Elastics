//
//  MonitoringGetMetricStatisticsResponse.h
//  Cloudwatch
//
//  Created by Dmitri Goutnik on 22/12/2010.
//  Copyright 2010 Tundra Bot. All rights reserved.
//

#import "MonitoringResponse.h"
#import "MonitoringStatisticsResult.h"

@interface MonitoringGetMetricStatisticsResponse : MonitoringResponse {
@private
	MonitoringStatisticsResult		*_result;
}

@property (nonatomic, retain, readonly) MonitoringStatisticsResult *result;

@end
