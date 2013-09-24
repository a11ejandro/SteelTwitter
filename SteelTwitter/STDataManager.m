//
//  STDataManager.m
//  SteelTwitter
//
//  Created by Alexander on 24.09.13.
//  Copyright (c) 2013 NASA. All rights reserved.
//

#import "STDataManager.h"
#import "STErrorHandler.h"
#import "STTimeline.h"
#import "Tweet.h"

@implementation STDataManager

+ (STDataManager*) sharedInstance {
    static STDataManager* sharedSingleton = nil;
    static dispatch_once_t predicate;
    dispatch_once( &predicate, ^{
        sharedSingleton = [ [ self alloc ] init ];
    });
    return sharedSingleton;
}

- (void) setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext {
    _managedObjectContext = managedObjectContext;
    _tweetEntity = [NSEntityDescription entityForName:@"Tweet" inManagedObjectContext:_managedObjectContext];
}


#pragma mark - Core Data

- (void)saveContext {
    NSError *error = nil;
    if (_managedObjectContext) {
        if ([_managedObjectContext hasChanges] && ![_managedObjectContext save:&error]) {
            [STErrorHandler handleError:error];
        }
    }
}

- (NSFetchRequest*) tweetsFetchRequest {
    if (_tweetsFetchRequest == nil) {
		_tweetsFetchRequest = [[NSFetchRequest alloc] init];
		[_tweetsFetchRequest setEntity:_tweetEntity];
	}
	
	return _tweetsFetchRequest;
}

- (NSFetchRequest*) oldestTweetFetchRequest {
    if (_oldestTweetFetchRequest == nil) {
        _oldestTweetFetchRequest = [[NSFetchRequest alloc] init];
        [_oldestTweetFetchRequest setEntity:_tweetEntity];
        
        NSSortDescriptor *sortByCreatedAtDescriptor = [[NSSortDescriptor alloc] initWithKey:STTweetCreationTimeKey ascending:YES];
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortByCreatedAtDescriptor, nil];
        [_oldestTweetFetchRequest setSortDescriptors:sortDescriptors];
        [_oldestTweetFetchRequest setFetchLimit:1];
    }
    return _oldestTweetFetchRequest;
}


#pragma mark - <STTimelineDelegate>

- (void) onTweet:(NSDictionary *)tweetDict {
    NSFetchRequest *allTweetsFetchRequest = [self tweetsFetchRequest];
    NSFetchRequest *tweetToDeleteFetchRequest = [self oldestTweetFetchRequest];
    NSError *error;
    
    // 'created_at' attribute is used as unique identifier
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(created_at == %@)", [tweetDict objectForKey:STTweetCreationTimeKey]];
	[allTweetsFetchRequest setPredicate:predicate];
	
	NSArray *fetched = [self.managedObjectContext executeFetchRequest:allTweetsFetchRequest error:&error];
	if ([fetched count] == 0) { // it's a new tweet!
		
		
		// process new item
		Tweet *tweet = [NSEntityDescription insertNewObjectForEntityForName:@"Tweet" inManagedObjectContext:self.managedObjectContext];
		tweet.text = [tweetDict objectForKey:STTweetTextKey];
        tweet.created_at = [tweetDict objectForKey:STTweetCreationTimeKey];
        
        // delete the oldest item
        if ([self.managedObjectContext countForFetchRequest:allTweetsFetchRequest error:nil] > STNumberOfTweets) {
            Tweet *tweetToDelete = [[self.managedObjectContext executeFetchRequest:tweetToDeleteFetchRequest error:nil] objectAtIndex: 0];
            [self.managedObjectContext deleteObject:tweetToDelete];
        }
    }
}

- (void) didReceiveNewTimeline: (NSError*) error {
    if (error) {
        [STErrorHandler handleError:error];
    } else {
        NSError *saveError = nil;
        [self.managedObjectContext save: &saveError];
        if (saveError) {
            [STErrorHandler handleError:saveError];
        }
    }
}




@end
