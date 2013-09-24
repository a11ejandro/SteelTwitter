//
//  STDataManager.m
//  SteelTwitter
//
//  Created by Alexander on 24.09.13.
//  Copyright (c) 2013 NASA. All rights reserved.
//

#import "STDataManager.h"

@implementation STDataManager

+ (STDataManager*) sharedInstance {
    static STTDataManager* sharedSingleton = nil;
    static dispatch_once_t predicate;
    dispatch_once( &predicate, ^{
        sharedSingleton = [ [ self alloc ] init ];
    });
    return sharedSingleton;
}



@end
