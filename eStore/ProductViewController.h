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
{
    NSMutableArray *itemArray;
    
    NSMutableArray *freeList;
    NSMutableArray *paidList;
    NSMutableArray *grossingList;
}




@property (weak, nonatomic) IBOutlet UILabel *productNameLabel;

@property (weak, nonatomic) IBOutlet UILabel *product_idLabel; // name of product_id
@property (weak, nonatomic) IBOutlet UILabel *linklabel; // link
@property (weak, nonatomic) IBOutlet UILabel *imagelabel; // image link
@property (weak, nonatomic) IBOutlet UILabel *currencylabel; // currency
@property (weak, nonatomic) IBOutlet UILabel *pricelabel; // price
@property (weak, nonatomic) IBOutlet UILabel *product_color; // color
@property (nonatomic, retain) IBOutlet UITextView *textView;// overview

@property (nonatomic, retain) IBOutlet UIWebView *webviewName;

@property (strong, nonatomic) IBOutlet UIPageControl *pageControl;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView; //scrollview
@property (strong, nonatomic) IBOutlet UIScrollView *scrollViewSize; //scrollview

@property (strong, nonatomic) IBOutlet UIImageView *productImage;
@property (nonatomic, retain) IBOutlet UITableView *tableView;// VISTA HORIZONTAL
@property (nonatomic, retain) IBOutlet UIView *rateView;// rate

@property (strong, nonatomic) IBOutlet UIButton *mybutton;



@property (nonatomic, strong) Product *product;





@end