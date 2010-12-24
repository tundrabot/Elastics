//
//  ChartView.h
//  Cloudwatch
//
//  Created by Dmitri Goutnik on 23/12/2010.
//  Copyright 2010 Tundra Bot. All rights reserved.
//

#import <Cocoa/Cocoa.h>

//enum {
//	TBChartRangeLastHour		= 3600,
//	TBChartRangeLast3Hours		= 10800,
//	TBChartRangeLast6Hours		= 21600,
//	TBChartRangeLast12Hours		= 43200,
//	TBChartRangeLast24Hours		= 86400,
//};

@interface ChartView : NSView {
	NSUInteger				_chartRange;
	NSArray					*_datapoints;
	NSProgressIndicator		*_spinner;
}

- (id)initWithRange:(NSUInteger)range datapoints:(NSArray *)datapoints;

@property (nonatomic, assign) NSUInteger chartRange;
@property (nonatomic, retain) NSArray *datapoints;

@end
