//
//  MJComments.m
//  eStore
//
//  Created by VQL Developer on 3/20/13.
//  Copyright (c) 2013 CLH. All rights reserved.
//

#import "MJComments.h"

@implementation MJComments
@synthesize Commenthits;


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Setting Main Background
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_sett_body.png"]];
    
    //Setting Navigation Bar
    //UIImageView* img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo_adidas_02.png"]];
    //self.navigationItem.titleView = img;
    
}

@end
