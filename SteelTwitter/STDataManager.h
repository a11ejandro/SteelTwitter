//
//  STDataManager.h
//  SteelTwitter
//
//  Created by Alexander on 24.09.13.
//  Copyright (c) 2013 NASA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STTimeline.h"

@interface STDataManager : NSObject <STTimelineDelegate> {
    NSFetchRequest *_tweetsFetchRequest;
    NSFetchRequest *_oldestTweetFetchRequest;
    NSEntityDescription *_tweetEntity;
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

+ (STDataManager*) sharedInstance;

@end
