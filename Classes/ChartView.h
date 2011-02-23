//
//  ChartView.h
//  Elastics
//
//  Created by Dmitri Goutnik on 23/12/2010.
//  Copyright 2010 Tundra Bot. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ChartView : NSView {
@private
	NSUInteger				_chartRange;
	NSArray					*_datapoints;
	NSProgressIndicator		*_spinner;
}

- (id)initWithRange:(NSUInteger)range datapoints:(NSArray *)datapoints;

@property (nonatomic, assign) NSUInteger chartRange;
@property (nonatomic, retain) NSArray *datapoints;

@end
