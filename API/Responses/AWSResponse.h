//
//  AWSResponse.h
//  Cloudwatch
//
//  Created by Dmitri Goutnik on 01/12/2010.
//  Copyright 2010 Tundra Bot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TBXML.h"
#import "EC2Type.h"

@interface AWSResponse : EC2Type

+ (id)responseWithRootXMLElement:(TBXMLElement *)rootElement;
- (id)initWithRootXMLElement:(TBXMLElement *)rootElement;

// protected

- (NSString *)_rootElementName;
- (void)_parseXMLElement:(TBXMLElement *)element;

@end
