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
    UINavigationBar *naviBarObj = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, 500, 44)];
    [self.view addSubview:naviBarObj];
    

    UIBarButtonItem *saveItem = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleDone target:self action:@selector(saveSettings)];
    UINavigationItem *navigItem = [[UINavigationItem alloc] initWithTitle:@"Settings"];
    

    navigItem.rightBarButtonItem = saveItem;
    
    self.view.superview.bounds = CGRectMake(0, 0, 500, 420);
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_sett_body"]];
    
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
        
        UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelButtonPressed)];
        
        navigItem.leftBarButtonItem = cancelItem;
        
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
        [contentView addSubview:infoLabel];
        [[KGModal sharedInstance] showWithContentView:contentView andAnimated:YES];
        
    }
    
    
    UIImageView *userSpace = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Space.png"]];
    UIImageView *userIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"User_Icon.png"]];
    [self.nameField  setRightView:userIcon];
    [self.nameField  setRightViewMode:UITextFieldViewModeAlways];
    [self.nameField  setLeftView:userSpace];
    [self.nameField  setLeftViewMode:UITextFieldViewModeAlways];
    
    UIImageView *countrySpace = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Space.png"]];
    UIImageView * countryIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Country_Icon.png"]];
    [self.countryField  setRightView:countryIcon];
    [self.countryField  setRightViewMode:UITextFieldViewModeAlways];
    [self.countryField  setLeftView:countrySpace];
    [self.countryField  setLeftViewMode:UITextFieldViewModeAlways];
    
    UIImageView *citySpace = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Space.png"]];
    UIImageView *cityIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Country_Icon.png"]];
    [self.cityField  setRightView:cityIcon];
    [self.cityField  setRightViewMode:UITextFieldViewModeAlways];
    [self.cityField  setLeftView:citySpace];
    [self.cityField  setLeftViewMode:UITextFieldViewModeAlways];
    
    UIImageView *storeSpace = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Space.png"]];
    UIImageView *storeIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Store_Icon.png"]];
    [self.storeField  setRightView:storeIcon];
    [self.storeField  setRightViewMode:UITextFieldViewModeAlways];
    [self.storeField  setLeftView:storeSpace];
    [self.storeField  setLeftViewMode:UITextFieldViewModeAlways];

    
    naviBarObj.items = [NSArray arrayWithObjects: navigItem,nil];
    naviBarObj.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:UITextAttributeTextColor];
    
    self.countryField.inputView = self.countryPicker;
    self.cityField.inputView = self.cityPicker;
    self.storeField.inputView = self.storePicker;
    
    [self createInputAccessoryView];
    
    
}



- (void)saveSettings {
    
    if (self.nameField.text.length == 0 || self.countryField.text.length == 0 || self.cityField.text.length == 0 || self.storeField.text.length == 0 ) {
        WCAlertView *alert = [[WCAlertView alloc] initWithTitle:@"Missing Information" message:@"Before to save your information you need to fill all the fields correctly" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        alert.style = WCAlertViewStyleBlack;
        [alert show];
    } else {
        self.HUD = [[MBProgressHUD alloc] initWithView:self.view];
        [self.navigationController.view addSubview:self.HUD];
        self.HUD.labelText = @"Saving information";
        [self.HUD showWhileExecuting:@selector(savingInformation) onTarget:self withObject:nil animated:YES];
    }
}

- (void)savingInformation {
    
    [CoreDataHelper deleteAllObjectsForEntity:@"Settings" andContext:self.managedObjectContext];
    sleep(2);
    Settings *setting = [NSEntityDescription insertNewObjectForEntityForName:@"Settings" inManagedObjectContext:self.managedObjectContext];
    
    setting.name = self.nameField.text;
    setting.country = self.countryField.text;
    setting.countryIdentifier = self.countrySelected;
    setting.city = self.cityField.text;
    setting.store = self.storeField.text;
    setting.storeIdentifier = self.storeSelected;
    
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Whoops, couldn't save changes: %@", [error localizedDescription]);
    }
    
    self.HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
    self.HUD.mode = MBProgressHUDModeCustomView;
    self.HUD.labelText = @"Information Saved";
    sleep(1);
    [self dismissViewControllerAnimated:YES completion:nil];
    
}


- (IBAction)dimissKeyword:(id)sender {
    [self.nameField resignFirstResponder];
    [self.countryField resignFirstResponder];
    [self.cityField resignFirstResponder];
    [self.storeField resignFirstResponder];
    
    if (self.nameField.text.length == 0) self.nameField.placeholder = @"Full Name";
    if (self.countryField.text.length == 0) self.countryField.placeholder = @"Country";
    if (self.cityField.text.length == 0) self.cityField.placeholder = @"City";
    if (self.storeField.text.length == 0) self.storeField.placeholder = @"Store";
}


- (void)createInputAccessoryView
{
    self.pickerToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44)];
    self.pickerToolbar.barStyle = UIBarStyleBlackTranslucent;
    self.pickerToolbar.tintColor = [UIColor darkGrayColor];
    
    UIBarButtonItem* flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    self.btnDone = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(donePicker:)];
    
    [self.pickerToolbar setItems:[NSArray arrayWithObjects: flexSpace, self.btnDone, nil] animated:NO];
    
    [self.countryField setInputAccessoryView:self.pickerToolbar];
    [self.cityField setInputAccessoryView:self.pickerToolbar];
    [self.storeField setInputAccessoryView:self.pickerToolbar];
}


-(void)donePicker:(id)sender
{
    if (self.countryField.isFirstResponder) {
        [self.countryField resignFirstResponder];
        if ([self.countryField.text isEqualToString:@""] || ![self.countryPicker selectedRowInComponent:0] != 0) {
            Country *country = [self.countries objectAtIndex:0];
            
            
            
            if (![country.identifier isEqualToString:self.countrySelected]) {
                self.cityField.text = @"";
                self.storeField.text = @"";
            }
            self.countryField.text = country.name;
            self.countrySelected = country.identifier;
        }
    }
    
    if (self.cityField.isFirstResponder) {
        [self.cityField resignFirstResponder];
        
        if ([self.cityField.text isEqualToString:@""] || ![self.cityPicker selectedRowInComponent:0] != 0) {
            City *city = [self.cities objectAtIndex:0];
            
            if (![city.name isEqualToString:self.citySelected]) {
                self.storeField.text = @"";
            }
            self.cityField.text = city.name;
            self.citySelected = city.name;
        }
    }
    
    if (self.storeField.isFirstResponder) {
        [self.storeField resignFirstResponder];
        
        if ([self.storeField.text isEqualToString:@""] || ![self.storePicker selectedRowInComponent:0] != 0) {
            Stores *store = [self.stores objectAtIndex:0];
            self.storeField.text = store.name;
            self.storeSelected = store.identifier;
        }
    }
    
    if (self.countryField.text.length == 0) self.countryField.placeholder = @"Country";
    if (self.cityField.text.length == 0) self.cityField.placeholder = @"City";
    if (self.storeField.text.length == 0) self.storeField.placeholder = @"Store";
    
    
}

- (void) cancelButtonPressed{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidUnload {
    [self setTableView:nil];
    [super viewDidUnload];
}


#pragma mark - TextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if (self.nameField == textField) {
        if (self.nameField.text.length == 0) {
            [self.nameField resignFirstResponder];
            self.nameField.placeholder = @"Full Name";
        } 
    }
    
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (self.nameField == textField) {
        self.nameField.placeholder = @"";
    }
    
    if (self.countryField == textField) {
        self.countryField.placeholder = @"";
        self.countries = [CoreDataHelper getObjectsForEntity:@"Country" withSortKey:@"name" andSortAscending:YES andContext:self.managedObjectContext];
        [self.countryPicker reloadAllComponents];
        [self.tableView reloadData];
        self.countryPicker.hidden = NO;
    }
    
    if (self.cityField == textField) {
        if (self.countryField.text.length == 0) {
            WCAlertView *alert = [[WCAlertView alloc] initWithTitle:@"Missing Information" message:@"To select a city you need to select a country before" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            alert.style = WCAlertViewStyleBlack;
            [alert show];
            return NO;
        } else {
            self.cityField.placeholder = @"";
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(country == %@)", self.countrySelected];
            self.cities = [CoreDataHelper searchObjectsForEntity:@"City" withPredicate:predicate andSortKey:@"name" andSortAscending:YES andContext:self.managedObjectContext];
            [self.cityPicker reloadAllComponents];
            self.cityPicker.hidden = NO;
        }
    }
    
    if (self.storeField == textField) {
        if (self.cityField.text.length == 0) {
            WCAlertView *alert = [[WCAlertView alloc] initWithTitle:@"Missing Information" message:@"To select a store you need to select a city before" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            alert.style = WCAlertViewStyleBlack;
            [alert show];
            return NO;
        } else {
            self.storeField.placeholder = @"";
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(city == %@) && (company == %@)", self.citySelected, self.countrySelected];
            self.stores = [CoreDataHelper searchObjectsForEntity:@"Stores" withPredicate:predicate andSortKey:@"name" andSortAscending:YES andContext:self.managedObjectContext];
            [self.storePicker reloadAllComponents];
            self.storePicker.hidden = NO;
        }
    }
    
    return YES;
}


#pragma mark - Picker Data Source Methods
        
        - (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
            return 1;
        }
        
        - (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
            if (pickerView == self.countryPicker) {
                return [self.countries count];
            }
            
            if (pickerView == self.storePicker) {
                return [self.stores count];
            }
            
            if (pickerView == self.cityPicker) {
                return [self.cities count];
            }
            
            return 1;
        }
        
#pragma mark Picker Delegate Methods
        - (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
            if (pickerView == self.countryPicker) {
                Country *country = [self.countries objectAtIndex:row];
                return country.name;
            }
            
            if (pickerView == self.storePicker) {
                Stores *store = [self.stores objectAtIndex:row];
                return store.name;
            }
            
            if (pickerView == self.cityPicker) {
                City *city = [self.cities objectAtIndex:row];
                return city.name;
            }
            
            return @"";
        }
        
        - (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
            if (pickerView == self.countryPicker) {
                Country *country = [self.countries objectAtIndex:row];
                
                if (![country.identifier isEqualToString:self.countrySelected]) {
                    self.cityField.text = @"";
                    self.storeField.text = @"";
                }
                self.countryField.text = country.name;
                self.countrySelected = country.identifier;
            }
            
            if (pickerView == self.storePicker) {
                Stores *store = [self.stores objectAtIndex:row];
                self.storeField.text = store.name;
                self.storeSelected = store.identifier;
            }
            
            if (pickerView == self.cityPicker) {
                City *city = [self.cities objectAtIndex:row];
                
                if (![city.name isEqualToString:self.citySelected]) {
                    self.storeField.text = @"";
                }
                self.cityField.text = city.name;
                self.citySelected = city.name;
            }
            
        }


#pragma mark - Table View DataSource


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.countries count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSString *cellIdentifier = [[NSString alloc] init];
    cellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    Country *country = [self.countries objectAtIndex:indexPath.row];
    
    UILabel *storeLabel = (UILabel *)[cell viewWithTag:100];
    storeLabel.text = country.name;

    
    return cell;
}


@end
