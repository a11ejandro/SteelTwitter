//
//  STTokenManager.m
//  SteelTwitter
//
//  Created by Alexander on 19.09.13.
//  Copyright (c) 2013 NASA. All rights reserved.
//

#import "STTokenManager.h"
#import "STErrorHandler.h"
#import "Base64.h"

@implementation STTokenManager

+ (STTokenManager *) sharedInstance {
    
    static STTokenManager* sharedSingleton = nil;
    static dispatch_once_t predicate;
    dispatch_once( &predicate, ^{
        sharedSingleton = [ [ self alloc ] init ];
    });
    return sharedSingleton;
}

- (id) init {
    if (self = [super init]) {
        _userDefaults = [NSUserDefaults standardUserDefaults];
        _timelineData = [[NSMutableData alloc] init];
        if ([_userDefaults valueForKey:@"tokenCredentials"]) {
            _tokenCredentials = [_userDefaults stringForKey:@"tokenCredentials"];
        } else {
            _tokenCredentials = [self calculateTokenCredentials];
            [_userDefaults setObject:_tokenCredentials forKey:@"tokenCredentials"];
        }
    }
    return self;
}


#pragma mark - public

- (void) receiveTokenAndNotify:(BOOL)notify {
    
    NSMutableURLRequest *request = [self prepareTokenRequestHeader];
    
    NSURL *requestUrl = [NSURL URLWithString: STTokenAddress];
    NSData *httpBody = [STHTTPBodyInTokenRequest dataUsingEncoding:NSUTF8StringEncoding];
    
    [request setURL: requestUrl];
    [request setHTTPBody:httpBody];
    
    [NSURLConnection connectionWithRequest:request delegate:self];
}


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
    NSInteger status = [httpResponse statusCode];
    
    if (status == 200) {
        [_timelineData setLength:0];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [_timelineData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [self.delegate didReceiveToken:error];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSError *error = nil;
    NSJSONSerialization *JSONData = [NSJSONSerialization JSONObjectWithData:_timelineData options: 0 error: &error];
    
    if(!error) {
        self.token = [JSONData valueForKey:@"access_token"];
    }
    [self.delegate didReceiveToken:error];
}



#pragma mark - private

- (NSMutableURLRequest *) prepareTokenRequestHeader {
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    [request setHTTPMethod: @"POST"];
    [request setValue:[@"Basic " stringByAppendingString:_tokenCredentials] forHTTPHeaderField:@"Authorization"];
    [request setValue: STContentTypeInTokenRequest forHTTPHeaderField:@"Content-Type"];
    
    return request;
}

- (NSString *) calculateTokenCredentials {
    
    NSString *consumerKeyRFC1738 = [STConsumerKey stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
    NSString *consumerSecretRFC1738 = [STConsumerSecret stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
    NSString *concatKeySecret = [NSString stringWithFormat: @"%@:%@", consumerKeyRFC1738, consumerSecretRFC1738];
    NSString *concatKeySecretBase64 = [concatKeySecret base64EncodedString];
    
    return concatKeySecretBase64;
}


@end

