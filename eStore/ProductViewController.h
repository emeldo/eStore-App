//
// ProductViewController.h
// eComm Mobile
//
// Created by VQL Developer on 3/4/13.
// Copyright (c) 2013 CLH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Product.h"
#import "POHorizontalList.h"
#import "DYRateView.h"

@interface ProductViewController : UIViewController <UIScrollViewDelegate,UITableViewDelegate, UITableViewDataSource, POHorizontalListDelegate, DYRateViewDelegate>


@property (weak, nonatomic) IBOutlet UILabel *productNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *productIDLabel;
@property (weak, nonatomic) IBOutlet UILabel *currencyLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *productColor;

@property (strong, nonatomic) IBOutlet UIWebView *webviewName;

@property (strong, nonatomic) IBOutlet UIPageControl *pageControl;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;     //Product Images
@property (strong, nonatomic) IBOutlet UIScrollView *scrollViewSize; //Sizes

@property (strong, nonatomic) IBOutlet UIImageView *productImage;
@property (strong, nonatomic) IBOutlet UITableView *tableView;      //Other Colors
@property (strong, nonatomic) IBOutlet UIView *rateView;


@property (nonatomic, strong) Product *product;
@property (nonatomic, strong) NSMutableDictionary *selected_refinements;
@property (nonatomic, strong) NSMutableDictionary *arrays;


@end