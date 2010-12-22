//
//  CloudwatchAppDelegate.m
//  Cloudwatch
//
//  Created by Dmitri Goutnik on 21/12/2010.
//  Copyright 2010 Tundra Bot. All rights reserved.
//

#import "CloudwatchAppDelegate.h"
#import "DataSource.h"

@interface CloudwatchAppDelegate ()
- (void)refreshCompleted:(NSNotification *)notification;
- (NSMenu *)submenuForInstance:(EC2Instance *)instance;
- (NSMenuItem *)actionItemWithLabel:(NSString *)label action:(SEL)action;
- (NSMenuItem *)submenuItemWithLabel:(NSString *)label info:(NSString *)info action:(SEL)action tooltip:(NSString *)tooltip;
- (void)refreshAction:(id)sender;
- (void)quitAction:(id)sender;
- (void)editPreferencesAction:(id)sender;
- (void)copyToPasteboardAction:(id)sender;
- (void)connectToInstanceAction:(id)sender;
@end

@implementation CloudwatchAppDelegate

static NSColor *_taggedInstanceColor;
static NSColor *_untaggedInstanceColor;
static NSColor *_actionItemColor;
static NSColor *_labelColumnColor;
static NSColor *_infoColumnColor;

static NSFont *_taggedInstanceFont;
static NSFont *_untaggedInstanceFont;
static NSFont *_actionItemFont;
static NSFont *_labelColumnFont;
static NSFont *_infoColumnFont;

static NSDictionary *_taggedInstanceAttributes;
static NSDictionary *_untaggedInstanceAttributes;
static NSDictionary *_actionItemAttributes;
static NSDictionary *_labelColumnAttributes;
static NSDictionary *_infoColumnAttributes;

+ (void)initialize
{
	if (!_taggedInstanceColor)		_taggedInstanceColor = [[NSColor blackColor] retain];
	if (!_untaggedInstanceColor)	_untaggedInstanceColor = [[NSColor blackColor] retain];
	if (!_actionItemColor)			_actionItemColor = [[NSColor blackColor] retain];
	if (!_labelColumnColor)			_labelColumnColor = [[NSColor grayColor] retain];
	if (!_infoColumnColor)			_infoColumnColor = [[NSColor blackColor] retain];
		
	if (!_taggedInstanceFont)		_taggedInstanceFont = [[NSFont boldSystemFontOfSize:13.0f] retain];
	if (!_untaggedInstanceFont)		_untaggedInstanceFont = [[NSFont systemFontOfSize:13.0f] retain];
	if (!_actionItemFont)			_actionItemFont = [[NSFont boldSystemFontOfSize:11.0f] retain];
	if (!_labelColumnFont)			_labelColumnFont = [[NSFont boldSystemFontOfSize:11.0f] retain];
	if (!_infoColumnFont)			_infoColumnFont = [[NSFont boldSystemFontOfSize:11.0f] retain];

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
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
	// set up status item menu
	_statusMenu = [[NSMenu alloc] initWithTitle:@""];
	
	// set up status item
	_statusItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:30.0] retain];
	[_statusItem setImage:[NSImage imageNamed:@"StatusItem.png"]];
	[_statusItem setMenu:_statusMenu];
	
	// set up pasteboard
	NSPasteboard *pasteBoard = [NSPasteboard generalPasteboard];
	[pasteBoard declareTypes:[NSArray arrayWithObject:NSStringPboardType] owner:self];
	
	// XXX
	[DataSource setDefaultRequestOptions:[NSDictionary dictionaryWithObjectsAndKeys:
										  @"AKIAJV4IYQPC6OFAH4PA", kAWSAccessKeyIdOption,
										  @"lN3doqRL9mRk4Y3oTcbXzHuJaMfteK7HZwIWc5+i", kAWSSecretAccessKeyOption,
										  nil]];

	// subscribe to data source notifications
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(refreshCompleted:)
												 name:kDataSourceAllRequestsCompletedNotification
											   object:[DataSource sharedInstance]];

	// perform initial refresh
	[self refreshAction:nil];
}

- (void)dealloc
{
	TB_RELEASE(_statusItem);
	TB_RELEASE(_statusMenu);
	[super dealloc];
}

- (void)refreshCompleted:(NSNotification *)notification
{
	if ([notification.name isEqualToString:kDataSourceAllRequestsCompletedNotification]) {
		
		// clear status menu
		[_statusMenu removeAllItems];
		
		// enumarate instances
		DataSource *dataSource = [DataSource sharedInstance];
		for (EC2Instance *instance in dataSource.instances) {
			// create menu item
			NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:@"" action:NULL keyEquivalent:@""];
			
			// set menu item title
			NSString *nameTag = instance.nameTag;
			NSAttributedString *attributedTitle = nil;
			
			if (nameTag)
				attributedTitle = [[[NSAttributedString alloc] initWithString:nameTag attributes:_taggedInstanceAttributes] autorelease];
			else
				attributedTitle = [[[NSAttributedString alloc] initWithString:instance.instanceId attributes:_untaggedInstanceAttributes] autorelease];

			menuItem.attributedTitle = attributedTitle;

			// set item image according to instance state
			switch (instance.instanceState.code) {
				case EC2_INSTANCE_STATE_RUNNING:
					menuItem.image = [NSImage imageNamed:@"InstanceStateRunning.png"];
					break;
				case EC2_INSTANCE_STATE_STOPPED:
					menuItem.image = [NSImage imageNamed:@"InstanceStateStopped.png"];
					break;
				case EC2_INSTANCE_STATE_TERMINATED:
					menuItem.image = [NSImage imageNamed:@"InstanceStateTerminated.png"];
					break;
				default:
					menuItem.image = [NSImage imageNamed:@"InstanceStateOther.png"];
					break;
			}
			
			// set item submenu
			menuItem.submenu = [self submenuForInstance:instance];
			
			// add menu item
			[_statusMenu addItem:menuItem];
			[menuItem release];
		}
		
		// add action menu items
		[_statusMenu addItem:[NSMenuItem separatorItem]];
		[_statusMenu addItem:[self actionItemWithLabel:@"Refresh" action:@selector(refreshAction:)]];
		[_statusMenu addItem:[NSMenuItem separatorItem]];
		[_statusMenu addItem:[self actionItemWithLabel:@"Preferences..." action:@selector(editPreferencesAction:)]];
		[_statusMenu addItem:[self actionItemWithLabel:@"Quit Cloudwatch" action:@selector(quitAction:)]];
		
		_isRefreshInProgress = NO;
	}
}

- (NSMenu *)submenuForInstance:(EC2Instance *)instance
{
	NSMenu *menu = [[NSMenu alloc] initWithTitle:@""];
	
	NSString *launchTimeString = [NSDateFormatter localizedStringFromDate:instance.launchTime
																dateStyle:NSDateFormatterMediumStyle
																timeStyle:NSDateFormatterShortStyle];
	
	[menu addItem:[self submenuItemWithLabel:@"Instance ID:" info:instance.instanceId action:@selector(copyToPasteboardAction:) tooltip:@"Copy Instance ID"]];
	[menu addItem:[self submenuItemWithLabel:@"Image ID:" info:instance.imageId action:@selector(copyToPasteboardAction:) tooltip:@"Copy Image ID"]];
	[menu addItem:[self submenuItemWithLabel:@"State:" info:instance.instanceState.name action:NULL tooltip:nil]];
	[menu addItem:[self submenuItemWithLabel:@"Launched At:" info:launchTimeString action:NULL tooltip:nil]];
	[menu addItem:[NSMenuItem separatorItem]];
	[menu addItem:[self submenuItemWithLabel:@"Public IP:" info:instance.ipAddress action:@selector(copyToPasteboardAction:) tooltip:@"Copy Public IP"]];
	[menu addItem:[self submenuItemWithLabel:@"Private IP:" info:instance.privateIpAddress action:@selector(copyToPasteboardAction:) tooltip:@"Copy Private IP"]];
	
	// add action menu items
	[menu addItem:[NSMenuItem separatorItem]];
	[menu addItem:[self actionItemWithLabel:@"Connect..." action:@selector(connectToInstanceAction:)]];

	return [menu autorelease];
}

- (NSMenuItem *)actionItemWithLabel:(NSString *)label action:(SEL)action
{
	NSMutableAttributedString *attributedTitle = [[[NSMutableAttributedString alloc] initWithString:label attributes:_actionItemAttributes] autorelease];
	
	NSMenuItem *menuItem = [[[NSMenuItem alloc] initWithTitle:@"" action:action keyEquivalent:@""] autorelease];
	menuItem.attributedTitle = attributedTitle;
	menuItem.target = self;
	
	return menuItem;
}

#define TABLE_WIDTH				220.f
#define LABEL_COLUMN_WIDTH		90.f

- (NSMenuItem *)submenuItemWithLabel:(NSString *)label info:(NSString *)info action:(SEL)action tooltip:(NSString *)tooltip
{
	NSTextTable *table = [[[NSTextTable alloc] init] autorelease];
	[table setNumberOfColumns:2];
	[table setLayoutAlgorithm:NSTextTableAutomaticLayoutAlgorithm];
	[table setContentWidth:TABLE_WIDTH type:NSTextBlockAbsoluteValueType];
	[table setHidesEmptyCells:NO];

	NSTextTableBlock *labelBlock = [[NSTextTableBlock alloc] initWithTable:table startingRow:0 rowSpan:1 startingColumn:0 columnSpan:1];
	[labelBlock setContentWidth:LABEL_COLUMN_WIDTH type:NSTextBlockAbsoluteValueType];

	NSTextTableBlock *infoBlock = [[NSTextTableBlock alloc] initWithTable:table startingRow:0 rowSpan:1 startingColumn:1 columnSpan:1];

	NSMutableParagraphStyle *labelParagraphStyle = [[[NSParagraphStyle defaultParagraphStyle] mutableCopy] autorelease];
	[labelParagraphStyle setAlignment:NSLeftTextAlignment];
	[labelParagraphStyle setTextBlocks:[NSArray arrayWithObject:labelBlock]];
	
	NSMutableParagraphStyle *infoParagraphStyle = [[[NSParagraphStyle defaultParagraphStyle] mutableCopy] autorelease];
	[infoParagraphStyle setAlignment:NSRightTextAlignment];
	[infoParagraphStyle setTextBlocks:[NSArray arrayWithObject:infoBlock]];

	NSMutableAttributedString *attributedTitle = [[[NSMutableAttributedString alloc] initWithString:@""] autorelease];

	NSUInteger textLength = [attributedTitle length];
	[attributedTitle replaceCharactersInRange:NSMakeRange(textLength, 0) withString:[NSString stringWithFormat:@"%@\n", (label ? label : @"")]];
	[attributedTitle setAttributes:_labelColumnAttributes range:NSMakeRange(textLength, [attributedTitle length] - textLength)];
	[attributedTitle addAttribute:NSParagraphStyleAttributeName value:labelParagraphStyle range:NSMakeRange(textLength, [attributedTitle length] - textLength)];

	textLength = [attributedTitle length];
	[attributedTitle replaceCharactersInRange:NSMakeRange(textLength, 0) withString:[NSString stringWithFormat:@"%@", (info ? info : @"")]];
	[attributedTitle setAttributes:_infoColumnAttributes range:NSMakeRange(textLength, [attributedTitle length] - textLength)];
	[attributedTitle addAttribute:NSParagraphStyleAttributeName value:infoParagraphStyle range:NSMakeRange(textLength, [attributedTitle length] - textLength)];

	NSMenuItem *menuItem = [[[NSMenuItem alloc] initWithTitle:@"" action:action keyEquivalent:@""] autorelease];
	menuItem.attributedTitle = attributedTitle;
	menuItem.target = self;
	menuItem.toolTip = tooltip;
	
	return menuItem;
}

#pragma mark -
#pragma mark Actions

- (void)refreshAction:(id)sender
{
	if (_isRefreshInProgress == NO) {
		_isRefreshInProgress = YES;
		[[DataSource sharedInstance] startAllRequests];
	}
}

- (void)quitAction:(id)sender
{
	[[NSApplication sharedApplication] terminate:self];
}

- (void)editPreferencesAction:(id)sender
{
}

- (void)copyToPasteboardAction:(id)sender
{
}

- (void)connectToInstanceAction:(id)sender
{
}

@end
