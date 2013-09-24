//
//  STTimeline.h
//  SteelTwitter
//
//  Created by Alexander on 19.09.13.
//  Copyright (c) 2013 NASA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STTokenManager.h"

@protocol STTimelineDelegate <NSObject>

- (void) onTweet: (NSDictionary*) tweetDict;
- (void) didReceiveNewTimeline: (NSError*) error;

@end

@interface STTimeline : NSObject <STTokenManagerDelegate> {
    NSDateFormatter *_dateFormatter;
    NSMutableData *_timeline;
    STTokenManager *_tokenManager;
}

@property(weak, nonatomic) id <STTimelineDelegate> delegate;

- (void) receiveTimeline;

@end