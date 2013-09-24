//
//  STTimeline.m
//  SteelTwitter
//
//  Created by Alexander on 19.09.13.
//  Copyright (c) 2013 NASA. All rights reserved.
//

#import "STTimeline.h"
#import "STTokenManager.h"
#import "STErrorHandler.h"

@implementation STTimeline

- (id) init {
    
    if (self = [super init]) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateFormat:STTimeFormatString];
        
        _tokenManager = [STTokenManager sharedInstance];
        _tokenManager.delegate = self;
        
        _timeline = [[NSMutableData alloc] init];
    }
    return self;
}


#pragma mark - <STTokenManagerDelegate>

- (void) didReceiveToken:(NSError*) error {
    if (!error) {
        [self receiveTimeline];
    } else {
        [self.delegate didReceiveNewTimeline:error];
    }
}

#pragma mark - pulbic
- (void) receiveTimeline {
    
    if (!(_tokenManager.token)) {
        [_tokenManager receiveTokenAndNotify:YES];
        return;
    }
    NSString *urlStringWithParams = [NSString stringWithFormat:@"%@count=%d&screen_name=%@", STTimelineAPIAddress, STNumberOfTweets, STTargetScreenName];
    NSURL *requestURL = [NSURL URLWithString: urlStringWithParams];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: requestURL];
    
    [request setHTTPMethod: @"GET"];
    [request addValue:[@"Bearer " stringByAppendingString:_tokenManager.token] forHTTPHeaderField:@"Authorization"];
    
    [NSURLConnection connectionWithRequest:request delegate:self];
}


#pragma mark - <NSURLConnectionDelegate>

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
    NSInteger status = [httpResponse statusCode];
    
    switch (status) {
        case 200:
            [_timeline setLength:0];            
            break;
            
        case 401:
            // When authorization failed, recieve new token
            [_tokenManager receiveTokenAndNotify:YES];
            break;
            
        default:
        {
            NSMutableDictionary* details = [NSMutableDictionary dictionary];
            [details setValue:[NSString stringWithFormat: @"Connection Error - status %d", status] forKey:NSLocalizedDescriptionKey];
            NSError *error = [NSError errorWithDomain:@"connection" code:status userInfo:details];
            [self.delegate didReceiveNewTimeline:error];
        }
            break;
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
        [_timeline appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [self.delegate didReceiveNewTimeline:error];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [self parseTweetsFromData:_timeline];
}


#pragma mark - private

- (void) parseTweetsFromData: (NSData*) data
{
    NSMutableArray *tweets = [[NSMutableArray alloc] init];
    NSError* error;
    NSDictionary *rawTweets = [NSJSONSerialization JSONObjectWithData: data options: 0 error: &error];
    
    if (!error) {
        for (NSDictionary *rawTweet in rawTweets) {
            NSString *text = [rawTweet valueForKey:STTweetTextKey];
            
            NSDate *postingDate = [_dateFormatter dateFromString:[rawTweet valueForKey:STTweetCreationTimeKey]];
            NSDictionary *tweet = [NSDictionary dictionaryWithObjectsAndKeys: text, STTweetTextKey, postingDate, STTweetCreationTimeKey, nil];
            
            [self.delegate onTweet:tweet];
            [tweets addObject:tweet];
        }
    }    
    [self.delegate didReceiveNewTimeline:error];
}



@end


