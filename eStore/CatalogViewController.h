//
//  CatalogViewController.h
//  eComm Mobile
//
//  Created by HNL on 2/28/13.
//  Copyright (c) 2013 CLH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DYRateView.h"
#import "DACircularProgressView.h"

@interface CatalogViewController : UIViewController <UITableViewDataSource, UITableViewDelegate,
UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, DYRateViewDelegate, UISearchBarDelegate>

@property (strong, nonatomic) IBOutlet UIView *leftMenu;
@property (strong, nonatomic) IBOutlet UIView *rightMenu;
@property (strong, nonatomic) IBOutlet UITableView *menuTableView;
@property (strong, nonatomic) IBOutlet UITableView *productTableView;
@property (strong, nonatomic) IBOutlet UITableView *selectionTableView;

@property (nonatomic, strong) NSMutableDictionary *selected_refinements;
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSString *searchQuery;
@property (strong, nonatomic) NSString *menuQuery;
@property (strong, nonatomic) NSString *titleQuery;

@property (strong, nonatomic) IBOutlet UILabel *bread;
@property (strong, nonatomic) UILabel *rateLabel;
@property (strong, nonatomic) NSTimer *timer;

@property (strong, nonatomic) IBOutlet UIStepper *stepper;
@property (strong, nonatomic) IBOutlet UILabel *progressLabel;
@property (strong, nonatomic) IBOutlet UILabel *qtyShoppingCart;
@property (strong, nonatomic) IBOutlet UISwitch *continuousSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *indeterminateSwitch;


- (IBAction)hideAndUnhide:(id)sender;
- (IBAction)changeViews:(id)sender;
- (IBAction)CleanAllPressed:(id)sender;

@end
