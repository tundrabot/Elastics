//
//  AWSResponse.h
//  Elastics
//
//  Created by Dmitri Goutnik on 01/12/2010.
//  Copyright 2010 Tundra Bot. All rights reserved.
//

#import "AWSType.h"

@interface AWSResponse : AWSType

+ (id)responseWithRootXMLElement:(TBXMLElement *)rootElement;
- (id)initWithRootXMLElement:(TBXMLElement *)rootElement;

// protected

- (void)parseElement:(TBXMLElement *)element;

@end
