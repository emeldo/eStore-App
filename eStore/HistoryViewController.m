//
//  HistoryViewController.m
//  eStore
//
//  Created by HNL on 4/8/13.
//  Copyright (c) 2013 CLH. All rights reserved.
//

#import "HistoryViewController.h"
#import "Products.h"
#import "ProductViewController.H"

@interface HistoryViewController ()

@property (nonatomic, strong) UINavigationBar *naviBarObj;
@property (nonatomic, strong) UINavigationItem *navigItem;
@property (strong, nonatomic) NSArray *products;

@end

@implementation HistoryViewController

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


- (void)viewWillAppear:(BOOL)animated
{
    self.naviBarObj = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, 600, 44)];
    [self.view addSubview:self.naviBarObj];
    
    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelButtonPressed)];
    self.navigItem = [[UINavigationItem alloc] initWithTitle:@"Searched History"];
    

    self.navigItem.rightBarButtonItem = self.editButtonItem;
    self.navigItem.leftBarButtonItem = cancelItem;
    
    self.naviBarObj.items = [NSArray arrayWithObjects: self.navigItem,nil];
    self.naviBarObj.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:UITextAttributeTextColor];
    
    self.view.superview.bounds = CGRectMake(0, 0, 600, 612);
    
    
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
}


#pragma mark - Table View DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.fetchedResultsController sections] count];;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HistoryCell"];
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
        
}


- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    Products *product = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    UILabel *productNameLabel = (UILabel *)[cell viewWithTag:102];
    productNameLabel.text = product.name;
    
    UIImageView *productImage = (UIImageView *)[cell viewWithTag:100];
    productImage.contentMode = UIViewContentModeScaleAspectFit;
    UIImage *image = [UIImage imageWithData:product.image];
    const float colorMasking[6] = {255, 255, 255, 255, 255, 255};
    productImage.image = [UIImage imageWithCGImage: CGImageCreateWithMaskingColors(image.CGImage, colorMasking)];
    
    
    UILabel *currencyLabel = (UILabel *)[cell viewWithTag:104];
    currencyLabel.text = product.currency;
    
    NSString *string = product.price;
    
    UILabel *productPrice = (UILabel *)[cell viewWithTag:105];
    productPrice.text = [NSString stringWithFormat:@"%@", string];
    
    
    UIView *ratingView = (UIView *)[cell viewWithTag:103];
    
    DYRateView *rateView = [[DYRateView alloc] initWithFrame:CGRectMake(0, 0, 200, 20)];
    rateView.padding = 10;
    rateView.rate = [self getRandomNumberBetweenMin:0 andMax:5];
    rateView.alignment = RateViewAlignmentLeft;
    [ratingView addSubview:rateView];
    
    
}


#pragma mark - Table View Delegate


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
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
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Products" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"sortDate" ascending:NO];
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
}



- (void)rateView:(DYRateView *)rateView changedToNewRate:(NSNumber *)rate {
    // self.rateLabel.text = [NSString stringWithFormat:@"Rate: %d", rate.intValue];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showProductDetail"]) {
        
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        
        ProductViewController *destViewController = segue.destinationViewController;
        Products *productDatacore = [self.fetchedResultsController objectAtIndexPath:indexPath];
        
        Product *product = [Product new];
        product.product_id = productDatacore.identifier;
        product.product_name = productDatacore.name;
        product.price = productDatacore.price;
        product.currency = productDatacore.currency;
        product.link = productDatacore.link;
        product.category = productDatacore.category;
        
        destViewController.product = product;
        destViewController.managedObjectContext = self.managedObjectContext;
        
    } }

@end
