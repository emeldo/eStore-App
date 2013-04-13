//
//  CommentsViewController.h
//  eStore
//
//  Created by HNL on 4/4/13.
//  Copyright (c) 2013 CLH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Product.h"

@interface CommentsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *CommentsTableView;
@property (strong, nonatomic) NSMutableArray *pageImages;
@property (nonatomic, strong) NSMutableArray  *Commenthits;
@property (nonatomic, strong) Product *product;

@end
