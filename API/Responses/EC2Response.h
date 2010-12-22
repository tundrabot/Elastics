//
//  EC2Response.h
//  Cloudwatch
//
//  Created by Dmitri Goutnik on 01/12/2010.
//  Copyright 2010 Tundra Bot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TBXML.h"
#import "EC2Type.h"

@interface EC2Response : EC2Type {
	NSString	*_requestId;
}

@property (nonatomic, retain, readonly) NSString *rootElementName;
@property (nonatomic, retain, readonly) NSString *requestId;

+ (id)responseWithRootXMLElement:(TBXMLElement *)rootElement;
- (id)initWithRootXMLElement:(TBXMLElement *)rootElement;

// protected

- (void)_parseXMLElement:(TBXMLElement *)element;

@end
