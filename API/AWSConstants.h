//
//  AWSConstants.h
//  Cloudwatch
//
//  Created by Dmitri Goutnik on 29/11/2010.
//  Copyright 2010 Tundra Bot. All rights reserved.
//

// Regions
extern NSString *const kAWSUSEastRegion;
extern NSString *const kAWSUSWestRegion;
extern NSString *const kAWSEURegion;
extern NSString *const kAWSAsiaPacificRegion;

extern NSString *const kAWSUSEastRegionName;
extern NSString *const kAWSUSWestRegionName;
extern NSString *const kAWSEURegionName;
extern NSString *const kAWSAsiaPacificRegionName;

// Services
extern NSString *const kAWSEC2Service;
extern NSString *const kAWSMonitoringService;

// Parameters
extern NSString *const kAWSInstanceIdParameter;
extern NSString *const kAWSMetricNameParameter;
extern NSString *const kAWSStatisticsParameter;
extern NSString *const kAWSNamespaceParameter;
extern NSString *const kAWSStartTimeParameter;
extern NSString *const kAWSEndTimeParameter;
extern NSString *const kAWSPeriodParameter;

// Metrics
extern NSString *const kAWSCPUUtilizationMetric;
extern NSString *const kAWSDiskReadBytesMetric;
extern NSString *const kAWSDiskReadOpsMetric;
extern NSString *const kAWSDiskWriteBytesMetric;
extern NSString *const kAWSDiskWriteOpsMetric;
extern NSString *const kAWSNetworkInMetric;
extern NSString *const kAWSNetworkOutMetric;

// Supported metric statistics ranges
#define kAWSLastHourRange		3600
#define kAWSLast3HoursRange		10800
#define kAWSLast6HoursRange		21600
#define kAWSLast12HoursRange	43200
#define kAWSLast24HoursRange	86400

// Errors
extern NSString *const kAWSErrorDomain;
