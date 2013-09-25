//
//  STViewController.m
//  SteelTwitter
//
//  Created by Alexander on 19.09.13.
//  Copyright (c) 2013 NASA. All rights reserved.
//

#import "STViewController.h"
#import "STErrorHandler.h"
#import "STDataManager.h"
#import "STTimeline.h"
#import "Tweet.h"

@interface STViewController ()

@end

@implementation STViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _dateFormatter = [[NSDateFormatter alloc] init];
    [_dateFormatter setDateFormat:STTimeFormatString];
    
    _dataManager = [STDataManager sharedInstance];
    _dataManager.managedObjectContext = self.managedObjectContext;
    
    _timeline = [[STTimeline alloc] init];
    _timeline.delegate = _dataManager;
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.tintColor = [UIColor blackColor];
    [self.refreshControl addTarget:self action:@selector(refresh)forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
    
    _tweetEntity = [NSEntityDescription entityForName:@"Tweet" inManagedObjectContext:self.managedObjectContext];
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


#pragma mark - Status Bar

// Fix overlay of status bar. No status bar - no overlay.
- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[[self.fetchedResultsController sections] objectAtIndex:section] numberOfObjects];
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath: (NSIndexPath *) indexPath {
    Tweet *managedObject = [[self.fetchedResultsController fetchedObjects] objectAtIndex: indexPath.row];
    NSString *text = managedObject.text;
    NSString *time = [_dateFormatter stringFromDate:managedObject.created_at];
    
    UIFont *timeFont = [UIFont fontWithName:@"Helvetica" size:14.0];
	UIFont *textFont = [UIFont fontWithName:@"Helvetica" size:18.0];
	CGSize constraintSize = CGSizeMake(280.0f, MAXFLOAT);
    
    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:text attributes:@{NSFontAttributeName: textFont}];
    NSAttributedString *attributedTime = [[NSAttributedString alloc] initWithString:time attributes:@{NSFontAttributeName: timeFont}];
    
    CGRect textRect = [attributedText boundingRectWithSize:constraintSize options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    CGRect timeRect = [attributedTime boundingRectWithSize:constraintSize options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    
    // Take into account appended row with time
	return textRect.size.height + timeRect.size.height;
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
    return NO;
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
    
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
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


#pragma mark - refresh controller

- (void)refresh {
    [_timeline receiveTimeline];
    [self.refreshControl endRefreshing];
}

@end
