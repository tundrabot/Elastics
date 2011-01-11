//
//  AppDelegate.m
//  ElasticPreferences
//
//  Created by Dmitri Goutnik on 26/12/2010.
//  Copyright 2010 Tundra Bot. All rights reserved.
//

#import "AppDelegate.h"
#import "Preferences.h"
#import "RefreshIntervalValueTransformer.h"
#import "RefreshIntervalLabelValueTransformer.h"
#import "KeychainController.h"

#define GENERAL_PANE_INDEX				0
#define ADVANCED_PANE_INDEX				1

#define PANE_SWITCH_ANIMATION_DURATION	0.25

@interface AppDelegate ()
- (void)schedulePreferenceChangeNotification;
- (void)postPreferenceChangeNotification;
- (void)userDefaultsDidChange:(NSNotification *)notification;
- (void)showPreferencePane:(NSUInteger)paneIndex animated:(BOOL)animated;
- (void)addContentSubview:(NSView *)view;
- (void)preferencesShouldTerminate:(NSNotification *)notification;
@end

@implementation AppDelegate

@synthesize window = _window;
@synthesize generalPane = _generalPane;
@synthesize advancedPane = _advancedPane;
@synthesize keychainController = _keychainController;
@synthesize awsAccessKeyIdField = _awsAccessKeyIdField;
@synthesize keypairFileField = _keypairFileField;
@synthesize aboutPanel = _aboutPanel;
@synthesize aboutVersionLabel = _aboutVersionLabel;
@synthesize aboutCopyrightLabel = _aboutCopyrightLabel;

+ (void)initialize
{
	RefreshIntervalValueTransformer *valueTransformer = [[[RefreshIntervalValueTransformer alloc] init] autorelease];
	RefreshIntervalLabelValueTransformer *labelValueTransformer = [[[RefreshIntervalLabelValueTransformer alloc] init] autorelease];
	
	[NSValueTransformer setValueTransformer:valueTransformer
									forName:@"RefreshIntervalValueTransformer"];
	[NSValueTransformer setValueTransformer:labelValueTransformer
									forName:@"RefreshIntervalLabelValueTransformer"];
	
	// register default preference values
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults registerDefaults:[userDefaults defaultElasticPreferences]];
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

	// center window on the first launch
	if (userDefaults.isFirstLaunch)
		[_window center];
	
	// show General pane on launch
	[self showPreferencePane:GENERAL_PANE_INDEX animated:NO];
	
	// if there's no AWS credentials, set focus to Access ID field
	if (![_keychainController.awsAccessKeyId length]) {
		[_window makeFirstResponder:_awsAccessKeyIdField];
	}
	
	// observe user defaults change notifications
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	[notificationCenter addObserver:self
						   selector:@selector(userDefaultsDidChange:)
							   name:NSUserDefaultsDidChangeNotification
							 object:nil];
	
	// observe KeychainController value changes
	[_keychainController addObserver:self
						  forKeyPath:@"awsAccessKeyId"
							 options:NSKeyValueObservingOptionNew
							 context:NULL];
	[_keychainController addObserver:self
						  forKeyPath:@"awsSecretAccessKey"
							 options:NSKeyValueObservingOptionNew
							 context:NULL];
	
	// observe termination notification from main app
	[[NSDistributedNotificationCenter defaultCenter] addObserver:self
														selector:@selector(preferencesShouldTerminate:)
															name:kPreferencesShouldTerminateNotification
														  object:nil];

	userDefaults.firstLaunch = NO;

	// show main window
	[_window makeKeyAndOrderFront:nil];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
	// unsubscribe from notifications
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[[NSDistributedNotificationCenter defaultCenter] removeObserver:self
															   name:kPreferencesShouldTerminateNotification
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
#pragma mark Preference data changes notifications

const NSTimeInterval kPreferenceChangeNotificationDelay = .5;

- (void)schedulePreferenceChangeNotification
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
	[_keychainController synchronize];
	
	[[NSDistributedNotificationCenter defaultCenter] postNotificationName:kPreferencesDidChangeNotification
																   object:nil];
}

- (void)userDefaultsDidChange:(NSNotification *)notification
{
	[self schedulePreferenceChangeNotification];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
					  ofObject:(id)object
						change:(NSDictionary *)change
					   context:(void *)context
{
	if (object == _keychainController)
		[self schedulePreferenceChangeNotification];
}

#pragma mark -
#pragma mark Main app notifications

- (void)preferencesShouldTerminate:(NSNotification *)notification
{
	[NSApp terminate:nil];
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

- (IBAction)chooseKeypairAction:(id)sender
{
	NSOpenPanel *panel = [NSOpenPanel openPanel];
	
	[panel setShowsHiddenFiles:YES];

	[panel beginSheetModalForWindow:_window
				  completionHandler:^(NSInteger result) {
					  if (result == NSOKButton) {
						  [[NSUserDefaults standardUserDefaults] setSshPrivateKeyFile:[[panel filenames] objectAtIndex:0]];
					  }
				  }];
}

- (void)aboutAction:(id)sender
{
	[_aboutPanel center];
	
	NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
	NSString *bundleShortVersionString = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
	NSString *version = [NSString stringWithFormat:NSLocalizedString(@"Version %@", nil), bundleShortVersionString];
	
	NSData *copyrightData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Credits" ofType:@"html"]];
	NSAttributedString *copyright = [[NSAttributedString alloc] initWithHTML:copyrightData documentAttributes:nil];
	
	[_aboutVersionLabel setStringValue:version];
	[_aboutCopyrightLabel setAttributedStringValue:copyright];
	[copyright release];
	
	[_aboutPanel makeKeyAndOrderFront:self];
}

@end
