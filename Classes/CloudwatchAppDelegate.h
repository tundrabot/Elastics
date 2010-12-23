//
//  CloudwatchAppDelegate.h
//  Cloudwatch
//
//  Created by Dmitri Goutnik on 21/12/2010.
//  Copyright 2010 Tundra Bot. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface CloudwatchAppDelegate : NSObject <NSApplicationDelegate, NSMenuDelegate> {
	NSStatusItem		*_statusItem;
	NSMenu				*_statusMenu;
	BOOL				_isRefreshInProgress;
}

@end
