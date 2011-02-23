//
//  ElasticsAppDelegate.h
//  Elastics
//
//  Created by Dmitri Goutnik on 21/12/2010.
//  Copyright 2010 Tundra Bot. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ValidateReceipt.h"

@interface ElasticsAppDelegate : NSObject <NSApplicationDelegate, NSMenuDelegate> {
@private
	NSStatusItem	*_statusItem;
	NSMenu			*_statusMenu;
	NSTimer			*_refreshTimer;
	NSPanel			*_aboutPanel;
	NSTextField		*_aboutVersionLabel;
	NSTextField		*_aboutCopyrightLabel;
}

@property (nonatomic, assign) IBOutlet NSPanel *aboutPanel;
@property (nonatomic, assign) IBOutlet NSTextField *aboutVersionLabel;
@property (nonatomic, assign) IBOutlet NSTextField *aboutCopyrightLabel;

@end
