//
//  AppDelegate.m
//  CloudwatchPreferences
//
//  Created by Dmitri Goutnik on 26/12/2010.
//  Copyright 2010 Invisible Llama. All rights reserved.
//

#import "AppDelegate.h"

#define GENERAL_PANE_INDEX				0
#define ADVANCED_PANE_INDEX				1

#define PANE_SWITCH_ANIMATION_DURATION	0.25

// AES128 key (16 bytes)                                                                                                                 
static const char kAWSCredentialsKey[16] = {
	0xfb, 0xb2, 0xd1, 0x9c,
	0xfa, 0x41, 0xf7, 0x9e,
	0xbb, 0xd8, 0x08, 0xc3,
	0xb5, 0xb3, 0xe3, 0xbe
};

@interface AppDelegate ()
- (void)showPreferencePane:(NSUInteger)paneIndex animated:(BOOL)animated;
- (void)addContentSubview:(NSView *)view;
@end

@implementation AppDelegate

@synthesize window = _window;
@synthesize generalPane = _generalPane;
@synthesize advancedPane = _advancedPane;

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
	[self showPreferencePane:GENERAL_PANE_INDEX animated:NO];
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
			// Cancel all pending 'show pane' requests
			[NSObject cancelPreviousPerformRequestsWithTarget:self];
			
			// Make toolbar button selected
			NSToolbar *toolbar = [_window toolbar];
			NSToolbarItem *toolbarItem = [[toolbar items] objectAtIndex:paneIndex];
			[toolbar setSelectedItemIdentifier:[toolbarItem itemIdentifier]];
			
			// Calculate new window frame
			NSRect contentBounds = [contentView bounds];
			NSRect paneBounds = [pane bounds];
			NSRect currentWindowFrame = [_window frame];
			NSRect newWindowFrame = NSMakeRect(currentWindowFrame.origin.x,
											   currentWindowFrame.origin.y - (paneBounds.size.height - contentBounds.size.height),
											   currentWindowFrame.size.width + (paneBounds.size.width - contentBounds.size.width),
											   currentWindowFrame.size.height + (paneBounds.size.height - contentBounds.size.height));
			
			// Resize window and replace panes
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
	[view setFrameOrigin:NSMakePoint(0.0, 0.0)];
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
