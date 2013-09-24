//
//  Constants.m
//  SteelReader
//
//  Created by Alexander on 13.09.13.
//  Copyright (c) 2013 NASA. All rights reserved.
//

#import "Constants.h"

@implementation Constants

int const  STNumberOfTweets = 10;
NSString* const STTargetScreenName = @"ladygaga";

NSString* const STTimelineAPIAddress = @"https://api.twitter.com/1.1/statuses/user_timeline.json?";
NSString* const STConsumerKey = @"wyxCds5XTstrA3Bexd8K4g";
NSString* const STConsumerSecret = @"wUYxCJqXmhO8KpYKD91A3xbTIPqqjV3UuQQXOnaRdM";

NSString* const STTokenAddress = @"https://api.twitter.com/oauth2/token";
NSString* const STInvalidateTokenAddress = @"https://api.twitter.com/oauth2/invalidate_token";
NSString* const STContentTypeInTokenRequest = @"application/x-www-form-urlencoded;charset=UTF-8";
NSString* const STHTTPBodyInTokenRequest = @"grant_type=client_credentials";

NSString* const STTimeFormatString = @"eee MMM dd HH:mm:ss ZZZZ yyyy";
NSString* const STTweetCreationTimeKey = @"created_at";
NSString* const STTweetTextKey = @"text";

@end
