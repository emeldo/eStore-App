//
//  HomeViewController.m
//  eStore
//
//  Created by Axel De Leon on 3/17/13.
//  Copyright (c) 2013 CLH. All rights reserved.
//

#import "HomeViewController.h"
#import "CatalogViewController.h"
#import "CoreDataHelper.h"
#import "Products.h"


@interface HomeViewController () {
    NSString *category;
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

    
    //Setting Navigation Bar
    
    UIView *menuBar = [[UIView alloc] initWithFrame:CGRectMake(15, 5, 91, 33)];
    menuBar.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"top_buttons_holder.png"]];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:menuBar];

    
    UIImage *historyImage = [UIImage imageNamed:@"top_buttons_recent.png"];
    UIButton *historyButton = [UIButton buttonWithType:UIButtonTypeCustom];
    historyButton.frame = CGRectMake(5, 5, 22, 22);
    [historyButton setBackgroundImage:historyImage forState:UIControlStateNormal];
    
    [menuBar addSubview:historyButton];
    
    category = nil;
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
    
    
    // Change Collection View
    CGPoint offset = CGPointMake(2 * self.collectionView.frame.size.width, 0);
    [self.collectionView setContentOffset:offset animated:YES];

}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    CatalogViewController *catalogViewController = [segue destinationViewController];
    catalogViewController.menuQuery = category;
    catalogViewController.searchQuery = [self.searchBar.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    catalogViewController.managedObjectContext = self.managedObjectContext;
    self.searchBar.text = nil;
}

- (IBAction)categorySelected:(id)sender
{
    
    self.searchBar.text = nil;
    
    UIButton *button = (UIButton *)sender;
    int buttonTag = button.tag;
    
    switch (buttonTag) {
        case 1:
            category = @"cgid=men";
            [self performSegueWithIdentifier:@"Catalog" sender:nil];
            break;
            
        case 2:
            category = @"cgid=women";
            break;
            
        case 3:
            category = @"cgid=kids";
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


#pragma mark - Scroll View Delegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGFloat pageWidth = self.collectionView.frame.size.width;
    NSLog(@"pageWidth: %f", pageWidth);
    NSLog(@"self.collectionView.contentOffset.x: %f", self.collectionView.contentOffset.x);
    
    //self.pageControl.currentPage = self.collectionView.contentOffset.x / pageWidth;
}


#pragma mark - DYRateView Delegate

- (void)rateView:(DYRateView *)rateView changedToNewRate:(NSNumber *)rate {
    
}

- (void)setUpEditableRateView {
    DYRateView *rateView = [[DYRateView alloc] initWithFrame:CGRectMake(0, 40, self.view.bounds.size.width, 20) fullStar:[UIImage imageNamed:@"StarFullLarge.png"] emptyStar:[UIImage imageNamed:@"StarEmptyLarge.png"]];
    rateView.padding = 20;
    rateView.alignment = RateViewAlignmentCenter;
    rateView.editable = YES;
    rateView.delegate = self;
    [self.view addSubview:rateView];
    
}

-(int) getRandomNumberBetweenMin:(int)min andMax:(int)max
{
	return ( (arc4random() % (max-min+1)) + min );
}



@end
