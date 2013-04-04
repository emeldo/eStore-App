//
//  CommentsViewController.h
//  eStore
//
//  Created by VQL Developer on 4/4/13.
//  Copyright (c) 2013 CLH. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommentsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *CommentsTableView;
@property (nonatomic, strong) NSMutableArray  *Commenthits;

@end
