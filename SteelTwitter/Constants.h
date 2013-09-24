//
//  Constants.h
//  SteelReader
//
//  Created by Alexander on 13.09.13.
//  Copyright (c) 2013 NASA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Constants : NSObject

extern const int STNumberOfTweets;

extern NSString* const STTargetScreenName;

extern NSString* const STTimelineAPIAddress;
extern NSString* const STConsumerKey;
extern NSString* const STConsumerSecret;

extern NSString* const STTokenAddress;
extern NSString* const STInvalidateTokenAddress;
extern NSString* const STContentTypeInTokenRequest;
extern NSString* const STHTTPBodyInTokenRequest;

extern NSString* const STTimeFormatString;
extern NSString* const STTweetCreationTimeKey;
extern NSString* const STTweetTextKey;


@end
