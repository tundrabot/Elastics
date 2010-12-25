//
//  PreferencesController.m
//  Cloudwatch
//
//  Created by Dmitri Goutnik on 25/12/2010.
//  Copyright 2010 Tundra Bot. All rights reserved.
//

#import "PreferencesController.h"

@implementation PreferencesController

@synthesize generalPane = _generalPane;
@synthesize advancedPane = _advancedPane;

- (void)dealloc
{
	[_generalPane release];
	[_advancedPane release];
	[super dealloc];
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
#pragma mark Actions

- (IBAction)showGeneralPaneAction:(id)sender
{
	NSToolbar *toolbar = [[self window] toolbar];
	[toolbar setSelectedItemIdentifier:[[[toolbar items] objectAtIndex:0] itemIdentifier]];
	
	NSView *contentView = [[self window] contentView];
	[_generalPane setFrame:[contentView bounds]];
	
	if ([_advancedPane superview] != nil)
		[[_advancedPane animator] removeFromSuperview];
	
	[[contentView animator] addSubview:_generalPane];
}

@end
