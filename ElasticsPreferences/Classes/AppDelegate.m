//
//  AppDelegate.m
//  ElasticsPreferences
//
//  Created by Dmitri Goutnik on 26/12/2010.
//  Copyright 2010 Tundra Bot. All rights reserved.
//

#import "AppDelegate.h"
#import "Preferences.h"
#import "RefreshIntervalValueTransformer.h"
#import "RefreshIntervalLabelValueTransformer.h"
#import "Account.h"

#define GENERAL_PANE_INDEX				0
#define ADVANCED_PANE_INDEX				1

#define PANE_SWITCH_ANIMATION_DURATION	0.25

@interface AppDelegate ()
- (void)schedulePreferenceChangeNotification;
- (void)postPreferenceChangeNotification;
- (void)userDefaultsDidChange:(NSNotification *)notification;
- (void)accountDidChange:(NSNotification *)notification;
- (void)showPreferencePane:(NSUInteger)paneIndex animated:(BOOL)animated;
- (void)addContentSubview:(NSView *)view;
- (void)preferencesShouldTerminate:(NSNotification *)notification;
@end

@implementation AppDelegate

@synthesize window = _window;
@synthesize generalPane = _generalPane;
@synthesize advancedPane = _advancedPane;
@synthesize accountsManager = _accountsManager;
@synthesize accountsController = _accountsController;
@synthesize accountsTableView = _accountsTableView;
@synthesize keypairFileField = _keypairFileField;
@synthesize aboutPanel = _aboutPanel;
@synthesize aboutVersionLabel = _aboutVersionLabel;
@synthesize aboutCopyrightLabel = _aboutCopyrightLabel;
@synthesize accountPanel = _accountPanel;
@synthesize accountPanelSaveButton = _accountPanelSaveButton;
@synthesize accountPanelNameField = _accountPanelNameField;
@synthesize accountPanelAccessKeyIdField = _accountPanelAccessKeyIdField;
@synthesize accountPanelSecretAccessKeyField = _accountPanelSecretAccessKeyField;

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
	[userDefaults registerDefaults:[userDefaults defaultElasticsPreferences]];
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

	// center window on the first launch
	if (userDefaults.isFirstLaunch)
		[_window center];
	
	// show General pane on launch
	[_accountsTableView setTarget:self];
	[_accountsTableView	setDoubleAction:@selector(editAccountAction:)];
	[self showPreferencePane:GENERAL_PANE_INDEX animated:NO];
	
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];

	// observe user defaults change notifications
	[notificationCenter addObserver:self
						   selector:@selector(userDefaultsDidChange:)
							   name:NSUserDefaultsDidChangeNotification
							 object:nil];

	// observe accounts change notifications
	[notificationCenter addObserver:self
						   selector:@selector(accountDidChange:)
							   name:kAccountDidChangeNotification
							 object:nil];
	
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


#pragma mark - Toolbar delegate

- (NSArray *)toolbarSelectableItemIdentifiers:(NSToolbar *)toolbar
{
	NSMutableArray *selectableItemIdentifiers = [NSMutableArray array];
	
	for (NSToolbarItem *item in [toolbar items]) {
		[selectableItemIdentifiers addObject:[item itemIdentifier]];
	}
	
	return selectableItemIdentifiers;
}


#pragma mark - Window delegate

- (void)windowWillClose:(NSNotification *)notification
{
	[_window makeFirstResponder:[_window contentView]];
	[[NSUserDefaults standardUserDefaults] synchronize];
}


#pragma mark - Preference data changes notifications

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
//	[_keychainController saveAccounts];
	
	[[NSDistributedNotificationCenter defaultCenter] postNotificationName:kPreferencesDidChangeNotification
                                                                   object:nil
                                                                 userInfo:nil
                                                       deliverImmediately:YES];
}

- (void)userDefaultsDidChange:(NSNotification *)notification
{
	[self schedulePreferenceChangeNotification];
}

- (void)accountDidChange:(NSNotification *)notification
{
	[self schedulePreferenceChangeNotification];
}


#pragma mark - Main app notifications

- (void)preferencesShouldTerminate:(NSNotification *)notification
{
	[NSApp terminate:nil];
}


#pragma mark -
#pragma mark Account sheet

#define ACCOUNT_SHEET_RETURNCODE_SAVE		1
#define ACCOUNT_SHEET_RETURNCODE_CANCEL		0

enum {
	kAccountActionAddAccount = 1000,
	kAccountActionEditAccount,
};

- (NSString *)_accountPanelNameValue
{
	return [[_accountPanelNameField stringValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (NSString *)_accountPanelAccessKeyIDValue
{
	return [[_accountPanelAccessKeyIdField stringValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (NSString *)_accountPanelSecretAccessKeyValue
{
	return [[_accountPanelSecretAccessKeyField stringValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (IBAction)accountSheetSaveAction:(id)sender
{
	[NSApp endSheet:_accountPanel returnCode:ACCOUNT_SHEET_RETURNCODE_SAVE];
}

- (IBAction)accountSheetCancelAction:(id)sender
{
	[NSApp endSheet:_accountPanel returnCode:ACCOUNT_SHEET_RETURNCODE_CANCEL];
}

- (void)accountSheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
	[_accountPanel orderOut:self];
	
	if (returnCode == ACCOUNT_SHEET_RETURNCODE_SAVE) {
		switch (_accountActionType) {
			case kAccountActionAddAccount: {
				[_accountsManager addAccountWithName:[self _accountPanelNameValue] accessKeyId:[self _accountPanelAccessKeyIDValue] secretAccessKey:[self _accountPanelSecretAccessKeyValue]];
				break;
			}
				
			case kAccountActionEditAccount: {
				NSUInteger selectionIndex = [_accountsController selectionIndex];

				if (selectionIndex != NSNotFound) {
					Account *account = [[_accountsManager accounts] objectAtIndex:selectionIndex];
					account.name = [self _accountPanelNameValue];
					account.accessKeyID = [self _accountPanelAccessKeyIDValue];
					account.secretAccessKey = [self _accountPanelSecretAccessKeyValue];
					[account save];
				}
				break;
			}
		}
	}
}

- (void)controlTextDidChange:(NSNotification *)notification
{
	id obj = [notification object];
	
	if (obj == _accountPanelAccessKeyIdField || obj == _accountPanelSecretAccessKeyField) {
		BOOL canSave = [[self _accountPanelAccessKeyIDValue] length] > 0 && [[self _accountPanelSecretAccessKeyValue] length] > 0;
		[_accountPanelSaveButton setEnabled:canSave];
	}
}

- (IBAction)addAccountAction:(id)sender
{
	_accountActionType = kAccountActionAddAccount;
	[_accountPanelAccessKeyIdField setStringValue:@""];
	[_accountPanelSecretAccessKeyField setStringValue:@""];
	[_accountPanelNameField setStringValue:@""];
	[_accountPanelSaveButton setEnabled:NO];
	[_accountPanel makeFirstResponder:_accountPanelAccessKeyIdField];
	
	[NSApp beginSheet:_accountPanel
	   modalForWindow:[NSApp mainWindow]
		modalDelegate:self
	   didEndSelector:@selector(accountSheetDidEnd:returnCode:contextInfo:)
		  contextInfo:NULL];
}

- (IBAction)editAccountAction:(id)sender
{
	if ([sender isKindOfClass:[NSTableView class]] && [_accountsTableView clickedRow] < 0)
		return;		// clicked on a header row
		
	Account *account = [[_accountsController selectedObjects] objectAtIndex:0];
	if (account) {
	
		_accountActionType = kAccountActionEditAccount;
		
		[_accountPanelAccessKeyIdField setStringValue:account.accessKeyID];
		[_accountPanelSecretAccessKeyField setStringValue:account.secretAccessKey];
		[_accountPanelNameField setStringValue:account.name];
		[_accountPanelSaveButton setEnabled:YES];
		[_accountPanel makeFirstResponder:_accountPanelAccessKeyIdField];
		
		[NSApp beginSheet:_accountPanel
		   modalForWindow:[NSApp mainWindow]
			modalDelegate:self
		   didEndSelector:@selector(accountSheetDidEnd:returnCode:contextInfo:)
			  contextInfo:NULL];
	}
}

- (void)removeAccountAlertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
	[[alert window] orderOut:nil];
	
	if (returnCode == 0) {
		[_accountsManager removeAccountAtIndex:[_accountsController selectionIndex]];
	}
}

- (IBAction)removeAccountAction:(id)sender
{
	Account *account = [[_accountsController selectedObjects] objectAtIndex:0];
	
	NSAlert *alert = [NSAlert alertWithMessageText:[NSString stringWithFormat:@"Remove account \"%@\"?", account.title]
									 defaultButton:@"Cancel"
								   alternateButton:@"Remove"
									   otherButton:nil
						 informativeTextWithFormat:@""];
	
	[alert beginSheetModalForWindow:[NSApp mainWindow]
					  modalDelegate:self
					 didEndSelector:@selector(removeAccountAlertDidEnd:returnCode:contextInfo:)
						contextInfo:nil];
}


#pragma mark - Actions

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
                          NSString *filename = [[[panel URLs] objectAtIndex:0] path];
//						  [[NSUserDefaults standardUserDefaults] setSshPrivateKeyFile:[[panel filenames] objectAtIndex:0]];
                          [[NSUserDefaults standardUserDefaults] setSshPrivateKeyFile:filename];
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
