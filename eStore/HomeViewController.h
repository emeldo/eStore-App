//
//  HomeViewController.h
//  eStore
//
//  Created by HNL on 3/17/13.
//  Copyright (c) 2013 CLH. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomeViewController : UIViewController <UITextFieldDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate>

@property (strong, nonatomic) IBOutlet UITextField *searchBar;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) IBOutlet UIPageControl *pageControl;

@property (strong, nonatomic) IBOutlet UIView *leftMenu;
@property (strong, nonatomic) IBOutlet UIView *rightMenu;

- (IBAction)categorySelected:(id)sender;
- (IBAction)hideKeyboard;
- (IBAction)hideAndUnhide:(id)sender;
- (void)setFoo:(NSString *)bar;

@end
