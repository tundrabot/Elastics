//
//  PreferencesController.h
//  Cloudwatch
//
//  Created by Dmitri Goutnik on 25/12/2010.
//  Copyright 2010 Tundra Bot. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PreferencesController : NSWindowController {
@private
	NSView		*_generalPane;
	NSView		*_advancedPane;
}

@property (nonatomic, retain) IBOutlet NSView *generalPane;
@property (nonatomic, retain) IBOutlet NSView *advancedPane;

- (IBAction)showGeneralPaneAction:(id)sender;

@end
