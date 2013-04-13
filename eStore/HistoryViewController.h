//
//  HistoryViewController.h
//  eStore
//
//  Created by HNL on 4/8/13.
//  Copyright (c) 2013 CLH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DYRateView.h"

@interface HistoryViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, DYRateViewDelegate, NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end
