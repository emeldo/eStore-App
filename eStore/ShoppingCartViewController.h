//
//  ShoppingCartViewController.h
//  eStore
//
//  Created by VQL Developer on 5/8/13.
//  Copyright (c) 2013 VQL. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShoppingCartViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate, UIActionSheetDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) IBOutlet UITableView *tableView;


@end
