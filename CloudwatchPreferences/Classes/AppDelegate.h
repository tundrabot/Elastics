//
//  AppDelegate.h
//  CloudwatchPreferences
//
//  Created by Dmitri Goutnik on 26/12/2010.
//  Copyright 2010 Tundra Bot. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate> {
@private
    NSWindow		*_window;
	NSView			*_generalPane;
	NSView			*_advancedPane;
	NSTextField		*_awsAccessKeyIdField;
}

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSView *generalPane;
@property (assign) IBOutlet NSView *advancedPane;
@property (assign) IBOutlet NSTextField *awsAccessKeyIdField;

- (IBAction)showGeneralPaneAction:(id)sender;
- (IBAction)showAdvancedPaneAction:(id)sender;

@end
