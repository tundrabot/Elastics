//
//  ChartView.m
//  Cloudwatch
//
//  Created by Dmitri Goutnik on 23/12/2010.
//  Copyright 2010 Tundra Bot. All rights reserved.
//

#import "ChartView.h"
#import "MonitoringDatapoint.h"

#define WIDTH				180.f
#define HEIGHT				50.f
#define HORIZONTAL_PADDING	18.f
#define VERTICAL_PADDING	4.f

@interface ChartView ()
- (void)setChartRange:(NSUInteger)newChartRange;
- (void)setDatapoints:(NSArray *)newDatapoints;
- (void)showSpinner;
- (void)hideSpinner;
@end

@implementation ChartView

@synthesize chartRange = _chartRange;
@synthesize datapoints = _datapoints;

- (id)initWithRange:(NSUInteger)range datapoints:(NSArray *)datapoints
{
	NSRect frame = NSMakeRect(0.f, 0.f, WIDTH + HORIZONTAL_PADDING * 2.f, HEIGHT + VERTICAL_PADDING * 2.f);

    self = [super initWithFrame:frame];
    if (self) {
		
//		[self setWantsLayer:YES];
		
		NSRect spinnerFrame = NSMakeRect(NSMaxX(frame)/2.f - 8.f, NSMaxY(frame)/2.f - 9.f, 16.f, 16.f);
		_spinner = [[NSProgressIndicator alloc] initWithFrame:spinnerFrame];
		[_spinner setControlSize:NSSmallControlSize];
		[_spinner setUsesThreadedAnimation:YES];
//		[_spinner setAlphaValue:.5f];
		[_spinner setStyle:NSProgressIndicatorSpinningStyle];
		[_spinner setHidden:YES];
		[self addSubview:_spinner];
		
		[self setChartRange:range];
		[self setDatapoints:datapoints];
	}
	return self;
}

- (void)dealloc
{
	[_datapoints release];
	[_spinner release];
	[super dealloc];
}

- (void)setChartRange:(NSUInteger)newChartRange
{
	switch (newChartRange) {
		case TBChartRangeLastHour:
			_chartRange = newChartRange;
			_expectedDatapointCount = 60;
			break;
		case TBChartRangeLast3Hours:
		case TBChartRangeLast6Hours:
		case TBChartRangeLast12Hours:
		case TBChartRangeLast24Hours:
			_chartRange = newChartRange;
			_expectedDatapointCount = 180;
			break;
		default:
			NSAssert(FALSE, @"Unsupported chart range: %d", newChartRange);
	}
	
	[self setNeedsDisplay:YES];
}

- (void)setDatapoints:(NSArray *)newDatapoints
{
	[newDatapoints retain];
	[_datapoints release];
	_datapoints = newDatapoints;
	
	[self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)dirtyRect
{
	[self hideSpinner];
	
	[NSGraphicsContext saveGraphicsState]; {
		NSRect chartRect = NSInsetRect([self bounds], HORIZONTAL_PADDING, VERTICAL_PADDING);

		NSBezierPath *clipPath = [NSBezierPath bezierPathWithRect:NSInsetRect(chartRect, .5f, .5f)];
		[clipPath addClip];

		NSBezierPath *borderPath = [NSBezierPath bezierPathWithRect:NSInsetRect(chartRect, .5f, .5f)];
		[[NSColor colorWithDeviceWhite:.75f alpha:1.f] set];
		[borderPath stroke];
		
		NSGradient *backgroundGradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithDeviceWhite:.90f alpha:1.f]
															 endingColor:[NSColor colorWithDeviceWhite:.98f alpha:1.f]];
		[backgroundGradient drawInRect:chartRect angle:-90.f];
		[backgroundGradient release];
		
		if ([_datapoints count] > 0) {

			NSUInteger count = MIN([_datapoints count], _expectedDatapointCount);
			CGFloat xScale = chartRect.size.width / _expectedDatapointCount;
			CGFloat yScale = chartRect.size.height / 100.0;
			
			NSBezierPath *path = [NSBezierPath bezierPath];
			MonitoringDatapoint *datapoint = nil;
			
			datapoint = [_datapoints lastObject];
			[path moveToPoint:NSMakePoint(NSMaxX(chartRect), datapoint.maximum * yScale)];
			
			for (NSUInteger i = count - 2; i != 0; i--) {
				datapoint = [_datapoints objectAtIndex:i];
				CGFloat maximum = datapoint.maximum * yScale;
				[path lineToPoint:NSMakePoint((NSMaxX(chartRect) - (count - i) * xScale), maximum < 1.5f ? maximum + 1.5f : maximum)];
			}
			
			datapoint = [_datapoints objectAtIndex:0];
			[path lineToPoint:NSMakePoint((NSMaxX(chartRect) - count * xScale), datapoint.minimum * yScale)];
			
			for (NSUInteger i = 1; i < count; i++) {
				datapoint = [_datapoints objectAtIndex:i];
				CGFloat minimum = datapoint.minimum * yScale;
				[path lineToPoint:NSMakePoint((NSMaxX(chartRect) - (count - i) * xScale), minimum + .5f)];
			}

			NSGradient *chartGradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithDeviceRed:(87.f/255.f) green:(177.f/255.f) blue:(230.f/255.f) alpha:1.f]
																	  endingColor:[NSColor colorWithDeviceRed:(0.f/255.f) green:(112.f/255.f) blue:(180.f/255.f) alpha:1.f]];
			[chartGradient drawInBezierPath:path angle:-90.f];
			[chartGradient release];
		}
		else {
			[self showSpinner];
		}

	}
	[NSGraphicsContext restoreGraphicsState];
}

- (void)showSpinner
{
	[_spinner startAnimation:self];
	[_spinner setHidden:NO];
}

- (void)hideSpinner
{
	[_spinner stopAnimation:self];
	[_spinner setHidden:YES];
}

@end
