//
//  ChartView.m
//  Elastic
//
//  Created by Dmitri Goutnik on 23/12/2010.
//  Copyright 2010 Tundra Bot. All rights reserved.
//

#import "ChartView.h"
#import "AWSConstants.h"
#import "MonitoringDatapoint.h"

#define MIN_WIDTH				180.f
#define MIN_HEIGHT				60.f
#define PADDING_TOP				0.f
#define PADDING_RIGHT			17.f
#define PADDING_BOTTOM			3.f
#define PADDING_LEFT			17.f

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
	NSRect frame = NSMakeRect(0.f, 0.f,
							  MIN_WIDTH + PADDING_LEFT + PADDING_RIGHT,
							  MIN_HEIGHT + PADDING_TOP + PADDING_BOTTOM);

    self = [super initWithFrame:frame];
    if (self) {
		[self setAutoresizingMask:NSViewWidthSizable];
		[self setAutoresizesSubviews:YES];
		
		NSRect spinnerFrame = NSMakeRect(NSMidX(frame) - 8.f, NSMidY(frame) - 6.f, 16.f, 16.f);
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

- (BOOL)isOpaque
{
	return YES;
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
//	@try {

		[self hideSpinner];
	
		[NSGraphicsContext saveGraphicsState]; {
			
			NSSize menuSize = [[[self enclosingMenuItem] menu] size];
			NSRect chartRect = NSMakeRect(0, 0, menuSize.width, MIN_HEIGHT);
			chartRect = NSInsetRect(chartRect, PADDING_LEFT, 0);
			chartRect = NSInsetRect(chartRect, 0, PADDING_BOTTOM);
			chartRect = NSOffsetRect(chartRect, 0, PADDING_BOTTOM);
			
			NSBezierPath *clipPath = [NSBezierPath bezierPathWithRect:NSInsetRect(chartRect, .5f, .5f)];
			[clipPath addClip];
			
			NSBezierPath *borderPath = [NSBezierPath bezierPathWithRect:NSInsetRect(chartRect, .5f, .5f)];
			[[NSColor colorWithDeviceWhite:.75f alpha:1.f] set];
			[borderPath stroke];
			
			NSGradient *backgroundGradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithDeviceWhite:.90f alpha:1.f]
																		   endingColor:[NSColor colorWithDeviceWhite:.98f alpha:1.f]];
			[backgroundGradient drawInRect:chartRect angle:-90.f];
			[backgroundGradient release];
			
			if (_datapoints == nil) {
				// first refresh is in progress

				[self showSpinner];
			}
			else if ([_datapoints count] > 0) {
				// data is ready

				NSTimeInterval timestampMax = floor([[NSDate date] timeIntervalSinceReferenceDate]) - 60.0;
				NSTimeInterval timestampMin = timestampMax - _chartRange;
				CGFloat xScale = chartRect.size.width / (CGFloat)_chartRange;
				CGFloat yScale = (chartRect.size.height - 2.0f - .5f) / 100.f;
				
				NSBezierPath *path = [NSBezierPath bezierPath];
				[path setFlatness:0.1f];
				[path setLineJoinStyle:NSRoundLineJoinStyle];
				MonitoringDatapoint *datapoint = [_datapoints lastObject];
				
				//TBTrace(@"count: %d", [_datapoints count]);
				if ([datapoint timestamp] > timestampMin) {
					CGFloat x, y;
					NSUInteger i;
				
					x = (CGFloat)(NSMinX(chartRect) + ([datapoint timestamp] - timestampMin) * xScale);
					y = ROUND_5(NSMinY(chartRect) + datapoint.maximum * yScale) + 1.5f;
					[path moveToPoint:NSMakePoint(x, y)];
					//TBTrace(@"x: %.1f, y: %.1f", x, y);
				
					for (i = [_datapoints count] - 2; (NSInteger)i >= 0; i--) {
						datapoint = [_datapoints objectAtIndex:i];
						x = (CGFloat)(NSMinX(chartRect) + ([datapoint timestamp] - timestampMin) * xScale);
						y = ROUND_5(NSMinY(chartRect) + datapoint.maximum * yScale) + 1.5f;
						[path lineToPoint:NSMakePoint(x, y)];
						//TBTrace(@"x: %.1f, y: %.1f", x, y);
					}
					
					//TBTrace(@"i: %d", i);

					for (i = 0; i < [_datapoints count]; i++) {
						datapoint = [_datapoints objectAtIndex:i];
						x = (CGFloat)(NSMinX(chartRect) + ([datapoint timestamp] - timestampMin) * xScale);
						y = ROUND_5(NSMinY(chartRect) + datapoint.minimum * yScale) + .5f;
						[path lineToPoint:NSMakePoint(x, y)];
						//TBTrace(@"x: %.1f, y: %.1f", x, y);
					}

					//TBTrace(@"i: %d", i);

					[path closePath];
					
					NSColor *startingColor = [NSColor colorWithDeviceRed:(35.f/255.f) green:(120.f/255.f) blue:(200.f/255.f) alpha:1.f];
					NSColor *endingColor = [NSColor colorWithDeviceRed:(0.f/255.f) green:(112.f/255.f) blue:(180.f/255.f) alpha:1.f];

					[endingColor set];
					[path setLineWidth:.5f];
					[path stroke];
					
					[path setClip];
					NSGradient *chartGradient = [[NSGradient alloc] initWithStartingColor:startingColor
																			  endingColor:endingColor];
					[chartGradient drawInBezierPath:clipPath angle:-90.f];
					[chartGradient release];
					
//					[[NSColor colorWithDeviceRed:(0.f/255.f) green:(112.f/255.f) blue:(180.f/255.f) alpha:1.f] set];
//					[path fill];
				}
			}
		}
		[NSGraphicsContext restoreGraphicsState];
//	}
//	@catch (NSException *e) {
//		NSLog(@"%@", e);
//	}
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
