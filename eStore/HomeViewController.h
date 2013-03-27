//
//  HomeViewController.h
//  eStore
//
//  Created by Axel De Leon on 3/17/13.
//  Copyright (c) 2013 CLH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DYRateView.h"

@interface HomeViewController : UIViewController <UITextFieldDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, DYRateViewDelegate, UIScrollViewDelegate>

@property (strong, nonatomic) IBOutlet UITextField *searchBar;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) IBOutlet UIPageControl *pageControl;

- (IBAction)categorySelected:(id)sender;
- (IBAction)hideKeyboard;

@end
