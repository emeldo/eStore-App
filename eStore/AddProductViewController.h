//
//  AddProductViewController.h
//  eStore
//
//  Created by VQL Developer on 5/7/13.
//  Copyright (c) 2013 VQL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Product.h"
#import "DYRateView.h"

@interface AddProductViewController : UIViewController<UITableViewDataSource, UITableViewDelegate,DYRateViewDelegate>

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) Product *product;
@property (strong, nonatomic) NSMutableArray *pageImages;
@property (strong, nonatomic) IBOutlet UIStepper *stepper;
@property (strong, nonatomic) IBOutlet UITextField *stepperfield;
@property (strong, nonatomic) IBOutlet UIButton *addCart;


- (IBAction)valueChanged:(UIStepper *)sender;
- (IBAction)addCartButton:(UIButton *)sender;

@end
