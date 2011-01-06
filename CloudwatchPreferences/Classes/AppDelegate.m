//
//  AppDelegate.m
//  CloudwatchPreferences
//
//  Created by Dmitri Goutnik on 26/12/2010.
//  Copyright 2010 Tundra Bot. All rights reserved.
//

#import "AppDelegate.h"
#import "Preferences.h"
#import "RefreshIntervalValueTransformer.h"
#import "RefreshIntervalLabelValueTransformer.h"

#define GENERAL_PANE_INDEX				0
#define ADVANCED_PANE_INDEX				1

#define PANE_SWITCH_ANIMATION_DURATION	0.25

@interface AppDelegate ()
- (void)userDefaultsDidChange:(NSNotification *)notification;
- (void)postPreferenceChangeNotification;
- (void)showPreferencePane:(NSUInteger)paneIndex animated:(BOOL)animated;
- (void)addContentSubview:(NSView *)view;
@end

@implementation AppDelegate

@synthesize window = _window;
@synthesize generalPane = _generalPane;
@synthesize advancedPane = _advancedPane;
@synthesize awsAccessKeyIdField = _awsAccessKeyIdField;

+ (void)initialize
{
	RefreshIntervalValueTransformer *valueTransformer = [[[RefreshIntervalValueTransformer alloc] init] autorelease];
	RefreshIntervalLabelValueTransformer *labelValueTransformer = [[[RefreshIntervalLabelValueTransformer alloc] init] autorelease];
	
	[NSValueTransformer setValueTransformer:valueTransformer
									forName:@"RefreshIntervalValueTransformer"];
	[NSValueTransformer setValueTransformer:labelValueTransformer
									forName:@"RefreshIntervalLabelValueTransformer"];
	
	// register default preference values
	NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
	[ud registerDefaults:[ud defaultCloudwatchPreferences]];
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
	// show General pane on launch
	[self showPreferencePane:GENERAL_PANE_INDEX animated:NO];
	
	// if there's no AWS credentials, set focus to Access ID field
	if (![[[NSUserDefaults standardUserDefaults] awsAccessKeyId] length]) {
		[_window makeFirstResponder:_awsAccessKeyIdField];
	}
	
	// subscribe to preference values change notifications
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	[notificationCenter addObserver:self
						   selector:@selector(userDefaultsDidChange:)
							   name:NSUserDefaultsDidChangeNotification
							 object:nil];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
	return YES;
}

- (void)showPreferencePane:(NSUInteger)paneIndex animated:(BOOL)animated
{
	NSView *pane = nil;
	switch (paneIndex) {
		case GENERAL_PANE_INDEX:
			pane = _generalPane;
			break;
		case ADVANCED_PANE_INDEX:
			pane = _advancedPane;
			break;
	}
	if (pane) {
		NSView *contentView = [_window contentView];
		NSView *currentPane = [[contentView subviews] count] ? [[contentView subviews] objectAtIndex:0] : nil;
		if (pane != currentPane) {
			// cancel all pending 'show pane' requests
			[NSObject cancelPreviousPerformRequestsWithTarget:self];
			
			// make toolbar button selected
			NSToolbar *toolbar = [_window toolbar];
			NSToolbarItem *toolbarItem = [[toolbar items] objectAtIndex:paneIndex];
			[toolbar setSelectedItemIdentifier:[toolbarItem itemIdentifier]];
			
			// calculate new window frame
			NSRect contentBounds = [contentView bounds];
			NSRect paneBounds = [pane bounds];
			NSRect currentWindowFrame = [_window frame];
			NSRect newWindowFrame = NSMakeRect(currentWindowFrame.origin.x,
											   currentWindowFrame.origin.y - (paneBounds.size.height - contentBounds.size.height),
											   currentWindowFrame.size.width + (paneBounds.size.width - contentBounds.size.width),
											   currentWindowFrame.size.height + (paneBounds.size.height - contentBounds.size.height));
			
			// resize window and replace panes
			[currentPane removeFromSuperview];
			if (animated) {
				[NSAnimationContext beginGrouping]; {
					[[NSAnimationContext currentContext] setDuration:PANE_SWITCH_ANIMATION_DURATION];
					[[_window animator] setFrame:newWindowFrame display:YES];
				} [NSAnimationContext endGrouping];
				[self performSelector:@selector(addContentSubview:) withObject:pane afterDelay:PANE_SWITCH_ANIMATION_DURATION + 0.05];
			}
			else {
				[_window setFrame:newWindowFrame display:YES];
				[self addContentSubview:pane];
			}
		}
	}
}

- (void)addContentSubview:(NSView *)view
{
	NSView *contentView = [_window contentView];
	[view setFrameOrigin:NSMakePoint(0.f, 0.f)];
	[contentView addSubview:view];
}

#pragma mark -
#pragma mark Toolbar delegate

- (NSArray *)toolbarSelectableItemIdentifiers:(NSToolbar *)toolbar
{
	NSMutableArray *selectableItemIdentifiers = [NSMutableArray array];
	
	for (NSToolbarItem *item in [toolbar items]) {
		[selectableItemIdentifiers addObject:[item itemIdentifier]];
	}
	
	return selectableItemIdentifiers;
}

#pragma mark -
#pragma mark Window delegate

- (void)windowWillClose:(NSNotification *)notification
{
	[_window makeFirstResponder:[_window contentView]];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark -
#pragma mark User Defaults notification

const NSTimeInterval kPreferenceChangeNotificationDelay = .5;

- (void)userDefaultsDidChange:(NSNotification *)notification
{
	[[self class] cancelPreviousPerformRequestsWithTarget:self
												 selector:@selector(postPreferenceChangeNotification)
												   object:nil];
	[self performSelector:@selector(postPreferenceChangeNotification)
			   withObject:nil
			   afterDelay:kPreferenceChangeNotificationDelay];
}

- (void)postPreferenceChangeNotification
{
	[[NSUserDefaults standardUserDefaults] synchronize];
	[[NSDistributedNotificationCenter defaultCenter] postNotificationName:kPreferencesDidChangeNotification
																   object:nil];
}

#pragma mark -
#pragma mark Actions

- (IBAction)showGeneralPaneAction:(id)sender
{
	[self showPreferencePane:GENERAL_PANE_INDEX animated:YES];
}

- (IBAction)showAdvancedPaneAction:(id)sender
{
	[self showPreferencePane:ADVANCED_PANE_INDEX animated:YES];
}

@end
