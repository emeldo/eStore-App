//
//  SettingsViewController.h
//  eStore
//
//  Created by VQL Developer on 4/17/13.
//  Copyright (c) 2013 CLH. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsViewController : UIViewController <UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate>

@property (strong, nonatomic) IBOutlet UITextField *nameField;
@property (strong, nonatomic) IBOutlet UITextField *countryField;
@property (strong, nonatomic) IBOutlet UIPickerView *countryPicker;
@property (strong, nonatomic) IBOutlet UITextField *cityField;
@property (strong, nonatomic) IBOutlet UIPickerView *cityPicker;
@property (strong, nonatomic) IBOutlet UITextField *storeField;
@property (strong, nonatomic) IBOutlet UIPickerView *storePicker;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (IBAction)dimissKeyword:(id)sender;

@end
