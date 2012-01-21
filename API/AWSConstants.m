//
//  AWSConstants.m
//  Elastics
//
//  Created by Dmitri Goutnik on 29/11/2010.
//  Copyright 2010 Tundra Bot. All rights reserved.
//

#import "AWSConstants.h"

// AWS domain
NSString *const kAWSDomain  = @"amazonaws.com";

// Regions
NSString *const kAWSUSEastRegion                = @"us-east-1";
NSString *const kAWSUSWestNorthCaliforniaRegion = @"us-west-1";
NSString *const kAWSUSWestOregonRegion          = @"us-west-2";
NSString *const kAWSEURegion                    = @"eu-west-1";
NSString *const kAWSAsiaPacificSingaporeRegion  = @"ap-southeast-1";
NSString *const kAWSAsiaPacificJapanRegion      = @"ap-northeast-1";
NSString *const kAWSSouthAmericaSaoPauloRegion  = @"sa-east-1";
NSString *const kAWSUSGovCloudRegion            = @"us-gov-west-1";

// Region titles
NSString *const kAWSUSEastRegionTitle                   = @"US East (Virginia)";
NSString *const kAWSUSWestNorthCaliforniaRegionTitle    = @"US West (North California)";
NSString *const kAWSUSWestOregonRegionTitle             = @"US West (Oregon)";
NSString *const kAWSEURegionTitle                       = @"EU West (Ireland)";
NSString *const kAWSAsiaPacificSingaporeRegionTitle     = @"Asia Pacific (Singapore)";
NSString *const kAWSAsiaPacificJapanRegionTitle         = @"Asia Pacific (Japan)";
NSString *const kAWSSouthAmericaSaoPauloRegionTitle     = @"South America (São Paulo)";
NSString *const kAWSUSGovCloudRegionTitle               = @"US GovCloud";

// Services
NSString *const kAWSEC2Service          = @"ec2";
NSString *const kAWSMonitoringService   = @"monitoring";

// Parameters
NSString *const kAWSInstanceIdParameter     = @"InstanceId";
NSString *const kAWSMetricNameParameter     = @"MetricName";
NSString *const kAWSStatisticsParameter     = @"Statistics";
NSString *const kAWSNamespaceParameter      = @"Namespace";
NSString *const kAWSStartTimeParameter      = @"StartTime";
NSString *const kAWSEndTimeParameter        = @"EndTime";
NSString *const kAWSPeriodParameter         = @"Period";

// Metrics
NSString *const kAWSCPUUtilizationMetric    = @"CPUUtilization";
NSString *const kAWSDiskReadBytesMetric     = @"DiskReadBytes";
NSString *const kAWSDiskReadOpsMetric       = @"DiskReadOps";
NSString *const kAWSDiskWriteBytesMetric    = @"DiskWriteBytes";
NSString *const kAWSDiskWriteOpsMetric      = @"DiskWriteOps";
NSString *const kAWSNetworkInMetric         = @"NetworkIn";
NSString *const kAWSNetworkOutMetric        = @"NetworkOut";

// Errors
NSString *const kAWSErrorDomain     = @"AWSError";
