//
//  EC2Type.h
//  Cloudwatch
//
//  Created by Dmitri Goutnik on 01/12/2010.
//  Copyright 2010 Tundra Bot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TBXML.h"


@interface EC2Type : NSObject {
@private
	EC2Type		*_parent;
}

+ (id)typeFromXMLElement:(TBXMLElement *)element parent:(EC2Type *)parent;
- (id)initFromXMLElement:(TBXMLElement *)element parent:(EC2Type *)parent;

@property (nonatomic, retain, readonly) EC2Type *parent;

+ (NSString *)stringFromDate:(NSDate *)value;
+ (NSString *)stringFromBool:(BOOL)value;
+ (NSDate *)dateFromString:(NSString *)dateString;

// protected

- (NSArray *)_parseXMLElement:(TBXMLElement *)element asArrayOf:(Class)class;

@end
