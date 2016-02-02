//
//  MMMainTableViewController.h
//  weather
//
//  Created by Petar Petrov on 28/01/2016.
//  Copyright © 2016 Petar Petrov. All rights reserved.
//

#import <UIKit/UIKit.h>

@import CoreData;

@interface MMMainTableViewController : UITableViewController

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultController;

@end
