//
//  CatalogViewController.h
//  eComm Mobile
//
//  Created by Axel De Leon on 2/28/13.
//  Copyright (c) 2013 CLH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DYRateView.h"

@interface CatalogViewController : UIViewController <UITableViewDataSource, UITableViewDelegate,
UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, DYRateViewDelegate, UISearchBarDelegate>

@property (strong, nonatomic) IBOutlet UIView *leftMenu;
@property (strong, nonatomic) IBOutlet UIView *rightMenu;
@property (strong, nonatomic) IBOutlet UITableView *menuTableView;
@property (strong, nonatomic) IBOutlet UITableView *productTableView;
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSString *searchQuery;
@property (strong, nonatomic) NSString *menuQuery;

@property (strong, nonatomic) IBOutlet UILabel *bread;
@property (strong, nonatomic) UILabel *rateLabel;


- (IBAction)hideAndUnhide:(id)sender;
- (IBAction)changeViews:(id)sender;

@end
