//
//  STAppDelegate.h
//  SteelTwitter
//
//  Created by Alexander on 19.09.13.
//  Copyright (c) 2013 NASA. All rights reserved.
//

#import <UIKit/UIKit.h>

@class STViewController;

@interface STAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, retain) STViewController *viewController;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
