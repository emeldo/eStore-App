//
//  StoresViewController.h
//  eStore
//
//  Created by VQL Developer on 4/17/13.
//  Copyright (c) 2013 CLH. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StoresViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *storesTableView;
@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentedControl;

- (IBAction)menuChanged:(id)sender;

@end
