//
//  STDataManager.h
//  SteelTwitter
//
//  Created by Alexander on 24.09.13.
//  Copyright (c) 2013 NASA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface STDataManager : NSObject <STTimelineDelegate>

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

+ (STDataManager*) sharedInstance;

@end
