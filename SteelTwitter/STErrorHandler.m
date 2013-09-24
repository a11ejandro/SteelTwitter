//
//  STErrorHandler.m
//  SteelTwitter
//
//  Created by Alexander on 20.09.13.
//  Copyright (c) 2013 NASA. All rights reserved.
//

#import "STErrorHandler.h"

@implementation STErrorHandler

+ (void)handleError:(NSError *)error {
	NSLog(@"error: %@", error);
    
	NSString *msg = [NSString stringWithFormat:@"%@", [error localizedDescription]];
	UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:msg delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
	[alertView show];
}

@end
