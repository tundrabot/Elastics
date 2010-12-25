//
//  ChartView.m
//  Cloudwatch
//
//  Created by Dmitri Goutnik on 23/12/2010.
//  Copyright 2010 Tundra Bot. All rights reserved.
//

#import "ChartView.h"
#import "AWSConstants.h"
#import "MonitoringDatapoint.h"

#define MIN_WIDTH				180.f
#define MIN_HEIGHT				50.f
#define HORIZONTAL_PADDING		18.f
#define VERTICAL_PADDING		4.f

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
	NSRect frame = NSMakeRect(0.f, 0.f, MIN_WIDTH + HORIZONTAL_PADDING * 2.f, MIN_HEIGHT + VERTICAL_PADDING * 2.f);

    self = [super initWithFrame:frame];
    if (self) {
		[self setAutoresizingMask:NSViewWidthSizable];
		[self setAutoresizesSubviews:YES];
		
		NSRect spinnerFrame = NSMakeRect(NSMidX(frame) - 8.f, NSMidY(frame) - 12.5f, 16.f, 16.f);
		_spinner = [[NSProgressIndicator alloc] initWithFrame:spinnerFrame];
		[_spinner setControlSize:NSSmallControlSize];
		[_spinner setAutoresizingMask:(NSViewMinXMargin | NSViewMaxXMargin | NSViewMinYMargin | NSViewMaxYMargin)];
		[_spinner setUsesThreadedAnimation:YES];
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
	NSParameterAssert(newChartRange >= kAWSLastHourRange && newChartRange <= kAWSLast24HoursRange);
	_chartRange = newChartRange;

	[self setNeedsDisplay:YES];
}

- (void)setDatapoints:(NSArray *)newDatapoints
{
	if (_datapoints != newDatapoints) {
		[_datapoints release];
		_datapoints = [newDatapoints retain];
	}
	
	[self setNeedsDisplay:YES];
}

//#define ROUND_5(x) (round((x)*2.0)/2.0)
#define ROUND_5(x) (x)

- (void)drawRect:(NSRect)dirtyRect
{
	[self hideSpinner];
	
	[NSGraphicsContext saveGraphicsState]; {
		
		NSSize menuSize = [[[self enclosingMenuItem] menu] size];
		NSRect chartRect = NSMakeRect(0, 0, menuSize.width, MIN_HEIGHT);
		chartRect = NSInsetRect(chartRect, HORIZONTAL_PADDING, 0);
		
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

			NSTimeInterval timestampMax = floor([[NSDate date] timeIntervalSinceReferenceDate]) - 60.0;
			NSTimeInterval timestampMin = timestampMax - _chartRange;
			CGFloat xScale = chartRect.size.width / (CGFloat)_chartRange;
			CGFloat yScale = chartRect.size.height / 100.0;
			
			NSBezierPath *path = [NSBezierPath bezierPath];
			[path setFlatness:0.1];
			[path setLineJoinStyle:NSRoundLineJoinStyle];
			MonitoringDatapoint *datapoint = [_datapoints lastObject];
			
			if ([datapoint timestamp] > timestampMin) {
				CGFloat x, y;
			
				x = NSMinX(chartRect) + ([datapoint timestamp] - timestampMin) * xScale;
				y = ROUND_5(NSMinY(chartRect) + datapoint.maximum * yScale) + 1.5f;
				[path moveToPoint:NSMakePoint(x, y)];
			
				for (NSUInteger i = [_datapoints count] - 2; i != 0; i--) {
					datapoint = [_datapoints objectAtIndex:i];
					x = NSMinX(chartRect) + ([datapoint timestamp] - timestampMin) * xScale;
					y = ROUND_5(NSMinY(chartRect) + datapoint.maximum * yScale) + 1.5f;
					[path lineToPoint:NSMakePoint(x, y)];
				}
			
				datapoint = [_datapoints objectAtIndex:0];
				x = NSMinX(chartRect) + ([datapoint timestamp] - timestampMin) * xScale;
				y = ROUND_5(NSMinY(chartRect) + datapoint.minimum * yScale) + .5f;
				[path lineToPoint:NSMakePoint(x, y)];
			
				for (NSUInteger i = 1; i < [_datapoints count]; i++) {
					datapoint = [_datapoints objectAtIndex:i];
					x = NSMinX(chartRect) + ([datapoint timestamp] - timestampMin) * xScale;
					y = ROUND_5(NSMinY(chartRect) + datapoint.minimum * yScale) + .5f;
					[path lineToPoint:NSMakePoint(x, y)];
				}
				
				[path closePath];
				
//				[[NSGraphicsContext currentContext] setShouldAntialias:NO];

				[path setClip];
				NSGradient *chartGradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithDeviceRed:(118.f/255.f) green:(186.f/255.f) blue:(250.f/255.f) alpha:1.f]
																		  endingColor:[NSColor colorWithDeviceRed:(0.f/255.f) green:(112.f/255.f) blue:(180.f/255.f) alpha:1.f]];
				[chartGradient drawInBezierPath:clipPath angle:-90.f];
				[chartGradient release];
				
//				[[NSColor colorWithDeviceRed:(0.f/255.f) green:(112.f/255.f) blue:(180.f/255.f) alpha:1.f] set];
//				[path fill];
			}
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
