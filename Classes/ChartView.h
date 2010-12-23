//
//  ChartView.h
//  Cloudwatch
//
//  Created by Dmitri Goutnik on 23/12/2010.
//  Copyright 2010 Tundra Bot. All rights reserved.
//

#import <Cocoa/Cocoa.h>

enum {
	TBChartRangeLastHour,
	TBChartRangeLast3Hours,
	TBChartRangeLast6Hours,
	TBChartRangeLast12Hours,
	TBChartRangeLast24Hours,
};

@interface ChartView : NSView {
	NSUInteger				_chartRange;
	NSUInteger				_expectedDatapointCount;
	NSArray					*_datapoints;
	NSProgressIndicator		*_spinner;
}

- (id)initWithRange:(NSUInteger)range datapoints:(NSArray *)datapoints;

@property (nonatomic, assign) NSUInteger chartRange;
@property (nonatomic, retain) NSArray *datapoints;

@end
