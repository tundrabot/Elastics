//
//  AppDelegate.h
//  ElasticsPreferences
//
//  Created by Dmitri Goutnik on 26/12/2010.
//  Copyright 2010 Tundra Bot. All rights reserved.
//

#import <Cocoa/Cocoa.h>

//@class KeychainController;

@interface AppDelegate : NSObject <NSApplicationDelegate> {
@private
    NSWindow			*_window;
	NSView				*_generalPane;
	NSView				*_advancedPane;
//	KeychainController	*_keychainController;
	NSTextField			*_awsAccessKeyIdField;
	NSTextField			*_keypairFileField;
	NSPanel				*_aboutPanel;
	NSTextField			*_aboutVersionLabel;
	NSTextField			*_aboutCopyrightLabel;
	NSPanel				*_accountPanel;
	NSTextField			*_accountPanelAccessKeyIdField;
	NSTextField			*_accountPanelSecretAccessKeyField;
	NSButton			*_accountPanelSaveButton;
}

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSView *generalPane;
@property (assign) IBOutlet NSView *advancedPane;
//@property (assign) IBOutlet KeychainController *keychainController;
@property (assign) IBOutlet NSTextField *keypairFileField;
@property (assign) IBOutlet NSPanel *aboutPanel;
@property (assign) IBOutlet NSTextField *aboutVersionLabel;
@property (assign) IBOutlet NSTextField *aboutCopyrightLabel;
@property (assign) IBOutlet NSPanel *accountPanel;
@property (assign) IBOutlet NSButton *accountPanelSaveButton;
@property (assign) IBOutlet NSTextField *accountPanelAccessKeyIdField;
@property (assign) IBOutlet NSTextField *accountPanelSecretAccessKeyField;

- (IBAction)showGeneralPaneAction:(id)sender;
- (IBAction)showAdvancedPaneAction:(id)sender;
- (IBAction)addAccountAction:(id)sender;
- (IBAction)accountSheetSaveAction:(id)sender;
- (IBAction)accountSheetCancelAction:(id)sender;
- (IBAction)removeAccountAction:(id)sender;
- (IBAction)chooseKeypairAction:(id)sender;
- (IBAction)aboutAction:(id)sender;

@end
