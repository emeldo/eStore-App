//
//  HomeViewController.m
//  eStore
//
//  Created by HNL on 3/17/13.
//  Copyright (c) 2013 CLH. All rights reserved.
//

#import "HomeViewController.h"
#import "CatalogViewController.h"
#import "CoreDataHelper.h"
#import "Products.h"
#import "Product.h"
#import "ProductViewController.h"
#import "HistoryViewController.h"
#import "AFJSONRequestOperation.h"
#import "Country.h"
#import "City.h"
#import "Stores.h"
#import "SettingsViewController.h"

@interface HomeViewController () {
    NSString *category;
    NSString *categoryName;
    int rightMenuY;
    int rightBevelWidth;
    int leftMenuY;
    int leftBevelWidth;
}

@property (strong, nonatomic) NSArray *products;
@property (nonatomic, assign) BOOL leftMenuVisible;
@property (nonatomic, assign) BOOL rightMenuVisible;

@property (strong, nonatomic) NSString *rboServer;
@property (strong, nonatomic) NSArray *store;
@property (strong, nonatomic) NSArray *country;
@property (strong, nonatomic) NSArray *city;
@property (strong, nonatomic) NSArray *countries;

@end

@implementation HomeViewController

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
    
    UIImageView *adidasImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo_adidas_02.png"]];
    self.navigationItem.titleView = adidasImage;
    
    
    UIView *mainBackgroundView = (UIView *)[self.view viewWithTag:4];
    mainBackgroundView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"home_img01.png"]];
    
    UIView *searchBackgroundView = (UIView *)[self.view viewWithTag:5];
    searchBackgroundView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_search_bar.png"]];
    
    
    //Setting Lateral Menus
    self.leftMenuVisible = NO;
    self.rightMenuVisible = NO;
    rightMenuY = 0;
    rightBevelWidth = 50;
    leftMenuY = 0;
    leftBevelWidth = 50;
    
    UIPanGestureRecognizer *leftRecognizer;
    leftRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragMenu:)];
    [self.leftMenu addGestureRecognizer:leftRecognizer];
    
    UIPanGestureRecognizer *rightRecognizer;
    rightRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragMenu:)];
    [self.rightMenu addGestureRecognizer:rightRecognizer];
    
    
    //Setting Search Bar
    
    UIImageView *space = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"space.png"]];
    UIImageView *searchIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_search_big.png"]];
    [self.searchBar  setRightView:searchIcon];
    [self.searchBar  setRightViewMode:UITextFieldViewModeAlways];
    [self.searchBar  setLeftView:space];
    [self.searchBar  setLeftViewMode:UITextFieldViewModeAlways];
    
    category = nil;
    categoryName = nil;
    self.searchBar.text = nil;
    
    
    //Loading Country, City and Stores
    [self getCompanies];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setSearchBar:nil];
    [self setCollectionView:nil];
    [self setPageControl:nil];
    [super viewDidUnload];
}


- (void)viewWillAppear:(BOOL)animated
{
    // Set up lateral menus first time
    self.leftMenu.frame = CGRectMake(self.leftMenu.frame.size.width * -1 + leftBevelWidth, leftMenuY, self.leftMenu.frame.size.width, self.leftMenu.frame.size.height);
    self.leftMenu.hidden = false;
    
    self.rightMenu.frame = CGRectMake(self.view.frame.size.width - rightBevelWidth, rightMenuY, self.rightMenu.frame.size.width, self.rightMenu.frame.size.height);
    self.rightMenu.hidden = false;
    
    
    // Set up the page control
    self.products = [CoreDataHelper getObjectsForEntity:@"Products" withSortKey:@"sortDate" andSortAscending:NO andContext:self.managedObjectContext];

    NSInteger pageCount;
    
    if ([self.products count] < 6) {
        pageCount = 1;
    } else {
        if ([self.products count] % 5 > 0) {
            pageCount = ([self.products count] / 5) + 1;
        } else {
            pageCount = ([self.products count] / 5);
        }
    }
    
    self.pageControl.currentPage = 0;
    if (pageCount == 1) {
        self.pageControl.numberOfPages = 0;
    } else {
        self.pageControl.numberOfPages = pageCount;
    }
    
    
    UIView *recentBackgroundView = (UIView *)[self.view viewWithTag:6];
    
    if ([self.products count] > 0) {
        
        recentBackgroundView.hidden = YES;
        [self.collectionView reloadData];
    } else {
        recentBackgroundView.hidden = NO;
    }
    
}


- (void)getCompanies {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.rboServer = [[NSString alloc] initWithFormat:@"%@",[defaults objectForKey:@"rbo_server"]];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    NSString *url = [NSString stringWithFormat:@"http://%@/WS/index.php/api/rbo/company",self.rboServer];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        self.country = JSON;
        
        [CoreDataHelper deleteAllObjectsForEntity:@"Country" andContext:self.managedObjectContext];
        
        for (NSDictionary *country in self.country) {
            
            Country *countryEntity = [NSEntityDescription insertNewObjectForEntityForName:@"Country" inManagedObjectContext:self.managedObjectContext];
            
            countryEntity.name = [country valueForKey:@"company_name"];
            countryEntity.identifier = [NSString stringWithFormat:@"%@", [country valueForKey:@"company_id"]];
        }
        
        NSError *error = nil;
        if (![self.managedObjectContext save:&error]) {
            NSLog(@"Whoops, couldn't save changes: %@", [error localizedDescription]);
        }
        
        [self getCity];
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSLog(@"Request Failed with Error: %@, %@", error, error.userInfo);
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }];
    [operation start];
    
}


- (void)getCity {
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    self.countries = [CoreDataHelper getObjectsForEntity:@"Country" withSortKey:@"name" andSortAscending:YES andContext:self.managedObjectContext];
    [CoreDataHelper deleteAllObjectsForEntity:@"City" andContext:self.managedObjectContext];
    [CoreDataHelper deleteAllObjectsForEntity:@"Stores" andContext:self.managedObjectContext];
    
    for (NSDictionary *country in self.country) {
        NSString *companyId = [NSString stringWithFormat:@"%@", [country valueForKey:@"company_id"]];
        NSString *url = [NSString stringWithFormat:@"http://%@/WS/index.php/api/rbo/city/company/%@", self.rboServer,companyId];
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
        
        AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
            self.city = JSON;
            
            for (NSDictionary *city in self.city) {
                
                City *cityEntity = [NSEntityDescription insertNewObjectForEntityForName:@"City" inManagedObjectContext:self.managedObjectContext];
                
                cityEntity.name = [city valueForKey:@"city"];
                cityEntity.country = [NSString stringWithFormat:@"%@", [city valueForKey:@"company_id"]];
                if (![cityEntity.country isEqual: @"All"]) {
                    [self getStores:companyId inCity:[city valueForKey:@"city"]];
                }
            }
            
            NSError *error = nil;
            if (![self.managedObjectContext save:&error]) {
                NSLog(@"Whoops, couldn't save changes: %@", [error localizedDescription]);
            }
            
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
            //NSLog(@"Request Failed with Error: %@, %@", error, error.userInfo);
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        }];
        [operation start];
    }
    
    
}

- (void)getStores:(NSString *)company inCity:(NSString *)city {
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    NSString *url = [NSString stringWithFormat:@"http://%@/WS/index.php/api/rbo/customer/company/%@/city/%@",self.rboServer,company, city];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        self.store = JSON;
        
        
        for (NSDictionary *store in self.store) {
            if ([store valueForKey:@"store_name"] != ( NSString *) [ NSNull null ]) {
                Stores *stores = [NSEntityDescription insertNewObjectForEntityForName:@"Stores" inManagedObjectContext:self.managedObjectContext];
                stores.name = [store valueForKey:@"store_name"];
                stores.company = [NSString stringWithFormat:@"%@", [store valueForKey:@"company_id"]];
                stores.latitude = [store valueForKey:@"latitude"];
                stores.longitude = [store valueForKey:@"longitude"];
                stores.address = [store valueForKey:@"address"];
                stores.city = city;
                stores.identifier = [NSString stringWithFormat:@"%@", [store valueForKey:@"store_id"]];
            }
        }
        
        NSError *error = nil;
        if (![self.managedObjectContext save:&error]) {
            NSLog(@"Whoops, couldn't save changes: %@", [error localizedDescription]);
        }
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        //NSLog(@"Request Failed with Error: %@, %@", error, error.userInfo);
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }];
    [operation start];
    
}



- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if ([segue.identifier isEqualToString:@"History"]) {
        HistoryViewController *historyViewController = [segue destinationViewController];
        historyViewController.managedObjectContext = self.managedObjectContext;
        
    }
    
    
    if ([segue.identifier isEqualToString:@"Settings"]) {
        SettingsViewController *settingsViewController = [segue destinationViewController];
        settingsViewController.managedObjectContext = self.managedObjectContext;
        
    }
    
    
    if ([segue.identifier isEqualToString:@"Catalog"]) {
        
        CatalogViewController *catalogViewController = [segue destinationViewController];
        catalogViewController.menuQuery = category;
        catalogViewController.titleQuery = categoryName;
        catalogViewController.searchQuery = [self.searchBar.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        catalogViewController.managedObjectContext = self.managedObjectContext;
        self.searchBar.text = nil;
        category = nil;
    }
    
    if ([segue.identifier isEqualToString:@"showProductDetail"]) {
        
        NSIndexPath *indexPath = [[self.collectionView indexPathsForSelectedItems] lastObject];
        ProductViewController *destViewController = segue.destinationViewController;
        
        Products *productDatacore = [self.products objectAtIndex:indexPath.row];
        
        Product *product = [Product new];
        product.product_id = productDatacore.identifier;
        product.product_name = productDatacore.name;
        product.price = productDatacore.price;
        product.currency = productDatacore.currency;
        product.link = productDatacore.link;
        product.category = productDatacore.category;
        
        destViewController.product = product;
        destViewController.managedObjectContext = self.managedObjectContext;
        
    } 
}

- (IBAction)categorySelected:(id)sender
{
    
    self.searchBar.text = nil;
    
    UIButton *button = (UIButton *)sender;
    int buttonTag = button.tag;
    
    switch (buttonTag) {
        case 1:
            category = @"cgid=men";
            categoryName = @"Men";
            [self performSegueWithIdentifier:@"Catalog" sender:nil];
            break;
            
        case 2:
            category = @"cgid=women";
            categoryName = @"Women";
            [self performSegueWithIdentifier:@"Catalog" sender:nil];
            break;
            
        case 3:
            category = @"cgid=kids";
            categoryName = @"Kids";
            [self performSegueWithIdentifier:@"Catalog" sender:nil];
            break;
            
        case 4:
            category = @"cgid=men";
            categoryName = @"Men";
            [self performSegueWithIdentifier:@"Catalog" sender:nil];
            break;
            
        case 5:
            category = @"cgid=women";
            categoryName = @"Women";
            [self performSegueWithIdentifier:@"Catalog" sender:nil];
            break;
            
        case 6:
            category = @"cgid=kids";
            categoryName = @"Kids";
            [self performSegueWithIdentifier:@"Catalog" sender:nil];
            break;
    }

}


- (IBAction)hideKeyboard
{    
    [self.searchBar resignFirstResponder];
}


#pragma mark - Lateral Menu Methods

- (void)dragMenu:(UIPanGestureRecognizer *)recognizer
{
    CGPoint translation = [recognizer translationInView:self.view];
    CGPoint velocity = [recognizer velocityInView:self.view];
    
    if(recognizer.state == UIGestureRecognizerStateEnded)
    {
        if (recognizer.view.tag == 1) {
            (velocity.x > 0) ? [self openMenu:self.leftMenu] : [self closeMenu:self.leftMenu];
        } else {
            (velocity.x > 0) ? [self closeMenu:self.rightMenu] : [self openMenu:self.rightMenu];
        }
    }
    
    int positionX = recognizer.view.center.x + translation.x;
    
    if (recognizer.view.tag == 1) {
        if (positionX > -66 && positionX < 101) {
            recognizer.view.center = CGPointMake(positionX, recognizer.view.center.y + 0);
            [recognizer setTranslation:CGPointMake(0, 0) inView:self.view];
        }
    } else {
        if (positionX > 930 && positionX < 1090) {
            recognizer.view.center = CGPointMake(positionX, recognizer.view.center.y + 0);
            [recognizer setTranslation:CGPointMake(0, 0) inView:self.view];
        }
    }
}


- (void)openMenu:(UIView *)menu
{
    [UIView animateWithDuration:0.5 animations:^{
        if (menu.tag == 1) {
            self.leftMenuVisible = YES;
            self.leftMenu.frame = CGRectMake(0, leftMenuY, self.leftMenu.frame.size.width, self.leftMenu.frame.size.height);
        } else {
            self.rightMenuVisible = YES;
            self.rightMenu.frame = CGRectMake(self.view.frame.size.width - self.rightMenu.frame.size.width, rightMenuY, self.rightMenu.frame.size.width, self.rightMenu.frame.size.height);
        }
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.5 animations:^{
        }];
    }];
}

- (void)closeMenu:(UIView *)menu
{
    [UIView animateWithDuration:0.5 animations:^{
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.5 animations:^{
            if (menu.tag == 1) {
                self.leftMenuVisible = NO;
                self.leftMenu.frame = CGRectMake(self.leftMenu.frame.size.width * -1 + leftBevelWidth, leftMenuY, self.leftMenu.frame.size.width, self.leftMenu.frame.size.height);
            } else {
                self.rightMenuVisible = NO;
                self.rightMenu.frame = CGRectMake(self.view.frame.size.width - rightBevelWidth, rightMenuY, self.rightMenu.frame.size.width, self.rightMenu.frame.size.height);
            }
        }];
    }];
}


- (IBAction)hideAndUnhide:(id)sender
{
    [self.searchBar resignFirstResponder];
    
    UIButton *button = (UIButton *)sender;
    int buttonTag = button.tag;
    
    switch (buttonTag) {
        case 3:
            self.leftMenuVisible ? [self closeMenu:self.leftMenu] : [self openMenu:self.leftMenu];
            break;
            
        case 4:
            self.rightMenuVisible ? [self closeMenu:self.rightMenu] : [self openMenu:self.rightMenu];
            break;
            
        default:
            [self closeMenu:self.leftMenu];
            [self closeMenu:self.rightMenu];
            break;
    }
}



#pragma mark - TextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [self.searchBar resignFirstResponder];
    [self performSegueWithIdentifier:@"Catalog" sender:nil];
    return YES;
}


#pragma mark - Collection View DataSource


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.products count];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"Cell";
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];

    if ([self.products count] == 0)
    {

    } else {
        
        Products *product = [self.products objectAtIndex:indexPath.row];
        
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
    
    return cell;
    
 }


#pragma mark - Collection View Delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    Products *product = [self.products objectAtIndex:indexPath.row];
    
    
    // Saving data in Core Data for historcial use
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(identifier == %@)", product.identifier];
    NSMutableArray *products = [CoreDataHelper searchObjectsForEntity:@"Products" withPredicate:predicate andSortKey:@"sortDate" andSortAscending:YES andContext:self.managedObjectContext];
    
    Products *productToUpdate = nil;
    productToUpdate = [products objectAtIndex:0];
    
    productToUpdate.sortDate = [NSDate date];
    [self.managedObjectContext save:nil];
    
}


#pragma mark - Scroll View Delegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGFloat pageWidth = self.collectionView.frame.size.width;
    NSLog(@"pageWidth: %f", pageWidth);
    NSLog(@"self.collectionView.contentOffset.x: %f", self.collectionView.contentOffset.x);
    
    //self.pageControl.currentPage = self.collectionView.contentOffset.x / pageWidth;
}



-(int) getRandomNumberBetweenMin:(int)min andMax:(int)max
{
	return ( (arc4random() % (max-min+1)) + min );
}



@end
