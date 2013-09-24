//
//  STViewController.h
//  SteelTwitter
//
//  Created by Alexander on 19.09.13.
//  Copyright (c) 2013 NASA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STTimeline.h"
#import "STDataManager.h"

@interface STViewController : UITableViewController <NSFetchedResultsControllerDelegate> {
    NSDateFormatter *_dateFormatter;
    UIRefreshControl *_refreshControl;
    NSEntityDescription *_tweetEntity;
    NSFetchRequest *_tweetsFetchRequest;
    NSFetchRequest *_oldestTweetFetchRequest;
    STTimeline *_timeline;
    STDataManager *_dataManager;
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

@end