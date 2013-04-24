//
//  StoresViewController.m
//  eStore
//
//  Created by VQL Developer on 4/17/13.
//  Copyright (c) 2013 CLH. All rights reserved.
//

#import "StoresViewController.h"
#import "CoreDataHelper.h"
#import "StoreLocation.h"
#import "Stores.h"
#import "Settings.h"


#define METERS_PER_MILE 1609.344

@interface StoresViewController ()
@property (strong, nonatomic) NSString *storeIdentifier;
@property (nonatomic, strong) NSArray *settings;
@property (nonatomic, strong) Settings *userInfo;
@property (nonatomic, strong) NSString *storeId;


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



#pragma mark - Table view data source


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSLog(@"seccuibes %i",[[self.fetchedResultsController sections] count]);
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    NSLog(@"numberOfObjects %i",[sectionInfo numberOfObjects]);
    
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"StoresCell"];
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
    
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    Stores *store = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    UILabel *lblName = (UILabel *)[cell viewWithTag:10];
    lblName.text = store.name;
    lblName.highlightedTextColor = [UIColor blackColor];
    
    UILabel *lblAddress = (UILabel *)[cell viewWithTag:11];
    lblAddress.text = store.address;
    lblAddress.highlightedTextColor = [UIColor blackColor];
    
    UILabel *lblCity = (UILabel *)[cell viewWithTag:12];
    lblCity.text = store.city;
    lblCity.highlightedTextColor = [UIColor blackColor];
    
    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Stores";
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Stores *store = [self.fetchedResultsController objectAtIndexPath:indexPath];
    self.storeIdentifier = store.identifier;
    
    
    UILabel *storename = (UILabel *)[self.view viewWithTag:200];
    storename.text = [NSString stringWithFormat:@"%@", store.name];
    
    UILabel *company = (UILabel *)[self.view viewWithTag:201];
    company.text = [NSString stringWithFormat:@"%@", store.address];
    
    UILabel *address = (UILabel *)[self.view viewWithTag:202];
    address.text = [NSString stringWithFormat:@"%@", store.city];
    
  
    NSLog(@"store %@ ",store.identifier);
  
    self.storeId = store.identifier;
    
    CLLocationCoordinate2D zoomLocation;
    zoomLocation.latitude = [store.latitude floatValue];
    zoomLocation.longitude= [store.longitude floatValue];
    
   MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 0.5*METERS_PER_MILE, 0.5*METERS_PER_MILE);
   [_mapView setRegion:viewRegion animated:YES];
    
   [self plotStorePositions];
    
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return nil;
    
}



- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.0;
}

- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"List_Container.png"]];
    cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"List_Container_Selected.png"]];
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    self.settings = [CoreDataHelper getObjectsForEntity:@"Settings" withSortKey:@"name" andSortAscending:YES andContext:self.managedObjectContext];
    self.userInfo = [self.settings objectAtIndex:0];
    
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Stores" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Set predicate
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(city == %@) && (company == %@)", self.userInfo.city, self.userInfo.countryIdentifier];
    [fetchRequest setPredicate:predicate];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:NO];
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

#pragma mark - Map View Delegate
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    static NSString *identifier = @"StoreLocation";
    if ([annotation isKindOfClass:[StoreLocation class]]) {
        
        MKAnnotationView *annotationView = (MKAnnotationView *) [_mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        if (annotationView == nil) {
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
            annotationView.enabled = YES;
            annotationView.canShowCallout = YES;
            annotationView.image = [UIImage imageNamed:@"adidas_pin_icon.png"];
        } else {
            annotationView.annotation = annotation;
        }
        
        return annotationView;
    }
    
    return nil;
}

- (void)plotStorePositions {
    for (id<MKAnnotation> annotation in _mapView.annotations) {
        [_mapView removeAnnotation:annotation];
    }
    
    // Getting Store information from Core Data.
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(identifier == %@)", self.storeId];
    NSMutableArray *storeInfo = [CoreDataHelper searchObjectsForEntity:@"Stores" withPredicate:predicate andSortKey:@"name" andSortAscending:YES andContext:self.managedObjectContext];
    
    Stores *store = [storeInfo objectAtIndex:0];
    
    NSString *storeName =store.name;
    NSString *city = store.city;
    
    CLLocationCoordinate2D coordinate;
    coordinate.latitude = [store.latitude floatValue];
    coordinate.longitude = [store.longitude floatValue];
    StoreLocation *annotation = [[StoreLocation alloc] initWithName:storeName address:city coordinate:coordinate] ;
    [_mapView addAnnotation:annotation];
}





@end
