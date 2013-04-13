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


@interface HomeViewController () {
    NSString *category;
    NSString *categoryName;
}

@property (strong, nonatomic) NSArray *products;

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
    self.products = [CoreDataHelper getObjectsForEntity:@"Products" withSortKey:@"sortDate" andSortAscending:NO andContext:self.managedObjectContext];

    // Set up the page control
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


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if ([segue.identifier isEqualToString:@"History"]) {
        HistoryViewController *historyViewController = [segue destinationViewController];
        historyViewController.managedObjectContext = self.managedObjectContext;
        
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
        
        destViewController.product = product;
        
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
    }

}


- (IBAction)hideKeyboard
{    
    [self.searchBar resignFirstResponder];
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
