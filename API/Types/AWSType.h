//
//  AWSType.h
//  Elastics
//
//  Created by Dmitri Goutnik on 01/12/2010.
//  Copyright 2010 Tundra Bot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TBXML.h"

@interface AWSType : NSObject {
@private
	AWSType		*_parent;
}

+ (id)typeFromXMLElement:(TBXMLElement *)element parent:(AWSType *)parent;
- (id)initFromXMLElement:(TBXMLElement *)element parent:(AWSType *)parent;

@property (nonatomic, retain, readonly) AWSType *parent;

+ (NSString *)stringFromBool:(BOOL)value;

// protected

- (NSArray *)parseElement:(TBXMLElement *)element asArrayOf:(Class)class;

@end
