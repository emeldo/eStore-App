//
//  CommentsViewController.m
//  eStore
//
//  Created by VQL Developer on 4/4/13.
//  Copyright (c) 2013 CLH. All rights reserved.
//

#import "CommentsViewController.h"
#import "Comments.h"

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
        
    return [self.Commenthits count];
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSString *cellIdentifier = [[NSString alloc] init];
    cellIdentifier = @"DetailCell";
           
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
   
    Comments *Comment = [self.Commenthits objectAtIndex:indexPath.row];
   
    
    UILabel *NickName = (UILabel *)[cell viewWithTag:1];
    UILabel *Title = (UILabel *)[cell viewWithTag:2];
    UILabel *filters = (UILabel *)[cell viewWithTag:3];
    UILabel *ReviewText = (UILabel *)[cell viewWithTag:4];
    
    NickName.text = Comment.UserNickname;
    //Title.text = Comment.Title;
    
    NSLog(@" %@",Comment.ReviewText);

    if (Comment.ReviewText != [NSNull null]){
        ReviewText.text = Comment.ReviewText;
    }else{
        ReviewText.text = @"";

    }
    
    if (Comment.Title != [NSNull null]){
        Title.text = Comment.Title;
    }else{
        Title.text = @"";
        
    }
    
    //filters.text = Comment.UserLocation;
             
       
    
    return cell;
}


@end
