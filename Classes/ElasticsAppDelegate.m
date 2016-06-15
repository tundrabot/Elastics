//
//  ElasticsAppDelegate.m
//  Elastics
//
//  Created by Dmitri Goutnik on 21/12/2010.
//  Copyright 2010 Tundra Bot. All rights reserved.
//

#import "ElasticsAppDelegate.h"
#import "DataSource.h"
#import "ChartView.h"
#import "Preferences.h"
#import "AccountsManager.h"
#import "ValidateReceipt.h"
#import "Constants.h"

//const CGFloat kActionItemTableWidth             = 180.;
const CGFloat kActionItemLabelColumnWidth       = 170.;

const CGFloat kInstanceInfoTableWidth           = 230.;
const CGFloat kInstanceInfoLabelColumnWidth     = 100.;

const CGFloat kMessageTableWidth                = 180.;

static NSString *const kElasticsPreferencesApplicationPath	= @"Contents/Helpers/Elastics Preferences.app";
static NSString *const kElasticsPreferencesSuite			= @"com.tundrabot.Elastics-Preferences";

@interface ElasticsAppDelegate ()

- (void)resetMenu;
- (void)addMenuActionItems;
- (void)refreshMenu:(NSNotification *)notification;

- (NSMenuItem *)titleItemWithTitle:(NSString *)title;
- (NSMenuItem *)messageItemWithTitle:(NSString *)title image:(NSImage *)image;
- (NSMenuItem *)progressMessageItemWithTitle:(NSString *)title;
- (NSMenuItem *)errorMessageItemWithTitle:(NSString *)title;
- (NSMenuItem *)notificationMessageItemWithTitle:(NSString *)title;
- (NSMenuItem *)instanceItemWithInstance:(EC2Instance *)instance;
- (NSMenuItem *)regionItemWithRegion:(NSString *)awsRegion info:(NSString *)info;
- (NSMenuItem *)chartItemWithRange:(NSUInteger)range datapoints:(NSArray *)datapoints;
- (NSMenuItem *)infoItemWithLabel:(NSString *)label info:(NSString *)info action:(SEL)action tooltip:(NSString *)tooltip;
- (NSMenuItem *)actionItemWithLabel:(NSString *)label info:(NSString *)info action:(SEL)action;
- (NSMenuItem *)dummyItem;

- (NSMenu *)submenuForInstance:(EC2Instance *)instance;
- (void)refreshSubmenu:(NSMenu *)menu forInstance:(EC2Instance *)instance;

- (BOOL)refresh;
- (BOOL)refreshIgnoringAge;
- (BOOL)refresh:(NSString *)instanceId;
- (void)refreshCompleted:(NSNotification *)notification;

- (void)loadPreferences;
- (void)setupDataSource;
- (void)preferencesDidChange:(NSNotification *)notification;

- (void)enableRefreshTimer;
- (void)disableRefreshTimer;
- (void)timerRefresh:(NSTimer *)timer;

- (void)workspaceSessionDidBecomeActive:(NSNotification *)notification;
- (void)workspaceSessionDidResignActive:(NSNotification *)notification;
- (void)workspaceDidWake:(NSNotification *)notification;

- (void)nopAction:(id)sender;
- (void)selectAccountAction:(id)sender;
- (void)selectRegionAction:(id)sender;
- (void)refreshAction:(id)sender;
- (void)quitAction:(id)sender;
- (void)editPreferencesAction:(id)sender;
- (void)copyToPasteboardAction:(id)sender;
- (void)connectToInstanceWithSshAction:(id)sender;
- (void)connectToInstanceWithRdpAction:(id)sender;
- (void)aboutAction:(id)sender;
- (void)openAWSManagementConsoleAction:(id)sender;

@end

@implementation ElasticsAppDelegate

@synthesize aboutPanel = _aboutPanel;
@synthesize aboutVersionLabel = _aboutVersionLabel;
@synthesize aboutCopyrightLabel = _aboutCopyrightLabel;

static NSColor *_titleColor;
static NSColor *_taggedInstanceColor;
static NSColor *_untaggedInstanceColor;
static NSColor *_actionItemColor;
static NSColor *_messageItemColor;
static NSColor *_labelColumnColor;
static NSColor *_infoColumnColor;

static NSFont *_statusItemFont;

static NSFont *_titleFont;
static NSFont *_taggedInstanceFont;
static NSFont *_untaggedInstanceFont;
static NSFont *_actionItemFont;
static NSFont *_messageItemFont;
static NSFont *_labelColumnFont;
static NSFont *_infoColumnFont;

static NSDictionary *_statusItemAttributes;

static NSDictionary *_titleAttributes;
static NSDictionary *_taggedInstanceAttributes;
static NSDictionary *_untaggedInstanceAttributes;
static NSDictionary *_actionItemAttributes;
static NSDictionary *_messageItemAttributes;
static NSDictionary *_labelColumnAttributes;
static NSDictionary *_infoColumnAttributes;

static NSImage *_statusItemImage;
static NSImage *_statusItemAlertImage;

static NSImage *_usImage;
static NSImage *_euImage;
static NSImage *_sgImage;
static NSImage *_jpImage;
static NSImage *_brImage;

#pragma mark - Initialization

+ (void)initialize
{
	TB_VALIDATE_EXPIRATION_DATE();
	TB_VALIDATE_RECEIPT();
	
	if (!_titleColor)               _titleColor = [[NSColor colorWithDeviceRed:(0.f/255.f) green:(112.f/255.f) blue:(180.f/255.f) alpha:1.f] retain];
	if (!_taggedInstanceColor)      _taggedInstanceColor = [[NSColor blackColor] retain];
	if (!_untaggedInstanceColor)	_untaggedInstanceColor = [[NSColor blackColor] retain];
	if (!_actionItemColor)			_actionItemColor = [[NSColor blackColor] retain];
	if (!_messageItemColor)			_messageItemColor = [[NSColor colorWithDeviceRed:(0.f/255.f) green:(0.f/255.f) blue:(0.f/255.f) alpha:0.70f] retain];
	if (!_labelColumnColor)			_labelColumnColor = [[NSColor blackColor] retain];
	if (!_infoColumnColor)			_infoColumnColor = [[NSColor blackColor] retain];

	if (!_statusItemFont)			_statusItemFont = [[NSFont systemFontOfSize:13.0f] retain];
	
	if (!_titleFont)				_titleFont = [[NSFont boldSystemFontOfSize:10.0f] retain];
	if (!_taggedInstanceFont)		_taggedInstanceFont = [[NSFont boldSystemFontOfSize:13.0f] retain];
	if (!_untaggedInstanceFont)		_untaggedInstanceFont = [[NSFont systemFontOfSize:13.0f] retain];
	if (!_actionItemFont)			_actionItemFont = [[NSFont boldSystemFontOfSize:11.0f] retain];
	if (!_messageItemFont)			_messageItemFont = [[NSFont boldSystemFontOfSize:11.0f] retain];
	if (!_labelColumnFont)			_labelColumnFont = [[NSFont systemFontOfSize:11.0f] retain];
	if (!_infoColumnFont)			_infoColumnFont = [[NSFont boldSystemFontOfSize:11.0f] retain];

	if (!_statusItemAttributes)
		_statusItemAttributes = [[NSDictionary dictionaryWithObjectsAndKeys:
								  _statusItemFont, NSFontAttributeName,
								  nil] retain];
	if (!_titleAttributes)
		_titleAttributes = [[NSDictionary dictionaryWithObjectsAndKeys:
							 _titleColor, NSForegroundColorAttributeName,
							 _titleFont, NSFontAttributeName,
							 [NSNumber numberWithFloat:8.f], NSBaselineOffsetAttributeName,
							 nil] retain];

	if (!_taggedInstanceAttributes)
		_taggedInstanceAttributes = [[NSDictionary dictionaryWithObjectsAndKeys:
									  _taggedInstanceColor, NSForegroundColorAttributeName,
									  _taggedInstanceFont, NSFontAttributeName,
									  nil] retain];

	if (!_taggedInstanceAttributes)
		_untaggedInstanceAttributes = [[NSDictionary dictionaryWithObjectsAndKeys:
										_untaggedInstanceColor, NSForegroundColorAttributeName,
										_untaggedInstanceFont, NSFontAttributeName,
										nil] retain];

	if (!_actionItemAttributes)
		_actionItemAttributes = [[NSDictionary dictionaryWithObjectsAndKeys:
								  _actionItemColor, NSForegroundColorAttributeName,
								  _actionItemFont, NSFontAttributeName,
								  nil] retain];

	if (!_messageItemAttributes)
		_messageItemAttributes = [[NSDictionary dictionaryWithObjectsAndKeys:
								   _messageItemColor, NSForegroundColorAttributeName,
								   _messageItemFont, NSFontAttributeName,
								   nil] retain];

	if (!_labelColumnAttributes)
		_labelColumnAttributes = [[NSDictionary dictionaryWithObjectsAndKeys:
								   _labelColumnColor, NSForegroundColorAttributeName,
								   _labelColumnFont, NSFontAttributeName,
								   //labelParagraphStyle, NSParagraphStyleAttributeName,
								   nil] retain];
	if (!_infoColumnAttributes)
		_infoColumnAttributes = [[NSDictionary dictionaryWithObjectsAndKeys:
								  _infoColumnColor, NSForegroundColorAttributeName,
								  _infoColumnFont, NSFontAttributeName,
								  //infoParagraphStyle, NSParagraphStyleAttributeName,
								  nil] retain];
	
	if (!_statusItemImage)		    _statusItemImage = [NSImage imageNamed:@"StatusItem"];
	if (!_statusItemAlertImage)	    _statusItemAlertImage = [NSImage imageNamed:@"StatusItemAlert"];
	
	if (!_usImage)	                _usImage = [NSImage imageNamed:@"US"];
	if (!_euImage)	                _euImage = [NSImage imageNamed:@"EU"];
	if (!_sgImage)	                _sgImage = [NSImage imageNamed:@"SG"];
	if (!_jpImage)	                _jpImage = [NSImage imageNamed:@"JP"];
	if (!_brImage)	                _brImage = [NSImage imageNamed:@"BR"];
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
	// register preferences set through Preferences helper app and defaults
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults addSuiteNamed:kElasticsPreferencesSuite];
	[userDefaults registerDefaults:[userDefaults defaultElasticsPreferences]];

	// load accounts
	_accountsManager = [[AccountsManager alloc] init];
	
	// load current preferences
	[self loadPreferences];

	// set up status item menu
	_statusMenu = [[NSMenu alloc] initWithTitle:@""];
	[_statusMenu setAutoenablesItems:NO];
//	[_statusMenu setShowsStateColumn:NO];
	[_statusMenu setDelegate:self];
	[self resetMenu];

	// set up status item
	_statusItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength] retain];
	[_statusItem setImage:_statusItemImage];
	[_statusItem setMenu:_statusMenu];

	// set up pasteboard
	NSPasteboard *pasteBoard = [NSPasteboard generalPasteboard];
	[pasteBoard declareTypes:[NSArray arrayWithObject:NSStringPboardType] owner:self];

	// subscribe to data source notifications
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(refreshCompleted:)
												 name:kDataSourceRefreshCompletedNotification
											   object:[DataSource sharedDataSource]];

	// subscribe to notifications from Preferences app
	[[NSDistributedNotificationCenter defaultCenter] addObserver:self
														selector:@selector(preferencesDidChange:)
															name:kPreferencesDidChangeNotification
														  object:nil];
	
	// subscribe to workspace notifications
	NSNotificationCenter *workspaceNotificationCenter = [[NSWorkspace sharedWorkspace] notificationCenter];
	
	// fast user switching
	[workspaceNotificationCenter addObserver:self
									selector:@selector(workspaceSessionDidBecomeActive:)
										name:NSWorkspaceSessionDidBecomeActiveNotification
									  object:nil];
	[workspaceNotificationCenter addObserver:self
									selector:@selector(workspaceSessionDidResignActive:)
										name:NSWorkspaceSessionDidResignActiveNotification
									  object:nil];
	
	// sleep
	[workspaceNotificationCenter addObserver:self
									selector:@selector(workspaceDidWake:)
										name:NSWorkspaceDidWakeNotification
									  object:nil];
	
	// perform initial refresh
	[self refresh];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
	// unsubscribe from notifications
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[[NSDistributedNotificationCenter defaultCenter] removeObserver:self
															   name:kPreferencesDidChangeNotification
															 object:nil];
	
	// post app termination notification so Preferences will terminate too
	[[NSDistributedNotificationCenter defaultCenter] postNotificationName:kPreferencesShouldTerminateNotification
																   object:nil
                                                                 userInfo:nil
                                                       deliverImmediately:YES];
}

- (void)dealloc
{
	[_statusItem release];
	[_statusMenu release];
	[_refreshTimer invalidate];
	[_refreshTimer release];
	[_accountsManager release];

	[super dealloc];
}

#pragma mark - Status menu

- (void)resetMenu
{
	[_statusMenu removeAllItems];
	[_statusMenu addItem:[self progressMessageItemWithTitle:@"Querying instance info..."]];
	[self addMenuActionItems];
}

- (void)addMenuActionItems
{
	if ([[_accountsManager accounts] count]) {
		// if there are configured accounts, show accounts and region selection

		NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        DataSource *dataSource = [DataSource sharedDataSource];
		NSInteger currentAccountId = userDefaults.accountId;
        BOOL hideTerminatedInstances = userDefaults.isHideTerminatedInstances;
		
		// Accounts
		
		[_statusMenu addItem:[NSMenuItem separatorItem]];
		[_statusMenu addItem:[self titleItemWithTitle:@"AWS ACCOUNTS"]];
        
		for (Account *account in [_accountsManager accounts]) {
			NSMenuItem *item = [self actionItemWithLabel:account.title info:nil action:@selector(selectAccountAction:)];
			[item setTag:account.accountId];
			[item setState:account.accountId == currentAccountId ? NSOnState : NSOffState];
			[_statusMenu addItem:item];
		}
		
		// Regions
		
		[_statusMenu addItem:[NSMenuItem separatorItem]];
		[_statusMenu addItem:[self titleItemWithTitle:@"AWS REGIONS"]];

        if (userDefaults.isRegionUSEastActive)
            [_statusMenu addItem:[self regionItemWithRegion:kAWSUSEastRegion
                                                       info:[dataSource instanceCountInRegionStringRepresentation:kAWSUSEastRegion hideTerminatedInstances:hideTerminatedInstances]]];
        if (userDefaults.isRegionUSWestNorthCaliforniaActive)
            [_statusMenu addItem:[self regionItemWithRegion:kAWSUSWestNorthCaliforniaRegion
                                                       info:[dataSource instanceCountInRegionStringRepresentation:kAWSUSWestNorthCaliforniaRegion hideTerminatedInstances:hideTerminatedInstances]]];
        if (userDefaults.isRegionUSWestOregonActive)
            [_statusMenu addItem:[self regionItemWithRegion:kAWSUSWestOregonRegion
                                                       info:[dataSource instanceCountInRegionStringRepresentation:kAWSUSWestOregonRegion hideTerminatedInstances:hideTerminatedInstances]]];
        if (userDefaults.isRegionUSGovCloudActive)
            [_statusMenu addItem:[self regionItemWithRegion:kAWSUSGovCloudRegion
                                                       info:[dataSource instanceCountInRegionStringRepresentation:kAWSUSGovCloudRegion hideTerminatedInstances:hideTerminatedInstances]]];
        if (userDefaults.isRegionEUActive)
            [_statusMenu addItem:[self regionItemWithRegion:kAWSEURegion
                                                       info:[dataSource instanceCountInRegionStringRepresentation:kAWSEURegion hideTerminatedInstances:hideTerminatedInstances]]];
        if (userDefaults.isRegionAsiaPacificSingaporeActive)
            [_statusMenu addItem:[self regionItemWithRegion:kAWSAsiaPacificSingaporeRegion
                                                       info:[dataSource instanceCountInRegionStringRepresentation:kAWSAsiaPacificSingaporeRegion hideTerminatedInstances:hideTerminatedInstances]]];
        if (userDefaults.isRegionAsiaPacificJapanActive)
            [_statusMenu addItem:[self regionItemWithRegion:kAWSAsiaPacificJapanRegion
                                                       info:[dataSource instanceCountInRegionStringRepresentation:kAWSAsiaPacificJapanRegion hideTerminatedInstances:hideTerminatedInstances]]];
        if (userDefaults.isRegionSouthAmericaSaoPauloActive)
            [_statusMenu addItem:[self regionItemWithRegion:kAWSSouthAmericaSaoPauloRegion
                                                       info:[dataSource instanceCountInRegionStringRepresentation:kAWSSouthAmericaSaoPauloRegion hideTerminatedInstances:hideTerminatedInstances]]];

		// Refresh
		
		if (!userDefaults.isRefreshOnMenuOpen) {
			[_statusMenu addItem:[NSMenuItem separatorItem]];
			[_statusMenu addItem:[self actionItemWithLabel:@"Refresh" info:nil action:@selector(refreshAction:)]];
		}
	}
	
	// Preferences and Quit

	[_statusMenu addItem:[NSMenuItem separatorItem]];
	[_statusMenu addItem:[self actionItemWithLabel:@"Open AWS Management Console" info:nil action:@selector(openAWSManagementConsoleAction:)]];
	[_statusMenu addItem:[self actionItemWithLabel:@"Preferences..." info:nil action:@selector(editPreferencesAction:)]];
	[_statusMenu addItem:[self actionItemWithLabel:@"Quit" info:nil action:@selector(quitAction:)]];
}

- (void)refreshMenu:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    NSString *refreshType = [userInfo objectForKey:kDataSourceRefreshTypeInfoKey];
    DataSource *dataSource = [DataSource sharedDataSource];
    
    if ([refreshType isEqualToString:kDataSourceCurrentRegionRefreshType]) {
        // current region refresh

//        TBTrace(@"current region refresh");
        
        [_statusMenu setMinimumWidth:0];
        [_statusMenu removeAllItems];

        NSError *error = [userInfo objectForKey:kDataSourceErrorInfoKey];
        if (error) {
            // refresh finished with error
            
            NSString *errorMessage = nil;
            if ([error domain] == kAWSErrorDomain)
                errorMessage = [[error userInfo] objectForKey:kAWSErrorMessageKey];
            else
                errorMessage = [[error userInfo] objectForKey:NSLocalizedDescriptionKey];
            
            [_statusMenu addItem:[self errorMessageItemWithTitle:errorMessage]];
            
            [self addMenuActionItems];
            
            [_statusItem setImage:_statusItemAlertImage];
            [_statusItem setTitle:nil];
        }
        else {
            // refresh finished successfully
            
            NSArray *instances = nil;
            
            BOOL hideTerminatedInstances = [[NSUserDefaults standardUserDefaults] isHideTerminatedInstances];
            BOOL sortInstancesByTitle = [[NSUserDefaults standardUserDefaults] isSortInstancesByTitle];
            if (hideTerminatedInstances) {
                instances = sortInstancesByTitle ? dataSource.sortedRunningInstances : dataSource.runningInstances;
            }
            else {
                instances = sortInstancesByTitle ? dataSource.sortedInstances : dataSource.instances;
            }
            NSUInteger instancesCount = [instances count];
            
            if (instancesCount > 0) {
                // there are instances
                
                [_statusMenu addItem:[self titleItemWithTitle:@"INSTANCES"]];
                
                for (EC2Instance *instance in instances) {
                    [_statusMenu addItem:[self instanceItemWithInstance:instance]];
                }
                
                [self addMenuActionItems];
            }
            else {
                // there are no instances
                
                NSString *awsRegionName = [AWSRequest regionTitleForRegion:[[NSUserDefaults standardUserDefaults] awsRegion]];
                [_statusMenu addItem:[self notificationMessageItemWithTitle:
                                      [NSString stringWithFormat:@"No instances in\n%@ region.", awsRegionName]]];
                
                [self addMenuActionItems];
            }

            [_statusItem setImage:_statusItemImage];
            
            NSAttributedString *statusItemTitle = [[NSAttributedString alloc]
                                                   initWithString:[NSString stringWithFormat:@"%zd", instancesCount]
                                                   attributes:_statusItemAttributes];
            [_statusItem setAttributedTitle:statusItemTitle];
            [statusItemTitle release];
        
            [_statusMenu setMinimumWidth:100];
        }
    }
    else if ([refreshType isEqualToString:kDataSourceAllRegionsRefreshType]) {
        // all regions refresh

//        TBTrace(@"all regions refresh");

        BOOL hideTerminatedInstances = [[NSUserDefaults standardUserDefaults] isHideTerminatedInstances];

        for (NSString *awsRegion in [AWSRequest regions]) {
            NSUInteger menuItemIdx = [[_statusMenu itemArray] indexOfObjectPassingTest:^(id obj, NSUInteger idx, BOOL *stop) {
                *stop = [[obj representedObject] isEqualToString:awsRegion];
                return *stop;
            }];
            
            if (menuItemIdx != NSNotFound) {
                NSMenuItem *regionItem = [self regionItemWithRegion:awsRegion
                                                               info:[dataSource instanceCountInRegionStringRepresentation:awsRegion hideTerminatedInstances:hideTerminatedInstances]]; 
                [_statusMenu removeItemAtIndex:menuItemIdx];
                [_statusMenu insertItem: regionItem atIndex:menuItemIdx];
            }
        }
    }
    else {
        // instance refresh

//        TBTrace(@"%@", refreshType);
        
        EC2Instance *instance = [dataSource instance:refreshType];
        
        NSUInteger menuItemIdx = [[_statusMenu itemArray] indexOfObjectPassingTest:^(id obj, NSUInteger idx, BOOL *stop) {
            *stop = [[obj representedObject] isEqualToString:refreshType];
            return *stop;
        }];
        
        if (instance && menuItemIdx != NSNotFound) {
            NSMenu *instanceSubmenu = [[[_statusMenu itemArray] objectAtIndex:menuItemIdx] submenu];
            [self refreshSubmenu:instanceSubmenu forInstance:instance];
        }
        else
            TBTrace(@"instance not found: %@ %zd", instance, menuItemIdx);
    }
}

#pragma mark - Menu item helpers

- (NSMenuItem *)titleItemWithTitle:(NSString *)title
{
	NSMutableAttributedString *attributedTitle = [[[NSMutableAttributedString alloc] initWithString:title
																						 attributes:_titleAttributes] autorelease];
	NSMutableParagraphStyle *paragraphStyle = [[[NSParagraphStyle defaultParagraphStyle] mutableCopy] autorelease];
	[paragraphStyle setMinimumLineHeight:20.f];

	[attributedTitle addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [attributedTitle length])];

	NSMenuItem *menuItem = [[[NSMenuItem alloc] initWithTitle:@"" action:NULL keyEquivalent:@""] autorelease];
	[menuItem setIndentationLevel:1];
	[menuItem setAttributedTitle:attributedTitle];
	[menuItem setEnabled:NO];

	return menuItem;
}

- (NSMenuItem *)messageItemWithTitle:(NSString *)title image:(NSImage *)image
{
	NSTextTable *table = [[[NSTextTable alloc] init] autorelease];
	[table setNumberOfColumns:1];
	[table setLayoutAlgorithm:NSTextTableAutomaticLayoutAlgorithm];
	[table setHidesEmptyCells:NO];

	NSTextTableBlock *titleBlock = [[[NSTextTableBlock alloc] initWithTable:table startingRow:0 rowSpan:1 startingColumn:0 columnSpan:1] autorelease];
	[titleBlock setContentWidth:kMessageTableWidth type:NSTextBlockAbsoluteValueType];
	[titleBlock setWidth:10.0f type:NSTextBlockAbsoluteValueType forLayer:NSTextBlockPadding edge:NSMinXEdge];

	NSMutableParagraphStyle *titleParagraphStyle = [[[NSParagraphStyle defaultParagraphStyle] mutableCopy] autorelease];
	[titleParagraphStyle setAlignment:NSLeftTextAlignment];
	[titleParagraphStyle setTextBlocks:[NSArray arrayWithObject:titleBlock]];

	NSMutableAttributedString *attributedTitle = [[[NSMutableAttributedString alloc] initWithString:@""] autorelease];
	NSUInteger attributedTitleLength = [attributedTitle length];

	NSString *titleText = nil;
	if (title) {
		if (NO == [title hasSuffix:@"."])
			titleText = [NSString stringWithFormat:@"%@.", title];
		else
			titleText = title;
	}
	else {
		titleText = @" ";
	}

	[attributedTitle replaceCharactersInRange:NSMakeRange(attributedTitleLength, 0) withString:titleText];
	[attributedTitle setAttributes:_messageItemAttributes range:NSMakeRange(attributedTitleLength, [attributedTitle length] - attributedTitleLength)];
	[attributedTitle addAttribute:NSParagraphStyleAttributeName value:titleParagraphStyle range:NSMakeRange(attributedTitleLength, [attributedTitle length] - attributedTitleLength)];

	NSMenuItem *menuItem = [[[NSMenuItem alloc] initWithTitle:@"" action:NULL keyEquivalent:@""] autorelease];

	[menuItem setIndentationLevel:1];
	[menuItem setAttributedTitle:attributedTitle];
//	[menuItem setTarget:self];
//	[menuItem setAction:@selector(nopAction:)];
	[menuItem setEnabled:NO];
	[menuItem setImage:image];

	return menuItem;
}

- (NSMenuItem *)progressMessageItemWithTitle:(NSString *)title
{
	return [self messageItemWithTitle:title image:[NSImage imageNamed:@"Progress"]];
}
	 
- (NSMenuItem *)errorMessageItemWithTitle:(NSString *)title
{
	return [self messageItemWithTitle:title image:[NSImage imageNamed:@"Error"]];
}

- (NSMenuItem *)notificationMessageItemWithTitle:(NSString *)title
{
	return [self messageItemWithTitle:title image:[NSImage imageNamed:@"Notification"]];
}

- (NSMenuItem *)instanceItemWithInstance:(EC2Instance *)instance
{
	NSMenuItem *menuItem = [[[NSMenuItem alloc] initWithTitle:@"" action:NULL keyEquivalent:@""] autorelease];
	[menuItem setIndentationLevel:1];

	// set item title to Name tag if present, otherwise to Instance ID
    NSAttributedString *attributedTitle = [[[NSAttributedString alloc] initWithString:instance.title attributes:_taggedInstanceAttributes] autorelease];
	menuItem.attributedTitle = attributedTitle;

	// set item image according to instance state
	NSImage *stateImage = nil;
//	if (instance.instanceState.code == EC2_INSTANCE_STATE_RUNNING_272) {
//		// special running state with 0x100 bit set to indicate problems with the host
//		stateImage = [NSImage imageNamed:@"InstanceStateRunning272"];
//	}
//	else {
//		// otherwise, according to API spec, high byte should be ignored
		switch (instance.instanceState.code & 0xFF) {
			case EC2_INSTANCE_STATE_RUNNING:
				stateImage = [NSImage imageNamed:@"InstanceStateRunning"];
				break;
			case EC2_INSTANCE_STATE_STOPPED:
				stateImage = [NSImage imageNamed:@"InstanceStateStopped"];
				break;
			case EC2_INSTANCE_STATE_TERMINATED:
				stateImage = [NSImage imageNamed:@"InstanceStateTerminated"];
				break;
			default:
				stateImage = [NSImage imageNamed:@"InstanceStateOther"];
				break;
		}
//	}
	[menuItem setImage:stateImage];
	
	// set item submenu
	[menuItem setSubmenu:[self submenuForInstance:instance]];
	
	// set item represented object to instance id
	[menuItem setRepresentedObject:instance.instanceId];
    // set tag to mark instance items
    [menuItem setTag:-100];

	return menuItem;
}

- (NSMenuItem *)regionItemWithRegion:(NSString *)awsRegion info:(NSString *)info
{
    NSInteger currentRegion = [[NSUserDefaults standardUserDefaults] region];
    NSMenuItem *item = nil;
    
    if ([awsRegion isEqualToString:kAWSUSEastRegion]) {
        // US East (Virginia)
        item = [self actionItemWithLabel:kAWSUSEastRegionTitle
                                    info:info
                                  action:@selector(selectRegionAction:)];
        [item setImage:_usImage];
        [item setTag:kPreferencesAWSUSEastRegion];
        [item setRepresentedObject:kAWSUSEastRegion];
        [item setState:kPreferencesAWSUSEastRegion == currentRegion ? NSOnState : NSOffState];
    }
    else if ([awsRegion isEqualToString:kAWSUSWestNorthCaliforniaRegion]) {
        // US West (North California)
        item = [self actionItemWithLabel:kAWSUSWestNorthCaliforniaRegionTitle
                                    info:info
                                  action:@selector(selectRegionAction:)];
        [item setImage:_usImage];
        [item setTag:kPreferencesAWSUSWestNorthCaliforniaRegion];
        [item setRepresentedObject:kAWSUSWestNorthCaliforniaRegion];
        [item setState:kPreferencesAWSUSWestNorthCaliforniaRegion == currentRegion ? NSOnState : NSOffState];
    }
    else if ([awsRegion isEqualToString:kAWSUSWestOregonRegion]) {
        // US West (Oregon)
        item = [self actionItemWithLabel:kAWSUSWestOregonRegionTitle
                                    info:info
                                  action:@selector(selectRegionAction:)];
        [item setImage:_usImage];
        [item setTag:kPreferencesAWSUSWestOregonRegion];
        [item setRepresentedObject:kAWSUSWestOregonRegion];
        [item setState:kPreferencesAWSUSWestOregonRegion == currentRegion ? NSOnState : NSOffState];
    }
    else if ([awsRegion isEqualToString:kAWSEURegion]) {
        // EU West (Ireland)
        item = [self actionItemWithLabel:kAWSEURegionTitle
                                    info:info
                                  action:@selector(selectRegionAction:)];
        [item setImage:_euImage];
        [item setTag:kPreferencesAWSEURegion];
        [item setRepresentedObject:kAWSEURegion];
        [item setState:kPreferencesAWSEURegion == currentRegion ? NSOnState : NSOffState];
    }
    else if ([awsRegion isEqualToString:kAWSAsiaPacificSingaporeRegion]) {
        // Asia Pacific (Singapore)
        item = [self actionItemWithLabel:kAWSAsiaPacificSingaporeRegionTitle
                                    info:info
                                  action:@selector(selectRegionAction:)];
        [item setImage:_sgImage];
        [item setTag:kPreferencesAWSAsiaPacificSingaporeRegion];
        [item setRepresentedObject:kAWSAsiaPacificSingaporeRegion];
        [item setState:kPreferencesAWSAsiaPacificSingaporeRegion == currentRegion ? NSOnState : NSOffState];
    }
    else if ([awsRegion isEqualToString:kAWSAsiaPacificJapanRegion]) {
        // Asia Pacific (Japan)
        item = [self actionItemWithLabel:kAWSAsiaPacificJapanRegionTitle
                                    info:info
                                  action:@selector(selectRegionAction:)];
        [item setImage:_jpImage];
        [item setTag:kPreferencesAWSAsiaPacificJapanRegion];
        [item setRepresentedObject:kAWSAsiaPacificJapanRegion];
        [item setState:kPreferencesAWSAsiaPacificJapanRegion == currentRegion ? NSOnState : NSOffState];
    }
    else if ([awsRegion isEqualToString:kAWSSouthAmericaSaoPauloRegion]) {
        // South America (Sao Paulo)
        item = [self actionItemWithLabel:kAWSSouthAmericaSaoPauloRegionTitle
                                    info:info
                                  action:@selector(selectRegionAction:)];
        [item setImage:_brImage];
        [item setTag:kPreferencesAWSSouthAmericaSaoPauloRegion];
        [item setRepresentedObject:kAWSSouthAmericaSaoPauloRegion];
        [item setState:kPreferencesAWSSouthAmericaSaoPauloRegion == currentRegion ? NSOnState : NSOffState];
    }
    else if ([awsRegion isEqualToString:kAWSUSGovCloudRegion]) {
        // US GovCloud
        item = [self actionItemWithLabel:kAWSUSGovCloudRegionTitle
                                    info:info
                                  action:@selector(selectRegionAction:)];
        [item setImage:_usImage];
        [item setTag:kPreferencesAWSUSGovCloudRegion];
        [item setRepresentedObject:kAWSUSGovCloudRegion];
        [item setState:kPreferencesAWSUSGovCloudRegion == currentRegion ? NSOnState : NSOffState];
    }
    
    return item;
}

- (NSMenuItem *)chartItemWithRange:(NSUInteger)range datapoints:(NSArray *)datapoints
{
	ChartView *chartView = [[[ChartView alloc] initWithRange:range datapoints:datapoints] autorelease];

	NSMenuItem *menuItem = [[[NSMenuItem alloc] initWithTitle:@"" action:NULL keyEquivalent:@""] autorelease];
	[menuItem setIndentationLevel:1];
	[menuItem setView:chartView];

	return menuItem;
}

- (NSMenuItem *)infoItemWithLabel:(NSString *)label info:(NSString *)info action:(SEL)action tooltip:(NSString *)tooltip
{
	NSTextTable *table = [[[NSTextTable alloc] init] autorelease];
	[table setNumberOfColumns:2];
	[table setLayoutAlgorithm:NSTextTableAutomaticLayoutAlgorithm];
	[table setContentWidth:kInstanceInfoTableWidth type:NSTextBlockAbsoluteValueType];
	[table setHidesEmptyCells:NO];

	NSTextTableBlock *labelBlock = [[[NSTextTableBlock alloc] initWithTable:table startingRow:0 rowSpan:1 startingColumn:0 columnSpan:1] autorelease];
	[labelBlock setContentWidth:kInstanceInfoLabelColumnWidth type:NSTextBlockAbsoluteValueType];

	NSTextTableBlock *infoBlock = [[[NSTextTableBlock alloc] initWithTable:table startingRow:0 rowSpan:1 startingColumn:1 columnSpan:1] autorelease];

	NSMutableParagraphStyle *labelParagraphStyle = [[[NSParagraphStyle defaultParagraphStyle] mutableCopy] autorelease];
	[labelParagraphStyle setAlignment:NSLeftTextAlignment];
	[labelParagraphStyle setTextBlocks:[NSArray arrayWithObject:labelBlock]];

	NSMutableParagraphStyle *infoParagraphStyle = [[[NSParagraphStyle defaultParagraphStyle] mutableCopy] autorelease];
	[infoParagraphStyle setAlignment:NSRightTextAlignment];
	[infoParagraphStyle setTextBlocks:[NSArray arrayWithObject:infoBlock]];

	NSMutableAttributedString *attributedTitle = [[[NSMutableAttributedString alloc] initWithString:@""] autorelease];

	NSUInteger textLength = [attributedTitle length];
	[attributedTitle replaceCharactersInRange:NSMakeRange(textLength, 0) withString:[NSString stringWithFormat:@"%@\n", (label ? label : @" ")]];
	[attributedTitle setAttributes:_labelColumnAttributes range:NSMakeRange(textLength, [attributedTitle length] - textLength)];
	[attributedTitle addAttribute:NSParagraphStyleAttributeName value:labelParagraphStyle range:NSMakeRange(textLength, [attributedTitle length] - textLength)];

	textLength = [attributedTitle length];
	[attributedTitle replaceCharactersInRange:NSMakeRange(textLength, 0) withString:[NSString stringWithFormat:@"%@", (info ? info : @" ")]];
	[attributedTitle setAttributes:_infoColumnAttributes range:NSMakeRange(textLength, [attributedTitle length] - textLength)];
	[attributedTitle addAttribute:NSParagraphStyleAttributeName value:infoParagraphStyle range:NSMakeRange(textLength, [attributedTitle length] - textLength)];

	NSMenuItem *menuItem = [[[NSMenuItem alloc] initWithTitle:@"" action:action keyEquivalent:@""] autorelease];

	[menuItem setIndentationLevel:1];
	[menuItem setAttributedTitle:attributedTitle];
	[menuItem setTarget:self];
	[menuItem setEnabled:action != NULL];
	[menuItem setToolTip:tooltip];
	[menuItem setRepresentedObject:info];

	return menuItem;
}

- (NSMenuItem *)actionItemWithLabel:(NSString *)label info:(NSString *)info action:(SEL)action
{
    NSMutableAttributedString *attributedTitle = nil;
    
    if ([info length]) {
        // action item with additional info on the right
        
        NSTextTable *table = [[[NSTextTable alloc] init] autorelease];
        [table setNumberOfColumns:2];
        [table setLayoutAlgorithm:NSTextTableAutomaticLayoutAlgorithm];
//        [table setContentWidth:kActionItemTableWidth type:NSTextBlockAbsoluteValueType];
        [table setHidesEmptyCells:NO];

        NSTextTableBlock *labelBlock = [[[NSTextTableBlock alloc] initWithTable:table startingRow:0 rowSpan:1 startingColumn:0 columnSpan:1] autorelease];
        [labelBlock setContentWidth:kActionItemLabelColumnWidth type:NSTextBlockAbsoluteValueType];
        
        NSTextTableBlock *infoBlock = [[[NSTextTableBlock alloc] initWithTable:table startingRow:0 rowSpan:1 startingColumn:1 columnSpan:1] autorelease];
        
        NSMutableParagraphStyle *labelParagraphStyle = [[[NSParagraphStyle defaultParagraphStyle] mutableCopy] autorelease];
        [labelParagraphStyle setAlignment:NSLeftTextAlignment];
        [labelParagraphStyle setLineBreakMode:NSLineBreakByClipping];
        [labelParagraphStyle setTextBlocks:[NSArray arrayWithObject:labelBlock]];
        
        NSMutableParagraphStyle *infoParagraphStyle = [[[NSParagraphStyle defaultParagraphStyle] mutableCopy] autorelease];
        [infoParagraphStyle setAlignment:NSRightTextAlignment];
        [infoParagraphStyle setTextBlocks:[NSArray arrayWithObject:infoBlock]];
        
        attributedTitle = [[[NSMutableAttributedString alloc] initWithString:@""] autorelease];
        
        NSUInteger textLength = [attributedTitle length];
        [attributedTitle replaceCharactersInRange:NSMakeRange(textLength, 0) withString:[NSString stringWithFormat:@"%@\n", ([label length] ? label : @" ")]];
        [attributedTitle setAttributes:_actionItemAttributes range:NSMakeRange(textLength, [attributedTitle length] - textLength)];
        [attributedTitle addAttribute:NSParagraphStyleAttributeName value:labelParagraphStyle range:NSMakeRange(textLength, [attributedTitle length] - textLength)];
        
        textLength = [attributedTitle length];
        [attributedTitle replaceCharactersInRange:NSMakeRange(textLength, 0) withString:[NSString stringWithFormat:@"%@", ([info length] ? info : @" ")]];
        [attributedTitle setAttributes:_infoColumnAttributes range:NSMakeRange(textLength, [attributedTitle length] - textLength)];
        [attributedTitle addAttribute:NSParagraphStyleAttributeName value:infoParagraphStyle range:NSMakeRange(textLength, [attributedTitle length] - textLength)];
    }
    else {
        // simple action item

        attributedTitle = [[[NSMutableAttributedString alloc] initWithString:label attributes:_actionItemAttributes] autorelease];
    }
    
    NSMenuItem *menuItem = [[[NSMenuItem alloc] initWithTitle:@"" action:action keyEquivalent:@""] autorelease];

    [menuItem setIndentationLevel:1];
    [menuItem setAttributedTitle:attributedTitle];
    [menuItem setTarget:self];
    
    return menuItem;
}

// HACK HACK HACK
// to force menu redrawing, this item is added at the beginning of the refresh and removed at the completion
- (NSMenuItem *)dummyItem
{
	NSView *dummyView = [[[NSView alloc] initWithFrame:NSMakeRect(0, 0, 1, 0.01f)] autorelease];
	
	NSMenuItem *menuItem = [[[NSMenuItem alloc] initWithTitle:@"" action:NULL keyEquivalent:@""] autorelease];
	[menuItem setIndentationLevel:1];
	[menuItem setView:dummyView];
	
	return menuItem;
}

#pragma mark - Submenu

- (NSMenu *)submenuForInstance:(EC2Instance *)instance
{
	NSMenu *menu = [[NSMenu alloc] initWithTitle:@""];
    [menu setTitle:instance.instanceId];
	[menu setDelegate:self];
	[menu setShowsStateColumn:NO];
 
	[self refreshSubmenu:menu forInstance:instance];

	return [menu autorelease];
}

- (void)refreshSubmenu:(NSMenu *)menu forInstance:(EC2Instance *)instance
{
	DataSource *dataSource = [DataSource sharedDataSource];

	// XXX: it seems that there's a bug in Cocoa menu system - when chart menu item gets removed,
	// Cocoa will release submenu's window (NSCarbonMenuWindow) prematurely and the app will crash with zombie access.
	// To work around this, find NSCarbonMenuWindow and send it retain/autorelease to keep it alive until next event loop.
	for (NSInteger i = 0; i < [menu numberOfItems]; i++) {
		NSView *view = [[menu itemAtIndex:i] view];
		if (view) {
			NSWindow *menuWindow = [view window];
			[[menuWindow retain] autorelease];
		}
	}
	
	[menu removeAllItems];

	[menu addItem:[self titleItemWithTitle:@"INSTANCE DETAILS"]];
	[menu addItem:[self infoItemWithLabel:@"Instance ID" info:instance.instanceId action:@selector(copyToPasteboardAction:) tooltip:@"Copy Instance ID"]];
	[menu addItem:[self infoItemWithLabel:@"Image ID" info:instance.imageId action:@selector(copyToPasteboardAction:) tooltip:@"Copy Image ID"]];
	[menu addItem:[self infoItemWithLabel:@"Instance Type" info:instance.instanceType action:NULL tooltip:nil]];
	[menu addItem:[self infoItemWithLabel:@"Monitoring" info:instance.monitoring.monitoringType action:NULL tooltip:nil]];
	[menu addItem:[self infoItemWithLabel:@"Launched At" info:[instance.launchTime localizedString] action:NULL tooltip:nil]];
	[menu addItem:[self infoItemWithLabel:@"Availability Zone" info:instance.placement.availabilityZone action:NULL tooltip:nil]];
    if (instance.securityGroup)
        [menu addItem:[self infoItemWithLabel:@"Security Group" info:instance.securityGroup action:NULL tooltip:nil]];
    if (instance.autoscalingGroupName)
        [menu addItem:[self infoItemWithLabel:@"Autoscaling Group" info:instance.autoscalingGroupName action:NULL tooltip:nil]];
	[menu addItem:[self infoItemWithLabel:@"State" info:instance.instanceState.name action:NULL tooltip:nil]];

	if ([instance.ipAddress length] > 0) {
		[menu addItem:[NSMenuItem separatorItem]];
		[menu addItem:[self titleItemWithTitle:@"NETWORKING"]];
		[menu addItem:[self infoItemWithLabel:@"Public IP" info:instance.ipAddress action:@selector(copyToPasteboardAction:) tooltip:@"Copy Public IP"]];
		[menu addItem:[self infoItemWithLabel:@"Private IP" info:instance.privateIpAddress action:@selector(copyToPasteboardAction:) tooltip:@"Copy Private IP"]];
	}

	if (instance.instanceState.code != EC2_INSTANCE_STATE_PENDING) {
		[menu addItem:[NSMenuItem separatorItem]];
		[menu addItem:[self titleItemWithTitle:@"CPU UTILIZATION"]];
		[menu addItem:[self chartItemWithRange:kAWSLastHourRange datapoints:[dataSource statisticsForMetric:kAWSCPUUtilizationMetric forInstance:instance.instanceId]]];

		if ([[dataSource statisticsForMetric:kAWSCPUUtilizationMetric forInstance:instance.instanceId] count] > 0) {
			CGFloat maxCPUUtilization = [dataSource maximumValueForMetric:kAWSCPUUtilizationMetric forInstance:instance.instanceId forRange:kAWSLastHourRange];
			CGFloat minCPUUtilization = [dataSource minimumValueForMetric:kAWSCPUUtilizationMetric forInstance:instance.instanceId forRange:kAWSLastHourRange];
			CGFloat avgCPUUtilization = [dataSource averageValueForMetric:kAWSCPUUtilizationMetric forInstance:instance.instanceId forRange:kAWSLastHourRange];
			
			if (maxCPUUtilization > 0. || minCPUUtilization > 0. || avgCPUUtilization > 0.) {
				[menu addItem:[self infoItemWithLabel:@"Maximum" info:[NSString stringWithFormat:@"%.1f%%", maxCPUUtilization] action:NULL tooltip:nil]];
				[menu addItem:[self infoItemWithLabel:@"Minimum" info:[NSString stringWithFormat:@"%.1f%%", minCPUUtilization] action:NULL tooltip:nil]];
				[menu addItem:[self infoItemWithLabel:@"Average" info:[NSString stringWithFormat:@"%.1f%%", avgCPUUtilization] action:NULL tooltip:nil]];
			}
		}
	}

	if ((instance.instanceState.code & 0xFF) == EC2_INSTANCE_STATE_RUNNING) {
		[menu addItem:[NSMenuItem separatorItem]];

		if ([instance.platform isEqualToString:@"windows"])
			[menu addItem:[self actionItemWithLabel:@"Connect (RDP)..." info:nil action:@selector(connectToInstanceWithRdpAction:)]];
		else
			[menu addItem:[self actionItemWithLabel:@"Connect (SSH)..." info:nil action:@selector(connectToInstanceWithSshAction:)]];
	}
	
//	[menu addItem:[NSMenuItem separatorItem]];
//	[menu addItem:[self actionItemWithLabel:@"Restart..." action:@selector(connectToInstanceAction:)]];
//	[menu addItem:[self actionItemWithLabel:@"Terminate..." action:@selector(connectToInstanceAction:)]];
}

#pragma mark - DataSource operations and notifications

- (BOOL)refresh
{
	DataSource *dataSource = [DataSource sharedDataSource];
    BOOL result = [dataSource refreshCurrentRegionIgnoringAge:NO];
    [dataSource refreshAllRegionsIgnoringAge:NO];
    
    return result;
}

- (BOOL)refreshIgnoringAge
{
	DataSource *dataSource = [DataSource sharedDataSource];
	BOOL result = [dataSource refreshCurrentRegionIgnoringAge:YES];
    [dataSource refreshAllRegionsIgnoringAge:YES];
    
    return result;
}

- (BOOL)refresh:(NSString *)instanceId
{
	DataSource *dataSource = [DataSource sharedDataSource];
	return [dataSource refreshInstance:instanceId ignoringAge:NO];
}

- (void)refreshCompleted:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    NSString *refreshType = [userInfo objectForKey:kDataSourceRefreshTypeInfoKey];
    
    if ([refreshType isEqualToString:kDataSourceCurrentRegionRefreshType]) {
        [_statusMenu addItem:[self dummyItem]];
    }
    
	[self performSelector:@selector(refreshMenu:)
			   withObject:notification
			   afterDelay:0.
				  inModes:[NSArray arrayWithObjects:NSDefaultRunLoopMode, NSEventTrackingRunLoopMode, nil]];

//	[self performSelectorOnMainThread:@selector(refreshMenu:)
//						   withObject:notification
//						waitUntilDone:NO];

//	[self performSelectorOnMainThread:@selector(refreshMenu:)
//						   withObject:notification
//						waitUntilDone:NO
//								modes:[NSArray arrayWithObjects:NSDefaultRunLoopMode, NSEventTrackingRunLoopMode, nil]];

//	[self refreshMenu:notification];
}

#pragma mark - Menu delegate

- (void)menuNeedsUpdate:(NSMenu *)menu
{
	NSString *instanceId = [menu title];
	if (![instanceId length]) {
		// status menu
		
		[self disableRefreshTimer];

		// refresh all instances only if "Refresh on menu open" is checked
		if ([[NSUserDefaults standardUserDefaults] isRefreshOnMenuOpen]) {
			if ([self refresh]) {
                // data source did start refresh
                for (NSMenuItem *menuItem in [_statusMenu itemArray]) {
                    // instanse items have negative tag
                    if ([menuItem tag] < 0) {
                        [menuItem setImage:[NSImage imageNamed:@"InstanceStateRefreshing"]];
                        [menuItem setSubmenu:nil];
                    }
                }
            }
		}
	}
	else {
		// instance submenu
		
		[self refresh:instanceId];
	}
}

- (void)menuDidClose:(NSMenu *)menu
{
	NSString *instanceId = [menu title];
	if (![instanceId length]) {
		// status menu
		
		// enable background refresh
		[self enableRefreshTimer];
	}
}

#pragma mark - User Defaults

- (void)loadPreferences
{
	TBTrace(@"reloading preferences");

	[[NSUserDefaults standardUserDefaults] synchronize];

	// set AWS options
	[self setupDataSource];
	
	// setup background refresh timer
	[self enableRefreshTimer];
}

- (void)setupDataSource
{
	NSMutableDictionary *options = [NSMutableDictionary dictionary];
	
	// reload accounts
	[_accountsManager loadAccounts];

	// get selected account
	Account *account = [_accountsManager accountWithId:[[NSUserDefaults standardUserDefaults] accountId]];
	if (!account && [[_accountsManager accounts] count] > 0) {
		// if previously selected account does not exist, get the first one
		account = [[_accountsManager accounts] objectAtIndex:0];
	}
	
	if (account) {
		[[NSUserDefaults standardUserDefaults] setAccountId:account.accountId];
		[options setObject:account.accessKeyID forKey:kAWSAccessKeyIdOption];
		[options setObject:account.secretAccessKey forKey:kAWSSecretAccessKeyOption];
	}
	else {
		// reset credentials in API
		[options setObject:@"" forKey:kAWSAccessKeyIdOption];
		[options setObject:@"" forKey:kAWSSecretAccessKeyOption];
	}
	
	// setup AWS region from user defaults
	NSString *awsRegion = [[NSUserDefaults standardUserDefaults] awsRegion];
	if (awsRegion) {
		[options setObject:awsRegion forKey:kAWSRegionOption];
	}
	
	[DataSource setDefaultRequestOptions:options];
}

- (void)preferencesDidChange:(NSNotification *)notification
{
	TBTrace(@"%@", notification);

	[self loadPreferences];
	[self refreshIgnoringAge];
}

#pragma mark - Background refresh timer

- (void)enableRefreshTimer
{
	TBTrace(@"enabling background refresh");

	NSTimeInterval refreshInterval = [[NSUserDefaults standardUserDefaults] refreshInterval];
	if (refreshInterval > 0) {
		
		if (_refreshTimer) {
			[_refreshTimer invalidate];
			TBRelease(_refreshTimer);
		}
		
		_refreshTimer = [[NSTimer scheduledTimerWithTimeInterval:refreshInterval
														 target:self
													   selector:@selector(timerRefresh:)
													   userInfo:nil
														repeats:YES] retain];
	}
}

- (void)disableRefreshTimer
{
	TBTrace(@"disabling background refresh");

	if (_refreshTimer) {
		[_refreshTimer invalidate];
		TBRelease(_refreshTimer);
	}
}

- (void)timerRefresh:(NSTimer *)timer
{
	[self refresh];
}

#pragma mark - Workspace notifications

- (void)workspaceSessionDidBecomeActive:(NSNotification *)notification
{
	TBTrace(@"performing refresh and enabling background refresh timer");
	
	[self refresh];
	[self enableRefreshTimer];
}

- (void)workspaceSessionDidResignActive:(NSNotification *)notification
{
	TBTrace(@"disabling background refresh timer");
	
	[self disableRefreshTimer];
}

- (void)workspaceDidWake:(NSNotification *)notification
{
	TBTrace(@"scheduling refresh and enabling background refresh timer");

	[self enableRefreshTimer];
	[self performSelector:@selector(refresh) withObject:nil afterDelay:15.0];
}

#pragma mark - Actions

- (void)nopAction:(id)sender
{
}

- (void)selectAccountAction:(id)sender
{
	NSInteger accountId = [sender tag];
	[[NSUserDefaults standardUserDefaults] setAccountId:accountId];
	
    [[DataSource sharedDataSource] reset];
	[self preferencesDidChange:nil];
}

- (void)selectRegionAction:(id)sender
{
	NSInteger region = [sender tag];
	[[NSUserDefaults standardUserDefaults] setRegion:region];
	
	[self preferencesDidChange:nil];
}

- (void)refreshAction:(id)sender
{
	[self refreshIgnoringAge];
}

- (void)quitAction:(id)sender
{
	[[NSApplication sharedApplication] terminate:self];
}

- (void)editPreferencesAction:(id)sender
{
	NSString *preferencesBundlePath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:kElasticsPreferencesApplicationPath];
	[[NSWorkspace sharedWorkspace] launchApplication:preferencesBundlePath];
}

- (void)copyToPasteboardAction:(id)sender
{
	NSMenuItem *menuItem = (NSMenuItem *)sender;
	NSPasteboard *pasteBoard = [NSPasteboard generalPasteboard];
    [pasteBoard clearContents];
	[pasteBoard setString:[menuItem representedObject] forType:NSPasteboardTypeString];
}

- (void)connectToInstanceWithSshAction:(id)sender
{
	NSMenuItem *menuItem = (NSMenuItem *)sender;
	NSString *instanceId = [[menuItem menu] title];
	EC2Instance *instance = [[DataSource sharedDataSource] instance:instanceId];
	NSInteger terminalApplication = [[NSUserDefaults standardUserDefaults] terminalApplication];
	BOOL isOpenInTerminalTab = [[NSUserDefaults standardUserDefaults] isOpenInTerminalTab];
	
	if (instance) {
		Account *account = [_accountsManager accountWithId:[[NSUserDefaults standardUserDefaults] accountId]];
		
		NSString *sshPrivateKeyFile = nil;
		if ([account.sshPrivateKeyFile length] > 0)
			sshPrivateKeyFile = account.sshPrivateKeyFile;
		else
			sshPrivateKeyFile = [[NSUserDefaults standardUserDefaults] sshPrivateKeyFile];
		
		NSString *sshUserName = nil;
		if ([account.sshUserName length] > 0)
			sshUserName = account.sshUserName;
		else
			sshUserName = [[NSUserDefaults standardUserDefaults] sshUserName];
        
        NSUInteger sshPort = 0;
		if (account.sshPort > 0)
			sshPort = account.sshPort;
		else
			sshPort = [[NSUserDefaults standardUserDefaults] sshPort];
		
		NSString *sshOptions = nil;
		if ([account.sshOptions length] > 0)
			sshOptions = account.sshOptions;
		else
			sshOptions = [[NSUserDefaults standardUserDefaults] sshOptions];

        NSString *instanceAddress = [[NSUserDefaults standardUserDefaults] isUsingPublicDNS] ? instance.dnsName : instance.ipAddress;

		NSString *cmd = @"ssh";

		if (sshPort > 0)
			cmd = [cmd stringByAppendingFormat:@" -p %zd", sshPort];
        
		if ([sshPrivateKeyFile length] > 0)
			cmd = [cmd stringByAppendingFormat:@" -i \'%@\'", sshPrivateKeyFile];
		
		if ([sshOptions length] > 0)
			cmd = [cmd stringByAppendingFormat:@" %@", sshOptions];

		if ([sshUserName length] > 0)
			cmd = [cmd stringByAppendingFormat:@" %@@%@", sshUserName, instanceAddress];
		else
			cmd = [cmd stringByAppendingFormat:@" %@", instanceAddress];

		switch (terminalApplication) {
			// use iTerm terminal
			case kPreferencesTerminalApplicationiTerm:
            {
                NSString *new = nil;
                NSString *old = nil;

				if (isOpenInTerminalTab) {
					// new iTerm tab

                    // for iTerm 3+
                    new = [NSString stringWithFormat:
                           @"activate\n"
                           @"tell current window\n"
                           @"    set newTab to create tab with default profile\n"
                           @"    tell newTab\n"
                           @"        tell current session\n"
                           @"            write text \"%@\"\n"
                           @"        end tell\n"
                           @"    end tell\n"
                           @"end tell",
                           cmd];

                    // for older version
                    old = [NSString stringWithFormat:
                           @"	activate\n"
                           @"	try\n"
                           @"		set myterm to (current terminal)\n"
                           @"		tell myterm\n"
                           @"			launch session \"Default Session\"\n"
                           @"			tell the last session\n"
                           @"				write text \"%@\"\n"
                           @"			end tell\n"
                           @"		end tell\n"
                           @"	on error\n"
                           @"		set myterm to (make new terminal)\n"
                           @"		tell myterm\n"
                           @"			launch session \"Default Session\"\n"
                           @"			tell the last session\n"
                           @"				write text \"%@\"\n"
                           @"			end tell\n"
                           @"		end tell\n"
                           @"	end try",
                           cmd, cmd];
                }
				else {
					// new iTerm window

                    // for iTerm 3+
                    new = [NSString stringWithFormat:
                           @"activate\n"
                           @"set newWindow to create window with default profile\n"
                           @"tell newWindow\n"
                           @"    tell current session\n"
                           @"        write text \"%@\"\n"
                           @"    end tell\n"
                           @"end tell",
                           cmd];

                    // for older versions
                    old = [NSString stringWithFormat:
                           @"	activate\n"
                           @"	set myterm to (make new terminal)\n"
                           @"	tell myterm\n"
                           @"		launch session \"Default Session\"\n"
                           @"		tell the last session\n"
                           @"			write text \"%@\"\n"
                           @"		end tell\n"
                           @"	end tell",
                           cmd];
                }

                new = [new stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
                old = [old stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];

                cmd = [NSString stringWithFormat:
                       @"on theSplit(theString, theDelimiter)\n"
                       @"    set oldDelimiters to AppleScript's text item delimiters\n"
                       @"    set AppleScript's text item delimiters to theDelimiter\n"
                       @"    set theArray to every text item of theString\n"
                       @"    set AppleScript's text item delimiters to oldDelimiters\n"
                       @"    return theArray\n"
                       @"end theSplit\n"
                       @"\n"
                       @"on IsModernVersion(version)\n"
                       @"    set myArray to my theSplit(version, \".\")\n"
                       @"    set major to item 1 of myArray\n"
                       @"    set minor to item 2 of myArray\n"
                       @"    set veryMinor to item 3 of myArray\n"
                       @"    \n"
                       @"    if major < 2 then\n"
                       @"        return false\n"
                       @"    end if\n"
                       @"    if major > 2 then\n"
                       @"        return true\n"
                       @"    end if\n"
                       @"    if minor < 9 then\n"
                       @"        return false\n"
                       @"    end if\n"
                       @"    if minor > 9 then\n"
                       @"        return true\n"
                       @"    end if\n"
                       @"    if veryMinor < 20140903 then\n"
                       @"        return false\n"
                       @"    end if\n"
                       @"    return true\n"
                       @"end IsModernVersion\n"
                       @"\n"
                       @"on NewScript()\n"
                       @"    return \"%@\"\n"
                       @"end NewScript\n"
                       @"\n"
                       @"on OldScript()\n"
                       @"    return \"%@\"\n"
                       @"end OldScript\n"
                       @"\n"
                       @"tell application \"iTerm\"\n"
                       @"    if my IsModernVersion(version) then\n"
                       @"        set myScript to my NewScript()\n"
                       @"    else\n"
                       @"        set myScript to my OldScript()\n"
                       @"    end if\n"
                       @"end tell\n"
                       @"\n"
                       @"set fullScript to \"tell application \\\"iTerm\\\"\n"
                       @"\" & myScript & \"\n"
                       @"end tell\"\n"
                       @"\n"
                       @"run script fullScript",
                       new, old];
				break;
            }

			// use Terminal terminal
			default:
				if (isOpenInTerminalTab) {
					// new Terminal tab
					
					cmd = [NSString stringWithFormat:
						   @"activate application \"Terminal\"\n"
						   @"tell application \"System Events\"\n"
						   @"	keystroke \"t\" using {command down}\n"
						   @"end tell\n"
						   @"tell application \"Terminal\"\n"
						   @"	repeat with win in windows\n"
						   @"	try\n"
						   @"		if get frontmost of win is true then\n"
						   @"			do script \"%@\" in (selected tab of win)\n"
						   @"		end if\n"
						   @"	end try\n"
						   @"	end repeat\n"
						   @"end tell",
						   cmd];
				}
				else {
					// new Terminal window
					
					cmd = [NSString stringWithFormat:
						   @"tell application \"Terminal\"\n"
						   @"	do script \"%@\"\n"
						   @"end tell",
						   cmd];
				}
				break;
		}
		
		TBTrace(@"%@", cmd);

		NSAppleScript *appleScript = [[[NSAppleScript alloc] initWithSource:cmd] autorelease];
		NSDictionary *errorInfo = nil;
		[appleScript executeAndReturnError:&errorInfo];

		// TODO: handle errors
	}
}

- (void)connectToInstanceWithRdpAction:(id)sender
{
	NSMenuItem *menuItem = (NSMenuItem *)sender;
	NSString *instanceId = [[menuItem menu] title];
	EC2Instance *instance = [[DataSource sharedDataSource] instance:instanceId];
	
	if (instance) {
		// NSInteger rdpApplication = [[NSUserDefaults standardUserDefaults] rdpApplication];
		// TODO: switch ...
		
		NSString *cmd = nil;
        NSString *instanceAddress = [[NSUserDefaults standardUserDefaults] isUsingPublicDNS] ? instance.dnsName : instance.ipAddress;

		cmd = [NSString stringWithFormat:
			   @"tell application \"Finder\" to set the clipboard to \"%@\"\n"
			   @"tell application \"CoRD\" to activate\n"
			   @"tell application \"System Events\"\n"
			   @"	keystroke \"g\" using command down\n"
			   @"	keystroke \"v\" using command down\n"
			   @"	do shell script \"sleep 1\"\n"
			   @"	keystroke return\n"
			   @"end tell\n",
			   instanceAddress];

		TBTrace(@"%@", cmd);
		
		NSAppleScript *appleScript = [[[NSAppleScript alloc] initWithSource:cmd] autorelease];
		NSDictionary *errorInfo = nil;
		[appleScript executeAndReturnError:&errorInfo];
		
		// TODO: handle errors
	}
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

- (void)openAWSManagementConsoleAction:(id)sender
{
    NSString *awsRegion = [[NSUserDefaults standardUserDefaults] awsRegion];
    NSString *urlString = [NSString stringWithFormat:@"https://console.aws.amazon.com/ec2/home?region=%@", awsRegion];

	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:urlString]];
}

@end
