//
//  MonitoringStatisticsResult.h
//  Elastic
//
//  Created by Dmitri Goutnik on 22/12/2010.
//  Copyright 2010 Tundra Bot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AWSType.h"

@interface MonitoringStatisticsResult : AWSType {
@private
	NSString	*_label;
	NSArray		*_datapoints;		// MonitoringDatapoint
}

@property (nonatomic, retain, readonly) NSString *label;
@property (nonatomic, retain, readonly) NSArray *datapoints;

@end
