//
//  STViewController.m
//  SteelTwitter
//
//  Created by Alexander on 19.09.13.
//  Copyright (c) 2013 NASA. All rights reserved.
//

#import "STViewController.h"
#import "STErrorHandler.h"
#import "STTimeline.h"
#import "Tweet.h"

@interface STViewController ()

@end

@implementation STViewController


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _dateFormatter = [[NSDateFormatter alloc] init];
    [_dateFormatter setDateFormat:STTimeFormatString];
    
    _timeline = [[STTimeline alloc] init];
    _timeline.delegate = self;
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.tintColor = [UIColor blackColor];
    [self.refreshControl addTarget:self action:@selector(refresh)forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
    
    _tweetEntity = [NSEntityDescription entityForName:@"Tweet" inManagedObjectContext:_managedObjectContext];
}


#pragma mark - View lifecycle

- (void)viewDidAppear:(BOOL)animated {
    [_timeline receiveTimeline];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[[self.fetchedResultsController sections] objectAtIndex:section] numberOfObjects];
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath: (NSIndexPath *) indexPath {
    Tweet *managedObject = [[self.fetchedResultsController fetchedObjects] objectAtIndex: indexPath.row];
    NSString *text = managedObject.text;
    
	UIFont *cellFont = [UIFont fontWithName:@"Helvetica" size:18.0];
	CGSize constraintSize = CGSizeMake(280.0f, MAXFLOAT);
    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:text attributes:@{NSFontAttributeName: cellFont}];
    
    CGRect rect = [attributedText boundingRectWithSize:constraintSize options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    
    // Take into account appended row with time
	return rect.size.height + 30;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    Tweet *managedTweet = [[self.fetchedResultsController fetchedObjects] objectAtIndex: indexPath.row];
    
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.text = managedTweet.text;
    cell.detailTextLabel.text = [_dateFormatter stringFromDate:managedTweet.created_at];
    
    return cell;
}


- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return NO;
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


- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:_tweetEntity];
    
    [fetchRequest setFetchBatchSize:STNumberOfTweets];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:STTweetCreationTimeKey ascending:NO];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:_managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    aFetchedResultsController.delegate = self;
    _fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
        
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return _fetchedResultsController;
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    // In the simplest, most efficient, case, reload the table view.
    [self.tableView reloadData];
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
	
	NSArray *fetched = [_managedObjectContext executeFetchRequest:allTweetsFetchRequest error:&error];
	if ([fetched count] == 0) { // it's a new tweet!
		
		
		// process new item
		Tweet *tweet = [NSEntityDescription insertNewObjectForEntityForName:@"Tweet" inManagedObjectContext:_managedObjectContext];
		tweet.text = [tweetDict objectForKey:STTweetTextKey];
        tweet.created_at = [tweetDict objectForKey:STTweetCreationTimeKey];
        
        // delete the oldest item
        if ([_managedObjectContext countForFetchRequest:allTweetsFetchRequest error:nil] > STNumberOfTweets) {
            Tweet *tweetToDelete = [[_managedObjectContext executeFetchRequest:tweetToDeleteFetchRequest error:nil] objectAtIndex: 0];
            [self.managedObjectContext deleteObject:tweetToDelete];
        }
    }
}

- (void) didReceiveNewTimeline: (NSError*) error {
    if (error) {
        [STErrorHandler handleError:error];
    } else {
        NSError *saveError = nil;
        [_managedObjectContext save: &saveError];
        if (saveError) {
            [STErrorHandler handleError:saveError];
        }
    }
   [self.refreshControl endRefreshing];
}


#pragma mark - refresh controller

- (void)refresh {
    [_timeline receiveTimeline];
}

@end
