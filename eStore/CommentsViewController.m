//
//  CommentsViewController.m
//  eStore
//
//  Created by HNL on 4/4/13.
//  Copyright (c) 2013 CLH. All rights reserved.
//

#import "CommentsViewController.h"
#import "Comments.h"
#import "Product.h"
#import "DYRateView.h"

@interface CommentsViewController ()

@end

@implementation CommentsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
  
    
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewWillAppear:(BOOL)animated
{
    UINavigationBar *naviBarObj = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, 600, 44)];
    [self.view addSubview:naviBarObj];
    
    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelButtonPressed)];
    UINavigationItem *navigItem = [[UINavigationItem alloc] initWithTitle:@"Ratings and Comments"];
    
    navigItem.rightBarButtonItem = cancelItem;
    
    naviBarObj.items = [NSArray arrayWithObjects: navigItem,nil];
    naviBarObj.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:UITextAttributeTextColor];
    
    self.view.superview.bounds = CGRectMake(0, 0, 600, 546);
}


- (void) cancelButtonPressed{
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Table View DataSource


- (BOOL)tableView:(UITableView *)tableView canCollapseSection:(NSInteger)section
{
    return YES;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
        
    return [self.Commenthits count]+1;
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSString *cellIdentifier = [[NSString alloc] init];
    
    if(indexPath.row == 0){
       cellIdentifier = @"HeaderCell";
    }else{
       cellIdentifier = @"DetailCell";
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    if(indexPath.row == 0){
        UIImageView *imageView = (UIImageView *)[cell viewWithTag:1];
        UILabel *ProductName = (UILabel *)[cell viewWithTag:2];
        UILabel *ProductCode = (UILabel *)[cell viewWithTag:3];
        UIView *Ratespace = (UIView *)[cell viewWithTag:4];
        
        //UIView *productBackgroundView = (UIView *)[self.view viewWithTag:5];
       // productBackgroundView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"r&c_product_holder.png"]];
        
        ProductName.text =  self.product.product_name;
        ProductCode.text =  self.product.product_id;
        imageView.image =  [self.pageImages objectAtIndex:0];
        
        
        DYRateView *rateView = [[DYRateView alloc] initWithFrame:CGRectMake(0, 0, 150, 20) fullStar:[UIImage imageNamed:@"StarFull.png"] emptyStar:[UIImage imageNamed:@"StarEmpty.png"]];
        rateView.padding = 5;
        rateView.rate = 3.3;
        rateView.alignment = RateViewAlignmentLeft;
        [Ratespace addSubview:rateView];
    
    }else{
   
    Comments *Comment = [self.Commenthits objectAtIndex:indexPath.row-1];
   
    
    UILabel *NickName = (UILabel *)[cell viewWithTag:11];
    UILabel *Title = (UILabel *)[cell viewWithTag:12];
    UILabel *Datetime = (UILabel *)[cell viewWithTag:13];
    UILabel *ReviewText = (UILabel *)[cell viewWithTag:14];
    UIView *Ratespace = (UIView *)[cell viewWithTag:15];
    UILabel *From = (UILabel *)[cell viewWithTag:16];
//    UILabel *Age = (UILabel *)[cell viewWithTag:17];
//    UILabel *Sex = (UILabel *)[cell viewWithTag:18];
    
    NickName.text = Comment.UserNickname;
    //Title.text = Comment.Title;
    
    NSLog(@" %@",Comment.ReviewText);

    if (Comment.ReviewText != [NSNull null]){
        ReviewText.text = Comment.ReviewText;
    }else{
        ReviewText.text = @"No Review";

    }
    
    if (Comment.Title != [NSNull null]){
        Title.text = Comment.Title;
    }else{
        Title.text = @"No Title";
        
    }
    
    
    if (Comment.LastModeratedTime != [NSNull null]){
        Datetime.text = Comment.LastModeratedTime;
    }else{
        Datetime.text = @"No Title";
    }
    
    if (Comment.UserLocation != [NSNull null]){
       From.text = Comment.UserLocation;
    }else{
        From.text = @"";
    }
    
    
    
    DYRateView *rateView = [[DYRateView alloc] initWithFrame:CGRectMake(0, 0, 150, 20) fullStar:[UIImage imageNamed:@"StarFull.png"] emptyStar:[UIImage imageNamed:@"StarEmpty.png"]];
    rateView.padding = 5;
    rateView.rate = [Comment.Rating floatValue];
    rateView.alignment = RateViewAlignmentLeft;
    [Ratespace addSubview:rateView];

    }
    return cell;
}


@end
