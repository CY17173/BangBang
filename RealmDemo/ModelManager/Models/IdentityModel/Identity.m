//
//  Identity.m
//  RealmDemo
//
//  Created by haigui on 16/7/2.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "Identity.h"

@implementation Identity

MJExtensionCodingImplementation

- (instancetype)init
{
    self = [super init];
    if (self) {
        _firstUseSoft = YES;
        _accessToken = @"";
    }
    return self;
}

@end
