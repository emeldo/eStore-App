//
//  SettingsViewController.m
//  eStore
//
//  Created by VQL Developer on 4/17/13.
//  Copyright (c) 2013 CLH. All rights reserved.
//

#import "SettingsViewController.h"
#import "MBProgressHUD.h"
#import "CoreDataHelper.h"
#import "WCAlertView.h"
#import "Country.h"
#import "City.h"
#import "Stores.h"
#import "Settings.h"
#import "KGModal.h"

@interface SettingsViewController ()

@property (nonatomic, strong) NSArray *countries;
@property (nonatomic, strong) NSString *countrySelected;
@property (nonatomic, strong) NSArray *cities;
@property (nonatomic, strong) NSString *citySelected;
@property (nonatomic, strong) NSArray *stores;
@property (nonatomic, strong) NSString *storeSelected;
@property (strong, nonatomic) MBProgressHUD *HUD;
@property (nonatomic, strong) NSArray *settings;
@property (nonatomic, strong) UIToolbar *pickerToolbar;
@property (nonatomic, strong) UIBarButtonItem* btnDone;

-(void)createInputAccessoryView;

@end

@implementation SettingsViewController

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
    
    self.countryField.inputView = self.countryPicker;
    self.cityField.inputView = self.cityPicker;
    self.storeField.inputView = self.storePicker;
    [self createInputAccessoryView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    UINavigationBar *naviBarObj = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, 448, 44)];
    [self.view addSubview:naviBarObj];
    

    UIBarButtonItem *saveItem = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleDone target:self action:@selector(saveSettings)];
    UINavigationItem *navigItem = [[UINavigationItem alloc] initWithTitle:@"Settings"];
    

    navigItem.rightBarButtonItem = saveItem;
    
    self.view.superview.bounds = CGRectMake(0, 0, 448, 500);
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_sett_body.png"]];
    
    UIView *textBackgroundView = (UIView *)[self.view viewWithTag:1];
    textBackgroundView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"text_fields_bg"]];
    
    
    self.settings = [CoreDataHelper getObjectsForEntity:@"Settings" withSortKey:@"name" andSortAscending:YES andContext:self.managedObjectContext];
    
    if ([self.settings count] > 0) {
        Settings *settings = [self.settings objectAtIndex:0];
        
        self.nameField.text = settings.name;
        self.countryField.text = settings.country;
        self.cityField.text = settings.city;
        self.storeField.text = settings.store;
        self.storeSelected = settings.storeIdentifier;
        self.countrySelected = settings.countryIdentifier;
        self.citySelected = settings.city;
        
    } else {
        
        self.navigationItem.leftBarButtonItem = nil;
        
        UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 280, 280)];
        CGRect welcomeLabelRect = contentView.bounds;
        welcomeLabelRect.origin.y = 20;
        welcomeLabelRect.size.height = 20;
        UIFont *welcomeLabelFont = [UIFont boldSystemFontOfSize:17];
        UILabel *welcomeLabel = [[UILabel alloc] initWithFrame:welcomeLabelRect];
        welcomeLabel.text = @"Welcome to adidas MOB";
        welcomeLabel.font = welcomeLabelFont;
        welcomeLabel.textColor = [UIColor whiteColor];
        welcomeLabel.textAlignment = NSTextAlignmentCenter;
        welcomeLabel.backgroundColor = [UIColor clearColor];
        welcomeLabel.shadowColor = [UIColor blackColor];
        welcomeLabel.shadowOffset = CGSizeMake(0, 1);
        [contentView addSubview:welcomeLabel];
        
        CGRect infoLabelRect = CGRectInset(contentView.bounds, 5, 5);
        infoLabelRect.origin.y = CGRectGetMaxY(welcomeLabelRect)+5;
        infoLabelRect.size.height -= CGRectGetMinY(infoLabelRect);
        UILabel *infoLabel = [[UILabel alloc] initWithFrame:infoLabelRect];
        infoLabel.text = @"MOB (Mobile Back Office) give you the opportunity to check the inventory of our adidas products in each of our stores. Scan the product tag or write the product code and then select the size that you are looking for. Before proceeding fill out the following information about you.";
        infoLabel.numberOfLines = 10;
        infoLabel.textColor = [UIColor whiteColor];
        infoLabel.textAlignment = NSTextAlignmentCenter;
        infoLabel.backgroundColor = [UIColor clearColor];
        infoLabel.shadowColor = [UIColor blackColor];
        infoLabel.shadowOffset = CGSizeMake(0, 1);
        [contentView addSubview:infoLabel];`