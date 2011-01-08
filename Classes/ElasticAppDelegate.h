//
//  ElasticAppDelegate.h
//  Elastic
//
//  Created by Dmitri Goutnik on 21/12/2010.
//  Copyright 2010 Tundra Bot. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ElasticAppDelegate : NSObject <NSApplicationDelegate, NSMenuDelegate> {
@private
	NSStatusItem	*_statusItem;
	NSMenu			*_statusMenu;
	NSTimer			*_refreshTimer;
}

@end
