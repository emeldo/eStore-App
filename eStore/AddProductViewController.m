//
//  AddProductViewController.m
//  eStore
//
//  Created by VQL Developer on 5/7/13.
//  Copyright (c) 2013 VQL. All rights reserved.
//

#import "AddProductViewController.h"
#import "CoreDataHelper.h"
#import "ShoppingCart.h"

@interface AddProductViewController ()

@property (nonatomic, strong) NSArray *shoppincartqty;
@end

@implementation AddProductViewController

@synthesize product;

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
       
    UILabel *productNameLabel = (UILabel *)[self.view viewWithTag:102];
    productNameLabel.text = product.product_name;
    
    UIImageView *productImage = (UIImageView *)[self.view viewWithTag:100];
    productImage.contentMode = UIViewContentModeScaleAspectFit;
    
    UIImage *image = [self.pageImages objectAtIndex:0];
    const float colorMasking[6] = {255, 255, 255, 255, 255, 255};
    productImage.image = [UIImage imageWithCGImage: CGImageCreateWithMaskingColors(image.CGImage, colorMasking)];
    
    
    UILabel *currencyLabel = (UILabel *)[self.view viewWithTag:104];
    currencyLabel.text = product.currency;
    
    NSString *string = product.price;
    UILabel *productPrice = (UILabel *)[self.view viewWithTag:105];
    productPrice.text = [NSString stringWithFormat:@"%@", string];
    
    
    UILabel *productcode = (UILabel *)[self.view viewWithTag:106];
    productcode.text = product.product_id;
    
    UILabel *productColor = (UILabel *)[self.view viewWithTag:107];
    productColor.text = product.image;

    //UIStepper *stepper = (UIStepper *)[self.view viewWithTag:303];
    
    
    [self.stepper setMinimumValue:1];
    [self.stepper setContinuous:YES];
    [self.stepper setWraps:NO];
    [self.stepper setStepValue:1];
    [self.stepper setMaximumValue:300];
    self.stepper.value = 1;
    self.stepper.backgroundColor = [UIColor redColor];
    self.stepper.frame = CGRectMake(0, 0, 100, 10);

    
    self.stepperfield.text= @"1";// [NSString stringWithFormat:@"%g",self.stepper.value];
    
    
    UIView *ratingView = (UIView *)[self.view viewWithTag:103];
    DYRateView *rateView = [[DYRateView alloc] initWithFrame:CGRectMake(0, 0, 200, 20)];
    rateView.padding = 10;
    rateView.rate = 4.5;
    rateView.alignment = RateViewAlignmentLeft;
    [ratingView addSubview:rateView];

    

    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void)viewWillAppear:(BOOL)animated
{
    UINavigationBar *naviBarObj = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, 550, 44)];
    [self.view addSubview:naviBarObj];
    
    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelButtonPressed)];
    UINavigationItem *navigItem = [[UINavigationItem alloc] initWithTitle:@"Add Shopping Cart"];
    
    navigItem.rightBarButtonItem = cancelItem;
    
    naviBarObj.items = [NSArray arrayWithObjects: navigItem,nil];
    naviBarObj.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:UITextAttributeTextColor];
    
        
    self.view.superview.bounds = CGRectMake(0, 0, 550, 300);
    
    
}

- (void) cancelButtonPressed{
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)valueChanged:(UIStepper *)sender {
    double value = [sender value];
    
    UITextField *textFile = (UITextField *)[self.view viewWithTag:200];
    [textFile setText:[NSString stringWithFormat:@"%d", (int)value]];
}


#pragma mark - DYRate View Delegate

- (void)rateView:(DYRateView *)rateView changedToNewRate:(NSNumber *)rate {
    //self.rateLabel.text = [NSString stringWithFormat:@"Rate: %d", rate.intValue;
}


- (IBAction)addCartButton:(UIButton *)sender {
// Saving data in Core Data for historcial use
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ShoppingCart" inManagedObjectContext:self.managedObjectContext];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(identifier == %@)", product.product_id];

if ([CoreDataHelper countForEntity:[entity name] withPredicate:predicate andContext:self.managedObjectContext] >= 1) {
    
    // Create fetch request
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    [request setIncludesPropertyValues:NO];
    [request setPredicate:predicate];
    
    // Execute the count request
    NSError *error = nil;
    NSArray *fetchResults = [self.managedObjectContext executeFetchRequest:request error:&error];
    
    // Delete the objects returned if the results weren't nil
    if (fetchResults != nil) {
        
        for (NSManagedObject *manObj in fetchResults) {
            [self.managedObjectContext deleteObject:manObj];
            
            if (![self.managedObjectContext save:&error]) {
                NSLog(@"Couldn't delete entries: %@", [error localizedDescription]);
            }
        }
    } else {
        NSLog(@"Couldn't delete objects for entity %@", [entity name]);
    }
}

    ShoppingCart *shoppingcart = [NSEntityDescription insertNewObjectForEntityForName:@"ShoppingCart" inManagedObjectContext:self.managedObjectContext];
    shoppingcart.identifier = product.product_id;
    shoppingcart.name = product.product_name;
    shoppingcart.price = [NSString stringWithFormat:@"%@",product.price];
    shoppingcart.qty = [NSNumber numberWithInt:[self.stepperfield.text intValue]];
    shoppingcart.currency = product.currency;
    shoppingcart.size = @"M";
    shoppingcart.image = UIImagePNGRepresentation([self.pageImages objectAtIndex:0]);

    sleep(1);
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
    NSLog(@"Whoops, couldn't save changes: %@", [error localizedDescription]);
    }
    self.shoppincartqty = [CoreDataHelper getObjectsForEntity:@"ShoppingCart" withSortKey:@"name" andSortAscending:YES andContext:self.managedObjectContext];
    
        NSDictionary *qtyShoppingCart = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:[self.shoppincartqty count]] forKey:@"qtyShoppingCart"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"EventShoppingCart" object:nil userInfo:qtyShoppingCart];
    NSLog(@" %i",[self.shoppincartqty count]);
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    

}


@end
