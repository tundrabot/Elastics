//
//  ElasticAppDelegate.m
//  Elastic
//
//  Created by Dmitri Goutnik on 21/12/2010.
//  Copyright 2010 Tundra Bot. All rights reserved.
//

#import "ElasticAppDelegate.h"
#import "DataSource.h"
#import "ChartView.h"
#import "Preferences.h"
#import "Keychain.h"
#import "ValidateReceipt.h"

#define INSTANCE_INFO_TABLE_WIDTH				220.f
#define INSTANCE_INFO_LABEL_COLUMN_WIDTH		90.f

#define MESSAGE_TABLE_WIDTH						180.f

@interface ElasticAppDelegate ()
- (void)resetMenu;
- (void)refreshMenu:(NSNotification *)notification;
- (NSMenuItem *)titleItemWithTitle:(NSString *)title;
- (NSMenuItem *)messageItemWithTitle:(NSString *)title image:(NSImage *)image;
- (NSMenuItem *)errorMessageItemWithTitle:(NSString *)title;
- (NSMenuItem *)notificationMessageItemWithTitle:(NSString *)title;
- (NSMenuItem *)instanceItemWithInstance:(EC2Instance *)instance;
- (NSMenuItem *)chartItemWithRange:(NSUInteger)range datapoints:(NSArray *)datapoints;
- (NSMenuItem *)infoItemWithLabel:(NSString *)label info:(NSString *)info action:(SEL)action tooltip:(NSString *)tooltip;
- (NSMenuItem *)actionItemWithLabel:(NSString *)label action:(SEL)action;

- (NSMenu *)submenuForInstance:(EC2Instance *)instance;
- (void)refreshSubmenu:(NSMenu *)menu forInstance:(EC2Instance *)instance;

- (void)refresh:(NSString *)instanceId;
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
- (void)refreshAction:(id)sender;
- (void)quitAction:(id)sender;
- (void)editPreferencesAction:(id)sender;
- (void)copyToPasteboardAction:(id)sender;
- (void)connectToInstanceAction:(id)sender;
- (void)aboutAction:(id)sender;
@end

@implementation ElasticAppDelegate

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

+ (void)initialize
{
	NSString *receiptPath = nil;
	
#ifdef TB_USE_SAMPLE_RECEIPT
	receiptPath = kElasticSampleReceiptPath;
#else
	receiptPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"Contents/_MASReceipt/receipt"];
#endif
	
	validateReceiptAtPath(receiptPath);
	NSLog(@"receipt validated successfully");

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
	
	if (!_statusItemImage)			_statusItemImage = [NSImage imageNamed:@"StatusItem.png"];
	if (!_statusItemAlertImage)		_statusItemAlertImage = [NSImage imageNamed:@"StatusItemAlert.png"];
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
	// register preferences set through Preferences helper app and defaults
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults addSuiteNamed:@"com.tundrabot.ElasticPreferences"];
	[userDefaults registerDefaults:[userDefaults defaultElasticPreferences]];

	// load current preferences
	[self loadPreferences];

	// set up status item menu
	_statusMenu = [[NSMenu alloc] initWithTitle:@""];
	[_statusMenu setAutoenablesItems:NO];
	[_statusMenu setShowsStateColumn:NO];
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
											   object:[DataSource sharedInstance]];

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
	[self refresh:nil];
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
																   object:nil];
}

- (void)dealloc
{
	TBRelease(_statusItem);
	TBRelease(_statusMenu);
	[_refreshTimer invalidate];
	TBRelease(_refreshTimer);
	[super dealloc];
}

#pragma mark -
#pragma mark Status menu

- (void)resetMenu
{
	[_statusMenu removeAllItems];

	if (![[NSUserDefaults standardUserDefaults] isRefreshOnMenuOpen]) {
		[_statusMenu addItem:[NSMenuItem separatorItem]];
		[_statusMenu addItem:[self actionItemWithLabel:@"Refresh" action:@selector(refreshAction:)]];
	}
	[_statusMenu addItem:[NSMenuItem separatorItem]];
	[_statusMenu addItem:[self actionItemWithLabel:@"Preferences..." action:@selector(editPreferencesAction:)]];
	[_statusMenu addItem:[self actionItemWithLabel:@"About..." action:@selector(aboutAction:)]];
	[_statusMenu addItem:[self actionItemWithLabel:@"Quit" action:@selector(quitAction:)]];
}

- (void)refreshMenu:(NSNotification *)notification
{
	[_statusMenu setMinimumWidth:0];

	NSError *error = [[notification userInfo] objectForKey:kDataSourceErrorInfoKey];

	if (error) {
		// refresh finished with error
		
		[_statusMenu removeAllItems];

		NSString *errorMessage = nil;

		if ([error domain] == kAWSErrorDomain)
			errorMessage = [[error userInfo] objectForKey:kAWSErrorMessageKey];
		else
			errorMessage = [[error userInfo] objectForKey:NSLocalizedDescriptionKey];

		[_statusMenu addItem:[self errorMessageItemWithTitle:errorMessage]];

		if (![[NSUserDefaults standardUserDefaults] isRefreshOnMenuOpen]) {
			[_statusMenu addItem:[NSMenuItem separatorItem]];
			[_statusMenu addItem:[self actionItemWithLabel:@"Refresh" action:@selector(refreshAction:)]];
		}
		[_statusMenu addItem:[NSMenuItem separatorItem]];
		[_statusMenu addItem:[self actionItemWithLabel:@"Preferences..." action:@selector(editPreferencesAction:)]];
		[_statusMenu addItem:[self actionItemWithLabel:@"About..." action:@selector(aboutAction:)]];
		[_statusMenu addItem:[self actionItemWithLabel:@"Quit" action:@selector(quitAction:)]];

		[_statusItem setImage:_statusItemAlertImage];
		[_statusItem setTitle:nil];
	}
	else {
		// refresh finished successfully
		
		DataSource *dataSource = [DataSource sharedInstance];
		NSUInteger instancesCount = [dataSource.instances count];

		if (instancesCount > 0) {
			// there are some instances
			
			NSString *instanceId = [[notification userInfo] objectForKey:kDataSourceInstanceIdInfoKey];

			if ([instanceId length] > 0) {
				// was refresh for selected instance

				TBTrace(@"%@", instanceId);
				
				EC2Instance *instance = [dataSource instance:instanceId];

				NSUInteger menuItemIdx = [[_statusMenu itemArray] indexOfObjectPassingTest:^(id obj, NSUInteger idx, BOOL *stop) {
					*stop = [[obj representedObject] isEqualToString:instanceId];
					return *stop;
				}];

				if (instance && menuItemIdx != NSNotFound) {
					NSMenu *instanceSubmenu = [[[_statusMenu itemArray] objectAtIndex:menuItemIdx] submenu];
					[self refreshSubmenu:instanceSubmenu forInstance:instance];
				}
			}
			else {
				// was refresh for all instances

				TBTrace(@"all instances");

				[_statusMenu removeAllItems];

				[_statusMenu addItem:[self titleItemWithTitle:@"INSTANCES"]];
				for (EC2Instance *instance in dataSource.instances) {
					[_statusMenu addItem:[self instanceItemWithInstance:instance]];
				}

//				// Add chart
//				[_statusMenu addItem:[NSMenuItem separatorItem]];
//				[_statusMenu addItem:[self titleItemWithTitle:@"CPU UTILIZATION"]];
//				[_statusMenu addItem:[self chartItemWithRange:kAWSLastHourRange datapoints:[dataSource statisticsForMetric:kAWSCPUUtilizationMetric]]];
//
//				CGFloat maxCPUUtilization = [dataSource maximumValueForMetric:kAWSCPUUtilizationMetric forRange:kAWSLastHourRange];
//				CGFloat minCPUUtilization = [dataSource minimumValueForMetric:kAWSCPUUtilizationMetric forRange:kAWSLastHourRange];
//				CGFloat avgCPUUtilization = [dataSource averageValueForMetric:kAWSCPUUtilizationMetric forRange:kAWSLastHourRange];
//
//				[_statusMenu addItem:[self infoItemWithLabel:@"Maximum" info:[NSString stringWithFormat:@"%.1f%%", maxCPUUtilization] action:NULL tooltip:nil]];
//				[_statusMenu addItem:[self infoItemWithLabel:@"Minimum" info:[NSString stringWithFormat:@"%.1f%%", minCPUUtilization] action:NULL tooltip:nil]];
//				[_statusMenu addItem:[self infoItemWithLabel:@"Average" info:[NSString stringWithFormat:@"%.1f%%", avgCPUUtilization] action:NULL tooltip:nil]];

				if (![[NSUserDefaults standardUserDefaults] isRefreshOnMenuOpen]) {
					[_statusMenu addItem:[NSMenuItem separatorItem]];
					[_statusMenu addItem:[self actionItemWithLabel:@"Refresh" action:@selector(refreshAction:)]];
				}
				[_statusMenu addItem:[NSMenuItem separatorItem]];
				[_statusMenu addItem:[self actionItemWithLabel:@"Preferences..." action:@selector(editPreferencesAction:)]];
				[_statusMenu addItem:[self actionItemWithLabel:@"About..." action:@selector(aboutAction:)]];
				[_statusMenu addItem:[self actionItemWithLabel:@"Quit" action:@selector(quitAction:)]];
			}
		}
		else {
			// there are no instances

			[_statusMenu removeAllItems];

			NSString *awsRegionName = [AWSRequest regionTitleForRegion:[[NSUserDefaults standardUserDefaults] awsRegion]];
			[_statusMenu addItem:[self notificationMessageItemWithTitle:
								  [NSString stringWithFormat:@"No instances in\n%@ region.", awsRegionName]]];

			if (![[NSUserDefaults standardUserDefaults] isRefreshOnMenuOpen]) {
				[_statusMenu addItem:[NSMenuItem separatorItem]];
				[_statusMenu addItem:[self actionItemWithLabel:@"Refresh" action:@selector(refreshAction:)]];
			}
			[_statusMenu addItem:[NSMenuItem separatorItem]];
			[_statusMenu addItem:[self actionItemWithLabel:@"Preferences..." action:@selector(editPreferencesAction:)]];
			[_statusMenu addItem:[self actionItemWithLabel:@"About..." action:@selector(aboutAction:)]];
			[_statusMenu addItem:[self actionItemWithLabel:@"Quit" action:@selector(quitAction:)]];

		}
		
		[_statusItem setImage:_statusItemImage];

		NSAttributedString *statusItemTitle = [[NSAttributedString alloc]
											   initWithString:[NSString stringWithFormat:@"%d", instancesCount]
											   attributes:_statusItemAttributes];
		[_statusItem setAttributedTitle:statusItemTitle];
		[statusItemTitle release];
	}

	[_statusMenu setMinimumWidth:100];
}

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
	[titleBlock setContentWidth:MESSAGE_TABLE_WIDTH type:NSTextBlockAbsoluteValueType];
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

- (NSMenuItem *)errorMessageItemWithTitle:(NSString *)title
{
	return [self messageItemWithTitle:title image:[NSImage imageNamed:@"Error.png"]];
}

- (NSMenuItem *)notificationMessageItemWithTitle:(NSString *)title
{
	return [self messageItemWithTitle:title image:[NSImage imageNamed:@"Notification.png"]];
}

- (NSMenuItem *)instanceItemWithInstance:(EC2Instance *)instance
{
	NSMenuItem *menuItem = [[[NSMenuItem alloc] initWithTitle:@"" action:NULL keyEquivalent:@""] autorelease];
	[menuItem setIndentationLevel:1];

	NSString *nameTag = instance.nameTag;
	NSAttributedString *attributedTitle = nil;

	// set item title to Name tag if present, otherwise to Instance ID
	if (nameTag)
		attributedTitle = [[[NSAttributedString alloc] initWithString:nameTag attributes:_taggedInstanceAttributes] autorelease];
	else
		attributedTitle = [[[NSAttributedString alloc] initWithString:instance.instanceId attributes:_untaggedInstanceAttributes] autorelease];

	menuItem.attributedTitle = attributedTitle;

	// set item image according to instance state
	NSImage *stateImage = nil;
	switch (instance.instanceState.code) {
		case EC2_INSTANCE_STATE_RUNNING:
			stateImage = [NSImage imageNamed:@"InstanceStateRunning.png"];
			break;
		case EC2_INSTANCE_STATE_STOPPED:
			stateImage = [NSImage imageNamed:@"InstanceStateStopped.png"];
			break;
		case EC2_INSTANCE_STATE_TERMINATED:
			stateImage = [NSImage imageNamed:@"InstanceStateTerminated.png"];
			break;
		default:
			stateImage = [NSImage imageNamed:@"InstanceStateOther.png"];
			break;
	}
	[menuItem setImage:stateImage];
	
	// set item submenu
	[menuItem setSubmenu:[self submenuForInstance:instance]];
	
	// set item represented object to instance id
	[menuItem setRepresentedObject:instance.instanceId];

	return menuItem;
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
	[table setContentWidth:INSTANCE_INFO_TABLE_WIDTH type:NSTextBlockAbsoluteValueType];
	[table setHidesEmptyCells:NO];

	NSTextTableBlock *labelBlock = [[[NSTextTableBlock alloc] initWithTable:table startingRow:0 rowSpan:1 startingColumn:0 columnSpan:1] autorelease];
	[labelBlock setContentWidth:INSTANCE_INFO_LABEL_COLUMN_WIDTH type:NSTextBlockAbsoluteValueType];

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

- (NSMenuItem *)actionItemWithLabel:(NSString *)label action:(SEL)action
{
	NSMutableAttributedString *attributedTitle = [[[NSMutableAttributedString alloc]
												   initWithString:label
												   attributes:_actionItemAttributes] autorelease];

	NSMenuItem *menuItem = [[[NSMenuItem alloc] initWithTitle:@"" action:action keyEquivalent:@""] autorelease];
	[menuItem setIndentationLevel:1];
	[menuItem setAttributedTitle:attributedTitle];
	[menuItem setTarget:self];

	return menuItem;
}

#pragma mark -
#pragma mark Submenu

- (NSMenu *)submenuForInstance:(EC2Instance *)instance
{
	NSMenu *menu = [[[NSMenu alloc] initWithTitle:@""] autorelease];
	[menu setDelegate:self];
	[menu setTitle:instance.instanceId];
	[menu setShowsStateColumn:NO];

	[self refreshSubmenu:menu forInstance:instance];

	return menu;
}

- (void)refreshSubmenu:(NSMenu *)menu forInstance:(EC2Instance *)instance
{
	DataSource *dataSource = [DataSource sharedInstance];

	[menu removeAllItems];

	[menu addItem:[self titleItemWithTitle:@"INSTANCE DETAILS"]];
	[menu addItem:[self infoItemWithLabel:@"Instance ID" info:instance.instanceId action:@selector(copyToPasteboardAction:) tooltip:@"Copy Instance ID"]];
	[menu addItem:[self infoItemWithLabel:@"Image ID" info:instance.imageId action:@selector(copyToPasteboardAction:) tooltip:@"Copy Image ID"]];
	[menu addItem:[self infoItemWithLabel:@"instance Type" info:instance.instanceType action:NULL tooltip:nil]];
	[menu addItem:[self infoItemWithLabel:@"Monitoring" info:instance.monitoring.monitoringType action:NULL tooltip:nil]];
	[menu addItem:[self infoItemWithLabel:@"Launched At" info:[instance.launchTime localizedString] action:NULL tooltip:nil]];
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

			[menu addItem:[self infoItemWithLabel:@"Maximum" info:[NSString stringWithFormat:@"%.1f%%", maxCPUUtilization] action:NULL tooltip:nil]];
			[menu addItem:[self infoItemWithLabel:@"Minimum" info:[NSString stringWithFormat:@"%.1f%%", minCPUUtilization] action:NULL tooltip:nil]];
			[menu addItem:[self infoItemWithLabel:@"Average" info:[NSString stringWithFormat:@"%.1f%%", avgCPUUtilization] action:NULL tooltip:nil]];
		}
	}

	if (instance.instanceState.code == EC2_INSTANCE_STATE_RUNNING) {
		[menu addItem:[NSMenuItem separatorItem]];
		[menu addItem:[self actionItemWithLabel:@"Connect..." action:@selector(connectToInstanceAction:)]];
	}
	
//	[menu addItem:[NSMenuItem separatorItem]];
//	[menu addItem:[self actionItemWithLabel:@"Restart..." action:@selector(connectToInstanceAction:)]];
//	[menu addItem:[self actionItemWithLabel:@"Terminate..." action:@selector(connectToInstanceAction:)]];
}

#pragma mark -
#pragma mark DataSource operations and notifications

- (void)refresh:(NSString *)instanceId
{
	DataSource *dataSource = [DataSource sharedInstance];
	
	if ([instanceId length] > 0)
		[dataSource refreshInstance:instanceId];
	else
		[dataSource refresh];
}

- (void)refreshCompleted:(NSNotification *)notification
{
	[self performSelector:@selector(refreshMenu:)
			   withObject:notification
			   afterDelay:0.
				  inModes:[NSArray arrayWithObjects:NSDefaultRunLoopMode, NSEventTrackingRunLoopMode, nil]];
//	[self performSelectorOnMainThread:@selector(refreshMenu:) withObject:notification waitUntilDone:NO];
//	[self performSelectorOnMainThread:@selector(refreshMenu:) withObject:notification waitUntilDone:NO modes:[NSArray arrayWithObject:NSEventTrackingRunLoopMode]];
//	[self refreshMenu:notification];
}

#pragma mark -
#pragma mark Menu delegate

- (void)menuWillOpen:(NSMenu *)menu
{
	NSString *instanceId = [menu title];
	
	if (![instanceId length]) {
		// refresh all instances only if "Refresh on menu open" is checked
		if ([[NSUserDefaults standardUserDefaults] isRefreshOnMenuOpen]) {
			
			for (NSMenuItem *menuItem in [_statusMenu itemArray]) {
				if ([menuItem representedObject]) {
					[menuItem setImage:[NSImage imageNamed:@"InstanceStateRefreshing.png"]];
					[menuItem setSubmenu:nil];
				}
			}
			
			// we're about to do manual refresh, disable background refresh timer
			[self disableRefreshTimer];
			[self refresh:nil];
		}
	}
	else {
		// refresh selected instance
		[self refresh:instanceId];
	}
}

- (void)menuDidClose:(NSMenu *)menu
{
	NSString *instanceId = [menu title];
	
	if (![instanceId length]) {
		// status menu closed, enable background refresh
		[self enableRefreshTimer];
	}
}

#pragma mark -
#pragma mark User Defaults

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
	
	// setup AWS credentials, these are stored in from Keychain
	NSString *awsAccessKeyId = nil;
	NSString *awsSecretAccessKey = nil;
	
	GetAWSCredentials(&awsAccessKeyId, &awsSecretAccessKey);
	
	if (awsAccessKeyId) {
		[options setObject:awsAccessKeyId forKey:kAWSAccessKeyIdOption];
		[awsAccessKeyId release];
	}
	if (awsSecretAccessKey) {
		[options setObject:awsSecretAccessKey forKey:kAWSSecretAccessKeyOption];
		[awsSecretAccessKey release];
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
	[self refresh:nil];
}

#pragma mark -
#pragma mark Background refresh timer

- (void)enableRefreshTimer
{
	TBTrace(@"enabling background refresh");

	NSTimeInterval refreshInterval = [[NSUserDefaults standardUserDefaults] refreshInterval];
	
	if (refreshInterval > 0) {
		_refreshTimer = [NSTimer scheduledTimerWithTimeInterval:refreshInterval
														 target:self
													   selector:@selector(timerRefresh:)
													   userInfo:nil
														repeats:YES];
		[_refreshTimer retain];
	}
}

- (void)disableRefreshTimer
{
	TBTrace(@"disabling background refresh");

	[_refreshTimer invalidate];
	TBRelease(_refreshTimer);
}

- (void)timerRefresh:(NSTimer *)timer
{
	[self refresh:nil];
}

#pragma mark -
#pragma mark Workspace notifications

- (void)workspaceSessionDidBecomeActive:(NSNotification *)notification
{
	TBTrace(@"performing refresh and enabling background refresh timer");
	
	[self refresh:nil];
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
	[self performSelector:@selector(refresh:) withObject:nil afterDelay:15.0];
}

#pragma mark -
#pragma mark Actions

- (void)nopAction:(id)sender
{
}

- (void)refreshAction:(id)sender
{
	[self refresh:nil];
}

- (void)quitAction:(id)sender
{
	[[NSApplication sharedApplication] terminate:self];
}

- (void)editPreferencesAction:(id)sender
{
	NSString *preferencesBundlePath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"Contents/Helpers/ElasticPreferences.app"];
	[[NSWorkspace sharedWorkspace] launchApplication:preferencesBundlePath];
}

- (void)copyToPasteboardAction:(id)sender
{
	NSMenuItem *menuItem = (NSMenuItem *)sender;
	NSPasteboard *pasteBoard = [NSPasteboard generalPasteboard];
	[pasteBoard setString:[menuItem representedObject] forType:NSStringPboardType];
}

- (void)connectToInstanceAction:(id)sender
{
	NSMenuItem *menuItem = (NSMenuItem *)sender;
	NSString *instanceId = [[menuItem menu] title];
	EC2Instance *instance = [[DataSource sharedInstance] instance:instanceId];
	
	if (instance) {
		NSString *sshPrivateKeyFile = [[NSUserDefaults standardUserDefaults] sshPrivateKeyFile];
		NSString *sshUserName = [[NSUserDefaults standardUserDefaults] sshUserName];
		NSString *cmd = @"ssh";
		
		if (sshPrivateKeyFile)
			cmd = [cmd stringByAppendingFormat:@" -i \'%@\'", sshPrivateKeyFile];
		
		if (sshUserName)
			cmd = [cmd stringByAppendingFormat:@" %@@%@", sshUserName, instance.ipAddress];
		else
			cmd = [cmd stringByAppendingFormat:@"%@", instance.ipAddress];
		
		cmd = [NSString stringWithFormat:
			   @"tell application \"Terminal\" to do script \"%@\"",
			   cmd];

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

@end
