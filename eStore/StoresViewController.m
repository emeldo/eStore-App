//
//  StoresViewController.m
//  eStore
//
//  Created by VQL Developer on 4/17/13.
//  Copyright (c) 2013 CLH. All rights reserved.
//

#import "StoresViewController.h"

@interface StoresViewController ()

@end

@implementation StoresViewController 


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
	
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Stores_main_bg.png"]];
    
    UIView *storesDetailsView = (UIView *)[self.view viewWithTag:1];
    storesDetailsView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Stores_details_bg.png"]];
    storesDetailsView.hidden = NO;
    
    UIView *storesLocationView = (UIView *)[self.view viewWithTag:2];
    storesLocationView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Stores_details_bg.png"]];
    storesLocationView.hidden = YES;
    
    
    UIFont *font = [UIFont boldSystemFontOfSize:18.0f];
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                font, UITextAttributeFont,
                                [UIColor whiteColor], UITextAttributeTextColor,
                                nil];
    [self.segmentedControl setTitleTextAttributes:attributes forState:UIControlStateNormal];
    NSDictionary *highlightedAttributes = [NSDictionary dictionaryWithObject:[UIColor blackColor] forKey:UITextAttributeTextColor];
    [self.segmentedControl setTitleTextAttributes:highlightedAttributes forState:UIControlStateHighlighted];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewDidUnload {
    //[self setProductImage:nil];
    //[self setImageView:nil];
    [self setSegmentedControl:nil];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    UINavigationBar *naviBarObj = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, 841, 44)];
    [self.view addSubview:naviBarObj];
    
    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelButtonPressed)];
    UINavigationItem *navigItem = [[UINavigationItem alloc] initWithTitle:@"Stores"];
    
    navigItem.rightBarButtonItem = cancelItem;
    
    naviBarObj.items = [NSArray arrayWithObjects: navigItem,nil];
    naviBarObj.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:UITextAttributeTextColor];
    
    self.view.superview.bounds = CGRectMake(0, 0, 841, 558);
    
    UIColor *background = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"Stores_main_bg.png"]];
    self.view.backgroundColor = background;
    
}


- (void) cancelButtonPressed{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)menuChanged:(id)sender {
    
    UIView *storesDetailsView = (UIView *)[self.view viewWithTag:1];
    UIView *storesLocationView = (UIView *)[self.view viewWithTag:2];
    
    if ([sender selectedSegmentIndex] == 0)
    {
        storesDetailsView.hidden = NO;
        storesLocationView.hidden = YES;
    }
    else
    {
        storesLocationView.hidden = NO;
        storesDetailsView.hidden = YES;
    }
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
    return 10;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSString *cellIdentifier = [[NSString alloc] init];
    
    cellIdentifier = @"StoresCell";
      
    
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    
    return cell;
}



@end
