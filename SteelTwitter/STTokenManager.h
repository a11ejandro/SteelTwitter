//
//  STTokenManager.h
//  SteelTwitter
//
//  Created by Alexander on 19.09.13.
//  Copyright (c) 2013 NASA. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol STTokenManagerDelegate <NSObject>

- (void) didReceiveToken:(NSError*)error;

@end

@interface STTokenManager : NSObject {
    NSMutableData *_timelineData;
    NSString *tokenCredentials;
    NSUserDefaults *userDefaults;
}

@property (weak, nonatomic) id <STTokenManagerDelegate> delegate;
@property(nonatomic, readonly) NSString *token;

- (void) receiveTokenAndNotify:(BOOL)notify;

+ (STTokenManager*) sharedInstance;

@end
