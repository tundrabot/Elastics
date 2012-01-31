//
//  AppDelegate.h
//  ElasticsPreferences
//
//  Created by Dmitri Goutnik on 26/12/2010.
//  Copyright 2010 Tundra Bot. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AccountsManager.h"

@interface AppDelegate : NSObject <NSApplicationDelegate, NSTextFieldDelegate> {
@private
    NSWindow			*_window;
	NSView				*_generalPane;
	NSView				*_regionsPane;
	NSView				*_connectionsPane;
	AccountsManager		*_accountsManager;
	NSArrayController	*_accountsController;
	NSTableView			*_accountsTableView;
	NSTextField			*_sshPortField;
	NSPanel				*_aboutPanel;
	NSTextField			*_aboutVersionLabel;
	NSTextField			*_aboutCopyrightLabel;
	NSPanel				*_accountPanel;
	NSTextField			*_accountPanelNameField;
	NSTextField			*_accountPanelAccessKeyIdField;
	NSTextField			*_accountPanelSecretAccessKeyField;
	NSTextField			*_accountPanelSshPrivateKeyFileField;
	NSTextField			*_accountPanelSshUserNameField;
	NSTextField			*_accountPanelSshPortField;
	NSButton			*_accountPanelSaveButton;
	NSInteger			_accountActionType;
    NSString            *_lastValidSshPortValue;
    BOOL                _regionUSEastEnabled;
    BOOL                _regionUSWestNorthCaliforniaEnabled;
    BOOL                _regionUSWestOregonEnabled;
    BOOL                _regionEUEnabled;
    BOOL                _regionAsiaPacificSingaporeEnabled;
    BOOL                _regionAsiaPacificJapanEnabled;
    BOOL                _regionSouthAmericaSaoPauloEnabled;
    BOOL                _regionUSGovCloudEnabled;
}

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSView *generalPane;
@property (assign) IBOutlet NSView *regionsPane;
@property (assign) IBOutlet NSView *connectionsPane;
@property (assign) IBOutlet AccountsManager *accountsManager;
@property (assign) IBOutlet NSArrayController *accountsController;
@property (assign) IBOutlet NSTableView *accountsTableView;
@property (assign) IBOutlet NSTextField *sshPortField;
@property (assign) IBOutlet NSPanel *aboutPanel;
@property (assign) IBOutlet NSTextField *aboutVersionLabel;
@property (assign) IBOutlet NSTextField *aboutCopyrightLabel;
@property (assign) IBOutlet NSPanel *accountPanel;
@property (assign) IBOutlet NSButton *accountPanelSaveButton;
@property (assign) IBOutlet NSTextField *accountPanelNameField;
@property (assign) IBOutlet NSTextField *accountPanelAccessKeyIdField;
@property (assign) IBOutlet NSTextField *accountPanelSecretAccessKeyField;
@property (assign) IBOutlet NSTextField *accountPanelSshPrivateKeyFileField;
@property (assign) IBOutlet NSTextField *accountPanelSshUserNameField;
@property (assign) IBOutlet NSTextField *accountPanelSshPortField;

@property (nonatomic, assign, getter=isRegionUSEastEnabled) BOOL regionUSEastEnabled;
@property (nonatomic, assign, getter=isRegionUSWestNorthCaliforniaEnabled) BOOL regionUSWestNorthCaliforniaEnabled;
@property (nonatomic, assign, getter=isRegionUSWestOregonEnabled) BOOL regionUSWestOregonEnabled;
@property (nonatomic, assign, getter=isRegionEUEnabled) BOOL regionEUEnabled;
@property (nonatomic, assign, getter=isRegionAsiaPacificSingaporeEnabled) BOOL regionAsiaPacificSingaporeEnabled;
@property (nonatomic, assign, getter=isRegionAsiaPacificJapanEnabled) BOOL regionAsiaPacificJapanEnabled;
@property (nonatomic, assign, getter=isRegionSouthAmericaSaoPauloEnabled) BOOL regionSouthAmericaSaoPauloEnabled;
@property (nonatomic, assign, getter=isRegionUSGovCloudEnabled) BOOL regionUSGovCloudEnabled;

- (IBAction)showGeneralPaneAction:(id)sender;
- (IBAction)showRegionsPaneAction:(id)sender;
- (IBAction)showConnectionsPaneAction:(id)sender;
- (IBAction)addAccountAction:(id)sender;
- (IBAction)editAccountAction:(id)sender;
- (IBAction)removeAccountAction:(id)sender;
- (IBAction)accountSheetSaveAction:(id)sender;
- (IBAction)accountSheetCancelAction:(id)sender;
- (IBAction)chooseDefaultKeypairAction:(id)sender;
- (IBAction)chooseAccountKeypairAction:(id)sender;
- (IBAction)toggleRegionEnabledAction:(id)sender;
- (IBAction)aboutAction:(id)sender;
- (IBAction)elasticsWebsiteAction:(id)sender;
- (IBAction)sendFeeedbackAction:(id)sender;

@end
