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
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewDidUnload {
    //[self setProductImage:nil];
    //[self setImageView:nil];
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
