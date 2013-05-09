//
//  ShoppingCartViewController.m
//  eStore
//
//  Created by VQL Developer on 5/8/13.
//  Copyright (c) 2013 VQL. All rights reserved.
//

#import "ShoppingCartViewController.h"
#import "Products.h"
#import "ShoppingCart.h"
#import "ProductViewController.H"
#import "HomeViewController.h"
#import "CoreDataHelper.h"


@interface ShoppingCartViewController ()

@property (nonatomic, strong) UINavigationBar *naviBarObj;
@property (nonatomic, strong) UINavigationItem *navigItem;
@property (strong, nonatomic) NSArray *products;
@property (assign, nonatomic) HomeViewController *homeViewControler;
@property (strong, nonatomic) NSString *currency;
@property (readwrite) float grandTotal;
@property (readwrite) int totalarticles;
@property (nonatomic, strong) NSArray *shoppincartqty;


@end

@implementation ShoppingCartViewController

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
    self.grandTotal = 0;
	// Do any additional setup after loading the view.
}


- (void)viewWillAppear:(BOOL)animated
{
    self.naviBarObj = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, 500, 44)];
    [self.view addSubview:self.naviBarObj];
    
    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelButtonPressed)];
    self.navigItem = [[UINavigationItem alloc] initWithTitle:@"Shopping Cart"];
    
    
    self.navigItem.rightBarButtonItem = self.editButtonItem;
    self.navigItem.leftBarButtonItem = cancelItem;
    
    self.naviBarObj.items = [NSArray arrayWithObjects: self.navigItem,nil];
    self.naviBarObj.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:UITextAttributeTextColor];
    
    self.view.superview.bounds = CGRectMake(0, 0, 500, 512);
     
    self.shoppincartqty = [CoreDataHelper getObjectsForEntity:@"ShoppingCart" withSortKey:@"name" andSortAscending:YES andContext:self.managedObjectContext];
    
    self.grandTotal = 0;
    for(int i = 0; i< [self.shoppincartqty count]; i++){
        
        ShoppingCart *shoppingCart = [self.shoppincartqty objectAtIndex:i];
        
        float subttotal = [shoppingCart.price floatValue] * [shoppingCart.qty floatValue];
        self.grandTotal = self.grandTotal + subttotal;
        UILabel *grantotal  = (UILabel *)[self.view viewWithTag:400];
        grantotal.text = [NSString stringWithFormat:@"%.2f",self.grandTotal];
        
        UILabel *currency  = (UILabel *)[self.view viewWithTag:401];
        currency.text = [NSString stringWithFormat:@"%@",shoppingCart.currency];
        
        UILabel *totalarticles  = (UILabel *)[self.view viewWithTag:402];
        totalarticles.text = [NSString stringWithFormat:@"%d",[self.shoppincartqty count]];

    }
    
    
    
 
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void) cancelButtonPressed{
    [self dismissViewControllerAnimated:YES completion:nil];
}


-(int) getRandomNumberBetweenMin:(int)min andMax:(int)max
{
	return ( (arc4random() % (max-min+1)) + min );
}


- (void)deleteAll:(id)sender {
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:@"Are you sure?"
                                  delegate:self
                                  cancelButtonTitle:@"No"
                                  destructiveButtonTitle:@"Yes"
                                  otherButtonTitles:nil];
    [actionSheet showInView:self.view];
    
    
}


- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    
    if(editing) {
        [super setEditing:editing animated:animated];
        [self.tableView setEditing:editing animated:animated];
        
        UIBarButtonItem *deleteAllButton = [[UIBarButtonItem alloc]
                                            initWithTitle:@"Clear All"
                                            style:UIBarButtonItemStyleBordered
                                            target:self
                                            action:@selector(deleteAll:)];
        
        self.navigItem.leftBarButtonItem = deleteAllButton;
        
    } else {
        [super setEditing:editing animated:animated];
        [self.tableView setEditing:editing animated:animated];
        UIBarButtonItem *closeButton = [[UIBarButtonItem alloc]
                                        initWithTitle:@"Close"
                                        style:UIBarButtonItemStyleBordered
                                        target:self
                                        action:@selector(cancelButtonPressed)];
        self.navigItem.leftBarButtonItem = closeButton;
    }

   
    
}


#pragma mark - Action Sheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != [actionSheet cancelButtonIndex]) {
        
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
        
        // Create fetch request
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:entity];
        [request setIncludesPropertyValues:NO];
        
        // Execute the count request
        NSError *error = nil;
        NSArray *fetchResults = [context executeFetchRequest:request error:&error];
        
        // Delete the objects returned if the results weren't nil
        if (fetchResults != nil) {
            
            for (NSManagedObject *manObj in fetchResults) {
                [context deleteObject:manObj];
                
                if (![context save:&error]) {
                    NSLog(@"Couldn't delete entries: %@", [error localizedDescription]);
                }
            }
        } else {
            NSLog(@"Couldn't delete objects for entity %@", [entity name]);
        }
    }
    
    self.shoppincartqty = [CoreDataHelper getObjectsForEntity:@"ShoppingCart" withSortKey:@"name" andSortAscending:YES andContext:self.managedObjectContext];
    
    NSDictionary *qtyShoppingCart = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:[self.shoppincartqty count]] forKey:@"qtyShoppingCart"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"EventShoppingCart" object:nil userInfo:qtyShoppingCart];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Table View DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    
    self.totalarticles = [sectionInfo numberOfObjects];
    return self.totalarticles;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ShoppingCartCell"];
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
    
}


- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    ShoppingCart *shoppingCart = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
  
    
    UIImageView *productImage = (UIImageView *)[cell viewWithTag:100];
    productImage.contentMode = UIViewContentModeScaleAspectFit;
    UIImage *image = [UIImage imageWithData:shoppingCart.image];
    const float colorMasking[6] = {255, 255, 255, 255, 255, 255};
    productImage.image = [UIImage imageWithCGImage: CGImageCreateWithMaskingColors(image.CGImage, colorMasking)];

    
    UILabel *productNameLabel = (UILabel *)[cell viewWithTag:102];
    productNameLabel.text = shoppingCart.name;
    
    UILabel *productId = (UILabel *)[cell viewWithTag:103];
    productId.text = shoppingCart.identifier;
    
    UILabel *currencyLabel = (UILabel *)[cell viewWithTag:104];
    currencyLabel.text = shoppingCart.currency;
    
    NSString *string = shoppingCart.price;
    
    
    UILabel *qty  = (UILabel *)[cell viewWithTag:106];
    qty.text = [NSString stringWithFormat:@"%@", shoppingCart.qty];

    UILabel *size  = (UILabel *)[cell viewWithTag:107];
    size.text = shoppingCart.size;
    
    float subttotal = [string floatValue] * [shoppingCart.qty floatValue];
    UILabel *productPrice = (UILabel *)[cell viewWithTag:105];
    productPrice.text = [NSString stringWithFormat:@"%.2f",subttotal];
    
}


#pragma mark - Table View Delegate


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    //Products *productDatacore = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    //Product *product = [Product new];
    //product.product_id = productDatacore.identifier;
    //product.product_name = productDatacore.name;
    //product.price = productDatacore.price;
    //product.currency = productDatacore.currency;
    //product.link = productDatacore.link;
    //product.category = productDatacore.category;
    
    
    //[self dismissModalViewControllerAnimated:YES];
    //NSLog(@"DismissModalviewController");
    
    
    //NSDictionary *userInfo = [NSDictionary dictionaryWithObject:product forKey:@"someKey"];
    //[[NSNotificationCenter defaultCenter] postNotificationName: @"MODELVIEW" object:nil userInfo:userInfo];
    
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
        
        NSError *error;
        if (![context save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ShoppingCart" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"id" ascending:NO];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Root"];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return _fetchedResultsController;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
    
  
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:(UITableViewCell *)[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
                
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
    self.shoppincartqty = [CoreDataHelper getObjectsForEntity:@"ShoppingCart" withSortKey:@"name" andSortAscending:YES andContext:self.managedObjectContext];
    
    NSDictionary *qtyShoppingCart = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:[self.shoppincartqty count]] forKey:@"qtyShoppingCart"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"EventShoppingCart" object:nil userInfo:qtyShoppingCart];
    
    //[self dismissViewControllerAnimated:YES completion:nil];
    self.grandTotal = 0;
    for(int i = 0; i< [self.shoppincartqty count]; i++){
        
        ShoppingCart *shoppingCart = [self.shoppincartqty objectAtIndex:i];
        
        float subttotal = [shoppingCart.price floatValue] * [shoppingCart.qty floatValue];
        self.grandTotal = self.grandTotal + subttotal;
        UILabel *grantotal  = (UILabel *)[self.view viewWithTag:400];
        grantotal.text = [NSString stringWithFormat:@"%.2f",self.grandTotal];
        
        UILabel *currency  = (UILabel *)[self.view viewWithTag:401];
        currency.text = [NSString stringWithFormat:@"%@",shoppingCart.currency];
        
        UILabel *totalarticles  = (UILabel *)[self.view viewWithTag:402];
        totalarticles.text = [NSString stringWithFormat:@"%d",[self.shoppincartqty count]];
        
    }

}



- (void)rateView:(DYRateView *)rateView changedToNewRate:(NSNumber *)rate {
    // self.rateLabel.text = [NSString stringWithFormat:@"Rate: %d", rate.intValue];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // if ([segue.identifier isEqualToString:@"REGRESA"]) {
    
}

@end

