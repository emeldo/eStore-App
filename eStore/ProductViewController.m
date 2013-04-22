//
// ProductViewController.m
// eComm Mobile
//
// Created by HNL on 3/4/13.
// Copyright (c) 2013 CLH. All rights reserved.
//

#import "ProductViewController.h"
#import "Product.h"
#import "AFJSONRequestOperation.h"
#import "UIImageView+WebCache.h"
#import "DYRateView.h"
#import "Variant.h"
#import "Comments.h"
#import "CatalogViewController.h"
#import "CommentsViewController.h"
#import "StoresViewController.h"
#import "ImageViewController.h"

@interface ProductViewController () {
    NSMutableArray *itemArray;
    NSMutableArray *freeList;
    NSMutableArray *paidList;
    NSMutableArray *grossingList;
    NSMutableIndexSet *expandedSections;
    
    int rightMenuY;
    int rightBevelWidth;
    int leftMenuY;
    int leftBevelWidth;
}

@property (strong, nonatomic) NSString *articleColor;
@property (strong, nonatomic) NSMutableArray *pageImages;
@property (strong, nonatomic) NSMutableArray *pageViews;
@property (strong, nonatomic) NSArray *products;
@property (strong, nonatomic) NSMutableArray *imagesByArticle;
@property (strong, nonatomic) NSMutableDictionary *master;
@property (strong, nonatomic) NSString *masterlink;
@property (strong, nonatomic) NSMutableArray *variation_attributes;
@property (strong, nonatomic) NSMutableArray *variation_color;
@property (strong, nonatomic) NSMutableArray *variation_products;
@property (strong, nonatomic) NSMutableArray *variation_size;
@property (strong, nonatomic) NSMutableArray  *variants_products;
@property (strong, nonatomic) NSMutableArray *variants;
@property (strong, nonatomic) NSMutableArray *imageslow;
@property (strong, nonatomic) NSMutableArray *imageshigh;
@property (assign, nonatomic) BOOL noImage;
@property (nonatomic, assign) BOOL leftMenuVisible;
@property (nonatomic, assign) BOOL rightMenuVisible;
@property (nonatomic, strong) NSMutableArray  *Commenthits;

//@property (nonatomic, readwrite, retain) NSMutableDictionary *arrays;

//////////////////////////////////////////////////EMELDO
@property (nonatomic, strong) NSArray *filterCategories;
@property (nonatomic, strong) NSArray *filterLabels;
@property (nonatomic, strong) NSArray *filterOrder;
@property (strong, nonatomic) UIActivityIndicatorView *progressView;
@property (strong, nonatomic) UIActivityIndicatorView *progressViewOverview;
@property (strong, nonatomic) NSMutableArray *sizesInfo;

@property (nonatomic, strong) NSArray *refinementsValues;
@property (nonatomic, strong) NSArray *sorting_optionsValues;

@end

@implementation ProductViewController

@synthesize product;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    
    return self;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //Getting Product information from Catalog
    self.title = product.product_name;
    self.productNameLabel.text = product.product_name;
    self.priceLabel.text = [NSString stringWithFormat:@"%@", product.price];
    self.currencyLabel.text = product.currency;
    self.productIDLabel.text = product.product_id;
    
       
    self.variation_attributes = [[NSMutableArray alloc] init];
    self.variation_color = [[NSMutableArray alloc] init];
    self.variation_size = [[NSMutableArray alloc] init];
    self.imageslow = [[NSMutableArray alloc] init];
    
    self.filterCategories = [[NSArray alloc] initWithObjects: @"c_productType", @"c_sport", @"cgid", @"c_division", @"c_searchColor",  @"c_sizeSearchValue", @"c_filters", nil];
    
    self.filterLabels = [[NSArray alloc] initWithObjects: @"Product Type", @"Sport", @"Category", @"Brand", @"Colour", @"Size", @"Filters", nil];
    
    
    self.filterOrder = [[NSArray alloc] initWithObjects:  @"cgid", @"c_division", @"c_sport", @"c_productType", @"c_searchColor",  @"c_sizeSearchValue", nil];

    //NSMutableArray *arrayActiveFilters = [self.arrays objectForKey:@"c_filters"];
    //NSMutableArray *arrayActiveFilters2 = [self.arrays objectForKey:@"Filters"];
    
    
    //Setting up Backgrounds for views
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_catalog.png"]];
    
    UIView *productView = (UIView *)[self.view viewWithTag:1];
    productView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"product_cont_holder.png"]];
    
    UIImageView* img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo_adidas_02.png"]];
    self.navigationItem.titleView = img;
    
    
    //Setting Breadcrum
    UIView *breadcumView = (UIView *)[self.view viewWithTag:2];
    breadcumView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Bread_Crumbs_holder.png"]];
    
    UILabel *breadcumLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 6, 100, 40)];
    [breadcumLabel setBackgroundColor:[UIColor clearColor]];
    [breadcumLabel setText:@"Home"];
    [breadcumLabel setTextColor:[UIColor darkGrayColor]];
    [breadcumLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:14.0]];
    [breadcumView addSubview:breadcumLabel];
    
    CGSize textSize = [[breadcumLabel text] sizeWithFont:[breadcumLabel font]];
    
    UIImageView *breadcumImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bread_crumb_separador.png"]];
    [breadcumImage setFrame:CGRectMake(20 + textSize.width + 10, 10, 13, 36)];
    [breadcumView addSubview:breadcumImage];
    
    NSArray *keys = [self.selected_refinements allKeys];
    UIView *breadcumViewComplete = (UIView *)[self.view viewWithTag:2];
    
    int iteration = [self.selected_refinements count];
    
    breadcumView = nil;
    
    if(iteration == 1) {
        breadcumView = [[UIView alloc] init];
        [breadcumView setTag:888];
    } else {
        breadcumView = (UIView *)[self.view viewWithTag:888];
        [breadcumView removeFromSuperview];
        breadcumView = [[UIView alloc] init];
        [breadcumView setTag:888];
    }
    
    int x = 100;
    
    for (int k=0; k< self.filterOrder.count; k++) {
        NSString *filterName = [self.filterOrder objectAtIndex:k];
        //NSLog(@" %@",filterName);
        
        for (NSString *key in keys) {
            
            if([key isEqualToString:filterName]){
                
                
                // for (NSString *key in keys) {
                
                //[arrayActiveFilters addObject:key];
                //[arrayActiveFilters2 addObject:[self.selected_refinements objectForKey:key]];
                
                int withlong = 100;
                if([[self.selected_refinements objectForKey:key] length] > 13){
                    withlong = 150;
                }

                UILabel *breadcumLabel = [[UILabel alloc]initWithFrame:CGRectMake(x, 6, withlong, 40)];
                
                [breadcumLabel setBackgroundColor:[UIColor clearColor]];
                [breadcumLabel setText:[self.selected_refinements objectForKey:key]];
                [breadcumLabel setTextColor:[UIColor darkGrayColor]];
                [breadcumLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:14.0]];
                [breadcumView addSubview:breadcumLabel];
                
                CGSize textSize = [[breadcumLabel text] sizeWithFont:[breadcumLabel font]];
                
                UIImageView *breadcumImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bread_crumb_separador.png"]];
                [breadcumImage setFrame:CGRectMake(x + textSize.width + 10, 10, 13, 36)];
                [breadcumView addSubview:breadcumImage];
                
                x = x + textSize.width + 40;
                break;
            }
            
        }
        
    }
    
    self.searchQuery = nil;
    if(product.category != nil){
        NSString *value = product.category;
        
        if([value isEqualToString:@"Men"] || [value isEqualToString:@"Women"] || [value isEqualToString:@"Kids"]){
            
            value =[NSString stringWithFormat:@"cgid=%@", [product.category lowercaseString]];
            [self loadingFromWeb : value : nil];
        }else{
            [self loadingFromWeb : nil : value];
            self.searchQuery =  value;
        }
        
    }
    
    if(self.searchQuery != nil){
        NSString *labelQuery = self.searchQuery;
        int widthlong = 100;
        if([labelQuery length] > 12){
            widthlong = 250;
        }else if([labelQuery length] > 15)  {
            widthlong = 390;
        }else if([labelQuery length] > 20)  {
            widthlong = 490;
        }
        
        UILabel *breadcumLabel = [[UILabel alloc]initWithFrame:CGRectMake(x, 6, widthlong, 40)];
        
        [breadcumLabel setBackgroundColor:[UIColor clearColor]];
        
        
        NSString *filename = [[labelQuery lastPathComponent] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        [breadcumLabel setText: filename];
        [breadcumLabel setTextColor:[UIColor darkGrayColor]];
        [breadcumLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:14.0]];
        [breadcumView addSubview:breadcumLabel];
        
        CGSize textSize = [[breadcumLabel text] sizeWithFont:[breadcumLabel font]];
        
        UIImageView *breadcumImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bread_crumb_separador.png"]];
        [breadcumImage setFrame:CGRectMake(x + textSize.width + 10, 10, 13, 36)];
        [breadcumView addSubview:breadcumImage];

    }
    
    [breadcumViewComplete addSubview:breadcumView];
    
    self.Commenthits = [[NSMutableArray alloc] init];

    //Loading Overview and Color Information
    [self loadingProductFromWeb:product.product_id];
    [self loadingCommentProductFromWeb:product.product_id];
    [self loadingOtherStoresInformation:product.product_id];
  
     
      
      [self.mybuttonComments addTarget:self action:@selector(myButtonClick:) forControlEvents:(UIControlEvents)UIControlEventTouchDown];
    
    
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
    
    
    
   

    if (!expandedSections)
    {
        expandedSections = [[NSMutableIndexSet alloc] init];
    }
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]
                                   initWithTitle: @"Back"
                                   style: UIBarButtonItemStyleBordered
                                   target: nil action: nil];
    
    [self.navigationItem setBackBarButtonItem: backButton];
    
    
    
   
}


- (void)viewWillAppear:(BOOL)animated
{
    self.leftMenu.frame = CGRectMake(self.leftMenu.frame.size.width * -1 + leftBevelWidth, leftMenuY, self.leftMenu.frame.size.width, self.leftMenu.frame.size.height);
    self.leftMenu.hidden = false;
    
    //self.rightMenu.frame = CGRectMake(self.view.frame.size.width - rightBevelWidth, rightMenuY, self.rightMenu.frame.size.width, self.rightMenu.frame.size.height);
    
    self.rightMenu.frame = CGRectMake(self.view.frame.size.width - rightBevelWidth, rightMenuY, self.rightMenu.frame.size.width, self.rightMenu.frame.size.height);
    self.rightMenu.hidden = false;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)loadScrollView {
       if ([self.pageImages count] == [self.imagesByArticle count]) {
        
        NSInteger pageCount = self.pageImages.count;
        
        // Set up the page control
        self.pageControl.currentPage = 0;
        if (pageCount == 1) {
            self.pageControl.numberOfPages = 0;
        } else {
            self.pageControl.numberOfPages = pageCount;
        }
        
        // Set up the array to hold the views for each page
        self.pageViews = [[NSMutableArray alloc] init];
        for (NSInteger i = 0; i < pageCount; ++i) {
            [self.pageViews addObject:[NSNull null]];
        }
        
        // Set up the content size of the scroll view
        self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width * self.pageImages.count, self.scrollView.frame.size.height);
        
        // Load the initial set of pages that are on screen
        [self loadVisiblePages];
        
    }
    
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"Comments"]) {
        CommentsViewController *destViewController = segue.destinationViewController;
        destViewController.Commenthits = self.Commenthits;
        destViewController.pageImages = self.pageImages;
        destViewController.product = self.product;
        
    }
    
    if ([[segue identifier] isEqualToString:@"imageZoom"]) {
        ImageViewController *imageViewController = [segue destinationViewController];
        imageViewController.productImage.contentMode = UIViewContentModeScaleAspectFit;
        imageViewController.imageStringName = product.product_name;
        imageViewController.productImage = [self.pageViews objectAtIndex:self.pageControl.currentPage];
    }
    
    if ([[segue identifier] isEqualToString:@"CatalogReturn"]) {
        
        CatalogViewController *catalogViewController = [segue destinationViewController];
        catalogViewController.menuQuery = self.menuQuery;
        catalogViewController.searchQuery = self.searchQuery;
        catalogViewController.managedObjectContext = self.managedObjectContext;
        catalogViewController.selected_refinements = self.selected_refinements;
    }
    
    if ([segue.identifier isEqualToString:@"Stores"]) {
        StoresViewController *storesViewController = [segue destinationViewController];
        storesViewController.managedObjectContext = self.managedObjectContext;
        
    }}


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
    //[self.searchBar resignFirstResponder];
    
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



#pragma mark - ScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // Load the pages which are now on screen
    
    if (scrollView == self.scrollView) {
        [self loadVisiblePages];
    }
}

#pragma mark - ScrollView Special Methods

- (void)loadVisiblePages {
    // First, determine which page is currently visible
    CGFloat pageWidth = self.scrollView.frame.size.width;
    
    NSInteger page = (NSInteger)floor((self.scrollView.contentOffset.x * 2.0f + pageWidth) / (pageWidth * 2.0f));
    
    // Update the page control
    self.pageControl.currentPage = page;
    
    // Work out which pages we want to load
    NSInteger firstPage = page - 1;
    NSInteger lastPage = page + 1;
    
    // Purge anything before the first page
    for (NSInteger i=0; i<firstPage; i++) {
        [self purgePage:i];
    }
    for (NSInteger i=firstPage; i<=lastPage; i++) {
        [self loadPage:i];
    }
    for (NSInteger i=lastPage+1; i<self.pageImages.count; i++) {
        [self purgePage:i];
    }
}

- (void)loadPage:(NSInteger)page {
    if (page < 0 || page >= self.pageImages.count) {
        // If it's outside the range of what we have to display, then do nothing
        return;
    }
    
    // Load an individual page, first seeing if we've already loaded it
    UIView *pageView = [self.pageViews objectAtIndex:page];
    if ((NSNull*)pageView == [NSNull null]) {
        CGRect frame = self.scrollView.bounds;
        frame.origin.x = frame.size.width * page;
        frame.origin.y = 0.0f;
        
        self.productImage = [[UIImageView alloc] initWithImage:[self.pageImages objectAtIndex:page]];
        self.productImage.contentMode = UIViewContentModeScaleAspectFit;
        self.productImage.frame = frame;
        
        self.productImage.userInteractionEnabled = YES;
        self.productImage.exclusiveTouch = YES;
        
        if (!self.noImage) {
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
            [self.productImage addGestureRecognizer:tap];
        }
        
        [self.scrollView addSubview:self.productImage];
        [self.pageViews replaceObjectAtIndex:page withObject:self.productImage];
    }
}

- (void)purgePage:(NSInteger)page {
    if (page < 0 || page >= self.pageImages.count) {
        // If it's outside the range of what we have to display, then do nothing
        return;
    }
    
    // Remove a page from the scroll view and reset the container array
    UIView *pageView = [self.pageViews objectAtIndex:page];
    if ((NSNull*)pageView != [NSNull null]) {
        [pageView removeFromSuperview];
        [self.pageViews replaceObjectAtIndex:page withObject:[NSNull null]];
    }
}

- (void) tap:(UITapGestureRecognizer*)gesture
{
    [self performSegueWithIdentifier:@"imageZoom" sender:nil];
}



#pragma mark - Web Services Methods

-(void)loadingOtherStoresInformation : (NSString *)wsProduct
{
//Loading all sizes information
NSArray *foo = [wsProduct componentsSeparatedByString: @"_"];
wsProduct = [foo objectAtIndex: 0];
    
    
NSString *wsOtherStoresInformation = [[NSString alloc] init];
wsOtherStoresInformation = [NSString stringWithFormat:@"http://%@/WS/index.php/api/rbo/invallstoresnosize/company/%@/article/%@", @"190.123.194.40", @"7", wsProduct];

  //  NSLog(@"STRING WEBSERVICES %@",wsOtherStoresInformation);


NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:wsOtherStoresInformation]];    
AFJSONRequestOperation *operation3 = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
    
    self.sizesInfo = [JSON mutableCopy];
    
    
   // if ((![self.userInfo.store isEqualToString:defaultStore.text] && self.sizesPickerView != NULL && ![inStockLabel1.text isEqualToString:@"Select a size"]) || ([self.userInfo.stock boolValue] != self.stockVisible && self.sizesPickerView != NULL && ![inStockLabel1.text isEqualToString:@"Select a size"])) {
    /*8
        [self searchSize:self.sizeDescription];
    }
    
    self.stockVisible = [self.userInfo.stock boolValue];
    
    //Put label for default store
    defaultStore.text = self.userInfo.store;
    defaultCity1.text = self.userInfo.city;
    defaultCity2.text = self.userInfo.city;
    
    if ([self.sizes count] == 1) {
        [self.sizesPickerView determineCurrentRow];
    }
    */
    //if (self.sizeDescription != nil) {
    //    [self updateAllStock];
    //}
    
    
} failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
    //NSLog(@"Request Failed with Error: %@, %@", error, error.userInfo);
    NSLog(@"Request Failed with Error: There are not sizes for others stores");
    //self.notSizes = YES;
    //if ([self.sizes count] == 1) {
    //    [self.sizesPickerView determineCurrentRow];
   // }
}];
[operation3 start];

}


-(void)loadingProductFromWeb : (NSString *)wsProduct_SKU
{
    //Show Loading View
    //UIView *loadingView = (UIView *)[self.view viewWithTag:501];
    //loadingView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"product_cont_holder.png"]];

    //UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleWhiteLarge];
    //indicator.frame = CGRectMake(499, 225, 10, 10);
    //indicator.color = [UIColor darkGrayColor];
    //[indicator startAnimating];
    //[loadingView addSubview:indicator];
    //loadingView.hidden = NO;
    self.progressView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
    
    self.progressView.frame = CGRectMake(107, 28, 294, 222);
    self.progressView.color = [UIColor darkGrayColor];
    
    self.progressView.alpha = 0.5;
    self.progressView.center = CGPointMake(294, 222);
   
    
    [self.view addSubview:self.progressView];
    [self.progressView startAnimating];
    
    
    self.masterlink = [[NSString alloc] init];
    NSString *wsStringQuery = [NSString stringWithFormat:@"http://development.store.adidasgroup.demandware.net/s/adidas-GB/dw/shop/v12_6/products/%@?client_id=6cb8ee1e-8951-421e-a3e6-b738b816dfc3&expand=variations,prices,availability,images",wsProduct_SKU];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:wsStringQuery]];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        
        NSDictionary *mainDict = JSON;
        
        self.master =[mainDict objectForKey:@"master"];
        self.imageslow = [mainDict objectForKey:@"image_groups"];
        NSString *c_color = [mainDict objectForKey:@"c_color"];
        
        [self loadingImagesFromWeb:c_color:self.imageslow];
        
        
        
        self.masterlink = [self.master objectForKey:@"link"];
        self.variation_attributes = [mainDict objectForKey:@"variation_attributes"];

        for (NSDictionary *valueInformation in self.variation_attributes) {
        
            if ([[valueInformation objectForKey:@"id"] isEqualToString:@"color"]) {
                self.variation_color = [valueInformation objectForKey:@"values"];
            } else if([[valueInformation objectForKey:@"id"] isEqualToString:@"size"]) {
                self.variation_size = [valueInformation objectForKey:@"values"];
            } else {
                NSLog(@"Sigue ejecucion");
            }
        }
        
        self.variants =  [mainDict objectForKey:@"variants"];
        
        self.variation_products = [[NSMutableArray alloc] init];
        self.variants_products = [[NSMutableArray alloc] init];
        
        for (NSDictionary *colorDict in self.variation_color) {

            NSString *nameColor = [colorDict objectForKey:@"name"];
            bool flag = 0;

            for (NSDictionary *variantValue in self.variants) {

                NSMutableDictionary *Darpa = [variantValue objectForKey:@"variation_values"];
                NSArray *keys = [[variantValue objectForKey:@"variation_values"] allKeys];
                
                for(NSString *key in keys) {
                    if([key isEqualToString:@"color"] && [[Darpa objectForKey:key] isEqualToString:nameColor] && flag == 0)
                    {
                        Variant *variant = [[Variant alloc] init];
                        [self.variation_products addObject:[variantValue objectForKey:@"product_id"]];
                        variant.product_id = [variantValue objectForKey:@"product_id"];
                        variant.color_variant = nameColor;
                        [self.variants_products addObject:variant];
                        flag = 1;
                    }
                }
            }
        }
        
        
        
        [self listColors : self.variation_color: self.imageslow : self.variants_products];
        
        [self addButtonsSize];
        [self loadingOverviewtFromWeb : self.masterlink];
        
        DYRateView *rateView = [[DYRateView alloc] initWithFrame:CGRectMake(0, 0, 150, 20) fullStar:[UIImage imageNamed:@"StarFull.png"] emptyStar:[UIImage imageNamed:@"StarEmpty.png"]];
        rateView.padding = 5;
        rateView.rate = 3.3;
        rateView.alignment = RateViewAlignmentLeft;
        rateView.editable = YES;
        rateView.delegate = self;
        [self.rateView addSubview:rateView];
        
        //Dismiss Loading View
        //CATransition *animation = [CATransition animation];
        //animation.type = kCATransitionFade;
        //animation.duration = 0.4;
        //[loadingView.layer addAnimation:animation forKey:nil];
        //loadingView.hidden = YES;


    }failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSLog(@"Request ERROR 1: %@, %@", error, error.userInfo);
        [self.progressView stopAnimating];
        
        UIView *loadingView = (UIView *)[self.view viewWithTag:501];
        loadingView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"product_cont_holder.png"]];
        loadingView.hidden = YES;

        
        UIView *ErrorView = (UIView *)[self.view viewWithTag:404];
        ErrorView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"product_cont_holder.png"]];
        ErrorView.hidden = NO;
        
    }];
    
    
    [operation start];
    
}


-(void)loadingCommentProductFromWeb : (NSString *)wsProduct_SKU
{
    
    //wsProduct_SKU
    
    NSString *wsStringQuery = [NSString stringWithFormat:@"http://adidas.ugc.bazaarvoice.com/bvstaging/data/reviews.json?apiversion=5.2&passkey=a7p8xf6e8y8gsmt3pfemzqkx&filter=ProductId:test2&Sort=Rating:desc&Limit=10"];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:wsStringQuery]];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        
        NSDictionary *mainDictComment = JSON;
        
      
        NSString *TotalResults = [mainDictComment objectForKey:@"TotalResults"];
        //NSString *HasErrors = [mainDictComment objectForKey:@"HasErrors"];
        self.commentValue.text = [NSString stringWithFormat:@"%@", TotalResults];
        
        NSArray *Results = [mainDictComment objectForKey:@"Results"];
        for (int i = 0, cantidad = [Results count]; i < cantidad; i = i + 1)
        {
            NSDictionary *ResultsValues = [Results objectAtIndex:i];
            Comments *Comment = [Comments new];
            
            
            Comment.UserNickname = [ResultsValues objectForKey:@"UserNickname"];
            Comment.UserLocation = [ResultsValues objectForKey:@"UserLocation"];
            Comment.AuthorId = [ResultsValues objectForKey:@"AuthorId"];

            Comment.ProductId = [ResultsValues objectForKey:@"ProductId"];
            Comment.Title = [ResultsValues objectForKey:@"Title"];
            
            if([ResultsValues objectForKey:@"ReviewText"] != nil){
            Comment.ReviewText = [ResultsValues objectForKey:@"ReviewText"];
            }else{
            Comment.ReviewText = @"No Review";
            }
            Comment.ModerationStatus = [ResultsValues objectForKey:@"ModerationStatus"];
            Comment.LastModeratedTime = [ResultsValues objectForKey:@"LastModeratedTime"];
            

            Comment.Id = [ResultsValues objectForKey:@"Id"];
            Comment.Rating = [ResultsValues objectForKey:@"Rating"];
            Comment.ContentLocale = [ResultsValues objectForKey:@"ContentLocale"];
            Comment.RatingRange = [ResultsValues objectForKey:@"RatingRange"];

            Comment.Photos = [ResultsValues objectForKey:@"Photos"];
            Comment.Videos = [ResultsValues objectForKey:@"Videos"];

             NSArray *ContextDataValues = [ResultsValues objectForKey:@"ContextDataValues"];
             NSArray *ContextDataValuesOrder = [ResultsValues objectForKey:@"ContextDataValuesOrder"];
            // NSArray *Context = [ContextDataValues allKeys];
            
             //NSLog(@"total  %i", [ContextDataValues count]);
            
            for(int j = 0 ; j < [ContextDataValuesOrder count]; j++){
               NSString *value =  [ContextDataValuesOrder objectAtIndex:j];
               // NSLog(@" %@",value);
               
                
                 for(int K = 0 ; K < [ContextDataValues count]; K++){
                // NSDictionary *xa =  [ContextDataValues :K];
                // NSLog(@" %@ ", xa );
                 }
            
                   
                
  
            }
            
            
            [self.Commenthits addObject:Comment];
           }
       

        
    }failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSLog(@"Request Error 2: %@, %@", error, error.userInfo);
        
        UIView *loadingView = (UIView *)[self.view viewWithTag:501];
        loadingView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"product_cont_holder.png"]];
        loadingView.hidden = YES;
        
        //[self performSegueWithIdentifier:@"notFound" sender:nil];
        UIView *ErrorView = (UIView *)[self.view viewWithTag:404];
        ErrorView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"product_cont_holder.png"]];
        ErrorView.hidden = NO;

    }];
    
    
    [operation start];
    
}



-(void)loadingImagesFromWeb:(NSString *)c_color :(NSArray *)imageGroupsImages  {
    
    self.articleColor = c_color;
    self.productColor.text = self.articleColor;
    
    NSArray *imageGroups = imageGroupsImages;
    //NSDictionary *imagesDic = [imageGroups objectAtIndex:0];
    
    for (NSDictionary *imagesDic in imageGroups) {
        if ([[imagesDic objectForKey:@"variation_value"] isEqualToString:self.articleColor]
            && [[imagesDic objectForKey:@"view_type"] isEqualToString:@"quickview"]) {
            self.imagesByArticle = [imagesDic objectForKey:@"images"];
        }
    }
    
    self.pageImages = [[NSMutableArray alloc] init];
    
    
    
    for (NSDictionary *imagesDictonary in self.imagesByArticle) {
        
        NSURL *urlImage = [NSURL URLWithString:[[imagesDictonary objectForKey:@"link"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        
        SDWebImageManager *manager = [SDWebImageManager sharedManager];
        [manager downloadWithURL:urlImage
                         options:0
                        progress:^(NSUInteger receivedSize, long long expectedSize)
         {
             // progression tracking code
                         
             
         }
                       completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL dummy)
         {
             
             [self.pageImages addObject:image];
             
             [self loadScrollView];
             
         }];
    }
    [self.progressView stopAnimating];
    
    
}


-(void)loadingOverviewtFromWeb : (NSString *)wsStringQuery
{

    self.progressViewOverview = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
    
    self.progressViewOverview.frame = CGRectMake(490, 303, 700, 480);
    self.progressViewOverview.color = [UIColor darkGrayColor];
    
    self.progressViewOverview.alpha = 0.5;
    self.progressViewOverview.center = CGPointMake(700, 480);
    
    
    [self.view addSubview:self.progressViewOverview];
    [self.progressViewOverview startAnimating];
    
    //NSLog(@"overview %@ ", wsStringQuery);
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:wsStringQuery]];
     
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        
        NSDictionary *mainDict = JSON;
        NSDictionary *bullets = [mainDict objectForKey:@"c_bullets"];
        NSMutableString *short_description = [[NSMutableString alloc] init];
        NSMutableString *bullets_description = [[NSMutableString alloc] init];
        
        short_description = [mainDict objectForKey:@"short_description"];
        
        for(NSString *bullet in bullets){
            bullets_description = [NSMutableString stringWithFormat:@" %@  <br> &#149; %@",bullets_description,bullet];
        }
        
        
        NSString *c_division = [mainDict objectForKey:@"c_division"];
        
        if([c_division isEqualToString:@"Originals"]){
         self.productDivision.image =  [UIImage imageNamed:@"original_small_logo.png"];
            
        }else if([c_division isEqualToString:@"Performance"]){
           self.productDivision.image =  [UIImage imageNamed:@"performance_small_logo.png"];
        }else{
           self.productDivision =  nil;
        }
        
        
        NSString *htmlBody = [[NSString alloc] initWithFormat:@"<html> \n"
                              "<head> \n"
                              "<style type=\"text/css\"> \n"
                              "body {font-family: \"helvetica\"; font-size: 13px;}\n"
                              "</style> \n"
                              "</head> \n"
                              "<body><div align='justify' style='font-family=Arial'>%@ <br> %@<div></body> \n"
                              "</html>", short_description,bullets_description];
        
        [self.webviewName loadHTMLString:htmlBody baseURL:nil];
        [self.progressViewOverview stopAnimating];

        
    }failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSLog(@"Request Error 3 %@, %@", error, error.userInfo);
        UIView *loadingView = (UIView *)[self.view viewWithTag:501];
        loadingView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"product_cont_holder.png"]];
        loadingView.hidden = YES;
        
        UIView *ErrorView = (UIView *)[self.view viewWithTag:404];
        ErrorView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"product_cont_holder.png"]];
        
        ErrorView.hidden = NO;
        [self.progressViewOverview stopAnimating];
    }];
    
    [operation start];
    
}


- (void)addButtonsSize {
    
    int positionx = 20;
    int positiony = 0;
    int counter = 0;
    int tag = 0;
   
    
    for (NSDictionary *sizeDict in self.variation_size) {

        NSString *nameSize = [sizeDict objectForKey:@"name"];
        
        UIButton *playButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        playButton.frame = CGRectMake(positionx, positiony, 35.0, 26.0);
        [playButton setTitle:nameSize forState:UIControlStateNormal];
        playButton.backgroundColor = [UIColor clearColor];
        [playButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        playButton.titleLabel.font = [UIFont systemFontOfSize:13.0];
        
        UIImage *buttonImageNormal = [UIImage imageNamed:@"size02_def.png"];
        UIImage *strechableButtonImageNormal = [buttonImageNormal stretchableImageWithLeftCapWidth:12 topCapHeight:0];
        [playButton setBackgroundImage:strechableButtonImageNormal forState:UIControlStateNormal];
        UIImage *buttonImagePressed = [UIImage imageNamed:@"size02_high.png"];
        UIImage *strechableButtonImagePressed = [buttonImagePressed stretchableImageWithLeftCapWidth:12 topCapHeight:0];
        [playButton setBackgroundImage:strechableButtonImagePressed forState:UIControlStateHighlighted];
        playButton.tag = tag;
        [playButton addTarget:self action:@selector(playAction:) forControlEvents:UIControlEventTouchUpInside];
        
        positionx = positionx + 46;
        counter++;
        tag++;
        
        if(counter >= 7){
            positiony = positiony + 40;
            positionx = 20;
            counter = 0;
        }
        
        [self.scrollViewSize addSubview:playButton]; 
    }
   
    [self.scrollViewSize setContentSize:(CGSizeMake(320, positiony))];
    
    
  
}


- (void)playAction:(id)sender
{
    UIButton *SizeButton = (UIButton *)sender;
    int valueSelected = (int)SizeButton.tag;
    NSString *inventory_qty = @"0";
    
    NSDictionary *sizeValue = [self.variation_size objectAtIndex:valueSelected];
    
    NSString *descString = [sizeValue objectForKey:@"name"];
    descString = [descString stringByReplacingOccurrencesOfString:@"-" withString:@".5"];
    
    NSInteger valueSizeSelected = [descString intValue];

    //NSLog(@"Button %i clicked. %@", valueSelected,sizeValue);
    
    for(int i=0; i<[self.sizesInfo count]; i++){
    NSDictionary *sizeData = [self.sizesInfo objectAtIndex:i];
        
    NSInteger size = [[sizeData objectForKey:@"size_description"] intValue];
    NSInteger store_id = [[sizeData objectForKey:@"store_id"] intValue];
    
       if(valueSizeSelected == size && store_id == 3){
           inventory_qty = [sizeData objectForKey:@"inventory_qty"];
           break;
        }
    }
   // NSLog(@" pilla %@",inventory_qty);
    
    self.qtyValue.text = [NSString stringWithFormat:@"%@", inventory_qty];
    if([inventory_qty intValue] == 0){
    self.qtyValue.textColor = [UIColor redColor];
    self.qtyValueInfo.text = @"Out Stock";
    }else{
    self.qtyValue.textColor = [UIColor greenColor];
    self.qtyValueInfo.text = @"In Stock";
    }
    
    
}

-(void)listColors:(NSMutableArray *)colors :(NSMutableArray *)images :(NSMutableArray *)product_list {
    
    //Loading images for article
    freeList = [[NSMutableArray alloc] init];
    
    for (Variant *productVariant in product_list) {
        
        NSString *productid = productVariant.product_id;
        NSString *nameColor = productVariant.color_variant;
        
        for (NSDictionary *imageInformation in images) {
            
            if([[imageInformation objectForKey:@"variation_value"] isEqualToString:nameColor] && [[imageInformation objectForKey:@"view_type"] isEqualToString:@"large"]) {
                
                NSMutableArray *imagesArray = [imageInformation objectForKey:@"images"];
                NSDictionary *imageDict = [imagesArray objectAtIndex:0];
                
                NSURL *urlImage = [NSURL URLWithString:[[imageDict objectForKey:@"link"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                
                SDWebImageManager *manager = [SDWebImageManager sharedManager];
                [manager downloadWithURL:urlImage
                                 options:0
                                progress:^(NSUInteger receivedSize, long long expectedSize)
                 {
                     // progression tracking code
                 }
                               completed:^(UIImage *imageView, NSError *error, SDImageCacheType cacheType, BOOL dummy)
                 {
                     ListItem *item1 = [[ListItem alloc] initWithFrame:CGRectZero image:imageView text:nil text:productid];
                     [freeList addObject:item1];
                     [self.tableView reloadData];
                     
                 }];
                
                
                
            }
        }
        
        
    }
    



}


#pragma mark - Table View DataSource


- (BOOL)tableView:(UITableView *)tableView canCollapseSection:(NSInteger)section
{
    return YES;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == self.menuTableView ) {
        return 6;
    }
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.menuTableView ) {
        if ([self tableView:tableView canCollapseSection:section])
        {
            if ([expandedSections containsIndex:section])
            {
                NSString *SubCategoryLabel = [self.filterCategories objectAtIndex:section];
                NSMutableArray *arrayInfoDisplay = [self.arrays objectForKey:SubCategoryLabel];
                int valortotal = [arrayInfoDisplay count]+1;
                if([SubCategoryLabel isEqualToString:@"c_searchColor"]
                   || [SubCategoryLabel isEqualToString:@"c_sizeSearchValue"]){
                    float x = [arrayInfoDisplay count]/4;
                    valortotal = (int)x;
                    valortotal = valortotal + 1;
                }else{
                    valortotal = [arrayInfoDisplay count]+1;
                }
                return valortotal;
            }
            return 1; // only top row showing
        }
    }else if (tableView == self.selectionTableView) {
       NSMutableArray *arraySelection = [self.arrays objectForKey:@"Filters"];
        return [arraySelection count];
    }
    
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSString *cellIdentifier = [[NSString alloc] init];
    
    if (tableView == self.menuTableView ) {
        if (!indexPath.row) {
            cellIdentifier = @"CategoryCell";
        } else {
            cellIdentifier = @"SubCategoryCell";
        }
        
        if (indexPath.row){
            NSString *SubCategoryInfoValue = [self.filterCategories objectAtIndex:indexPath.section];
            
            //NSLog(@" NTYPE %@",SubCategoryInfoValue);
            if([SubCategoryInfoValue isEqualToString:@"c_searchColor"]){
                cellIdentifier = @"ColourCell";
                
            }else if([SubCategoryInfoValue isEqualToString:@"c_sizeSearchValue"]){
                cellIdentifier = @"SizeCell";
            }
        }
        
    } else if(tableView == self.selectionTableView) {
        cellIdentifier = @"SelectionCell";
    } else {
        cellIdentifier = @"Cell";
    }
    
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    
    if (tableView == self.menuTableView ) {
        
        if ([self tableView:tableView canCollapseSection:indexPath.section])
        {
            if (!indexPath.row)
            {
                UILabel *categoryName = (UILabel *)[cell viewWithTag:5];
                UIView *cellSectionBg = (UIView *)[cell viewWithTag:14];
                UIView *accesorySection = (UIView *)[cell viewWithTag:13];
                
                cellSectionBg.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"filter_bg.png"]];
                accesorySection.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"desplegar_icon.png"]];
                
                NSString *CategoryLabel = [self.filterLabels objectAtIndex:indexPath.section];
                
                switch (indexPath.section) {
                    case 2:
                        if(self.titleQuery != nil){
                            categoryName.text = self.titleQuery;
                        }else{
                            categoryName.text = @"Category";
                        }
                        break;
                    default:
                        categoryName.text = CategoryLabel;
                        break;
                }
                
            }
            else
            {
                
                NSString *SubCategoryLabel = [self.filterLabels objectAtIndex:indexPath.section];
                NSString *SubCategoryInfoValue = [self.filterCategories objectAtIndex:indexPath.section];
                
                if([SubCategoryInfoValue isEqualToString:@"c_searchColor"]){
                    
                    UIButton *color1 = (UIButton *)[cell viewWithTag:20];
                    UIButton *color2 = (UIButton *)[cell viewWithTag:21];
                    UIButton *color3 = (UIButton *)[cell viewWithTag:22];
                    UIButton *color4 = (UIButton *)[cell viewWithTag:23];
                    
                    NSString  *col1, *col2, *col3,*col4 = nil;
                    int N1,N2,N3,N4 = 0;
                    
                    //NSLog(@"i-> %i",indexPath.row);
                    if(indexPath.row == 1){
                        N1 = 0;
                        N2 = 1;
                        N3 = 2;
                        N4 = 3;
                    }else{
                        N1 = indexPath.row * 4 - 4;
                        N2 = indexPath.row * 4 - 3;
                        N3 = indexPath.row * 4 - 2;
                        N4 = indexPath.row * 4 - 1;
                    }
                    
                    @try {
                        //NSLog(@"trying...");
                        col1 = [[self.arrays objectForKey:@"c_searchColor"] objectAtIndex:N1];
                    }
                    @catch (NSException * e) {
                        //NSLog(@"catching reason");
                        col1 = nil;
                    }
                    @finally {
                        // NSLog(@"finally");
                    }
                    
                    @try {
                        //NSLog(@"trying...");
                        col2 = [[self.arrays objectForKey:@"c_searchColor"] objectAtIndex:N2];
                    }
                    @catch (NSException * e) {
                        //NSLog(@"catching reason");
                        col2 = nil;
                    }
                    @finally {
                        // NSLog(@"finally");
                    }
                    
                    @try {
                        //NSLog(@"trying...");
                        col3 = [[self.arrays objectForKey:@"c_searchColor"] objectAtIndex:N3];
                    }
                    @catch (NSException * e) {
                        col3 = nil;
                        //NSLog(@"catching reason");
                    }
                    @finally {
                        // NSLog(@"finally");
                    }
                    
                    @try {
                        //NSLog(@"trying...");
                        col4 = [[self.arrays objectForKey:@"c_searchColor"] objectAtIndex:N4];
                    }
                    @catch (NSException * e) {
                        //                         NSLog(@"colores %@ %@ %@ %@",col1,col2,col3,col4);
                        //NSLog(@"catching reason ");
                        col4 = nil;
                    }
                    @finally {
                        //  NSLog(@"finally");
                    }
                    
                    
                    //NSLog(@"colores %i %i %i %i",N1,N2,N3,N4);
                    //NSLog(@"colores %@ %@ %@ %@",col1,col2,col3,col4);
                    
                    
                    
                    [color1 addTarget:self action:@selector(colorPressed:) forControlEvents:UIControlEventTouchUpInside];
                    [color2 addTarget:self action:@selector(colorPressed:) forControlEvents:UIControlEventTouchUpInside];
                    [color3 addTarget:self action:@selector(colorPressed:) forControlEvents:UIControlEventTouchUpInside];
                    [color4 addTarget:self action:@selector(colorPressed:) forControlEvents:UIControlEventTouchUpInside];
                    
                    color1.tag = N1;
                    color2.tag = N2;
                    color3.tag = N3;
                    color4.tag = N4;
                    
                    color1.backgroundColor = [UIColor clearColor];
                    [color1 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal ];
                    UIImage *buttonImageNormal = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png",col1]];
                    UIImage *strechableButtonImageNormal = [buttonImageNormal stretchableImageWithLeftCapWidth:12 topCapHeight:0];
                    [color1 setBackgroundImage:strechableButtonImageNormal forState:UIControlStateNormal];
                    
                    
                    color2.backgroundColor = [UIColor clearColor];
                    [color2 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal ];
                    UIImage *buttonImageNormal2 = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png",col2]];
                    strechableButtonImageNormal = [buttonImageNormal2 stretchableImageWithLeftCapWidth:12 topCapHeight:0];
                    [color2 setBackgroundImage:strechableButtonImageNormal forState:UIControlStateNormal];
                    
                    
                    color3.backgroundColor = [UIColor clearColor];
                    [color3 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal ];
                    UIImage *buttonImageNormal3 = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png",col3]];
                    strechableButtonImageNormal = [buttonImageNormal3 stretchableImageWithLeftCapWidth:12 topCapHeight:0];
                    [color3 setBackgroundImage:strechableButtonImageNormal forState:UIControlStateNormal];
                    
                    
                    color4.backgroundColor = [UIColor clearColor];
                    [color4 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal ];
                    UIImage *buttonImageNormal4 = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png",col4]];
                    strechableButtonImageNormal = [buttonImageNormal4 stretchableImageWithLeftCapWidth:12 topCapHeight:0];
                    [color4 setBackgroundImage:strechableButtonImageNormal forState:UIControlStateNormal];
                    
                    
                    
                    
                    
                }else if([SubCategoryInfoValue isEqualToString:@"c_sizeSearchValue"]){
                    
                    UIButton *button1 = (UIButton *)[cell viewWithTag:30];
                    UIButton *button2 = (UIButton *)[cell viewWithTag:31];
                    UIButton *button3 = (UIButton *)[cell viewWithTag:32];
                    UIButton *button4 = (UIButton *)[cell viewWithTag:33];
                    
                    
                    [button1 addTarget:self action:@selector(sizePressed:) forControlEvents:UIControlEventTouchUpInside];
                    [button2 addTarget:self action:@selector(sizePressed:) forControlEvents:UIControlEventTouchUpInside];
                    [button3 addTarget:self action:@selector(sizePressed:) forControlEvents:UIControlEventTouchUpInside];
                    [button4 addTarget:self action:@selector(sizePressed:) forControlEvents:UIControlEventTouchUpInside];
                    
                    NSString  *col1, *col2, *col3,*col4 = nil;
                    int N1,N2,N3,N4 = 0;
                    
                    //NSLog(@"i-> %i",indexPath.row);
                    if(indexPath.row == 1){
                        N1 = 0;
                        N2 = 1;
                        N3 = 2;
                        N4 = 3;
                    }else{
                        N1 = indexPath.row * 4 - 4;
                        N2 = indexPath.row * 4 - 3;
                        N3 = indexPath.row * 4 - 2;
                        N4 = indexPath.row * 4 - 1;
                    }
                    
                    @try {
                        //NSLog(@"trying...");
                        col1 = [[self.arrays objectForKey:@"c_sizeSearchValue"] objectAtIndex:N1];
                    }
                    @catch (NSException * e) {
                        //NSLog(@"catching reason");
                        col1 = nil;
                    }
                    @finally {
                        // NSLog(@"finally");
                    }
                    
                    @try {
                        //NSLog(@"trying...");
                        col2 = [[self.arrays objectForKey:@"c_sizeSearchValue"] objectAtIndex:N2];
                    }
                    @catch (NSException * e) {
                        //NSLog(@"catching reason");
                        col2 = nil;
                    }
                    @finally {
                        // NSLog(@"finally");
                    }
                    
                    @try {
                        //NSLog(@"trying...");
                        col3 = [[self.arrays objectForKey:@"c_sizeSearchValue"] objectAtIndex:N3];
                    }
                    @catch (NSException * e) {
                        col3 = nil;
                        //NSLog(@"catching reason");
                    }
                    @finally {
                        //  NSLog(@"finally");
                    }
                    
                    @try {
                        col4 = [[self.arrays objectForKey:@"c_sizeSearchValue"] objectAtIndex:N4];
                    }
                    @catch (NSException * e) {
                        // NSLog(@"catching reason ");
                        col4 = nil;
                    }
                    @finally {
                        //NSLog(@"finally");
                    }
                    //NSLog(@"colores %i %i %i %i",N1,N2,N3,N4);
                    
                    //NSLog(@"colores %@ %@ %@ %@",col1,col2,col3,col4);
                    button1.tag = N1;
                    button2.tag = N2;
                    button3.tag = N3;
                    button4.tag = N4;
                    
                    
                    [button1 setTitle:col1 forState:UIControlStateNormal];
                    button1.backgroundColor = [UIColor clearColor];
                    [button1 setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
                    
                    
                    [button2 setTitle:col2 forState:UIControlStateNormal];
                    button2.backgroundColor = [UIColor clearColor];
                    [button2 setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
                    
                    [button3 setTitle:col3 forState:UIControlStateNormal];
                    button3.backgroundColor = [UIColor clearColor];
                    [button3 setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
                    
                    [button4 setTitle:col4 forState:UIControlStateNormal];
                    button4.backgroundColor = [UIColor clearColor];
                    [button4 setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
                    
                    
                    
                    
                }else{
                    
                    UILabel *subCategoryName = (UILabel *)[cell viewWithTag:7];
                    UILabel *subCategoryValue = (UILabel *)[cell viewWithTag:8];
                    
                    
                    if(![SubCategoryLabel isEqualToString: @"Filters"]){
                        if (indexPath.row == 0) {
                            
                            subCategoryName.text = [[self.arrays objectForKey:SubCategoryLabel] objectAtIndex:indexPath.row];
                            if(![SubCategoryLabel isEqualToString: @"Filters"]){
                                subCategoryValue.text = [[self.arrays objectForKey:SubCategoryInfoValue] objectAtIndex:indexPath.row];
                                
                            }
                            subCategoryValue.hidden = true;
                        } else {
                            subCategoryName.text = [[self.arrays objectForKey:SubCategoryLabel] objectAtIndex:indexPath.row-1];
                            if(![SubCategoryLabel isEqualToString: @"Filters"]){
                                subCategoryValue.text = [[self.arrays objectForKey:SubCategoryInfoValue] objectAtIndex:indexPath.row-1];
                            }
                            subCategoryValue.hidden = true;
                        }
                    }// quitando filters
                    
                }
            }
        }
        else
        {
            cell.accessoryView = nil;
            cell.textLabel.text = @"Normal Cell";
        }
        
    } else if(tableView == self.selectionTableView){
        UILabel *filters = (UILabel *)[cell viewWithTag:13];
        UILabel *filterName = (UILabel *)[cell viewWithTag:14];
        UIImageView *filterImageView = (UIImageView *)[cell viewWithTag:15];
        
        //NSString *filterTempLabel = [[NSString alloc] initWithString:[[self.arrays objectForKey:@"Filters"] objectAtIndex:indexPath.row]];
        
        filters.text = [[self.arrays objectForKey:@"Filters"] objectAtIndex:indexPath.row];
        
        //filters.text = [filterTempLabel stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        filterName.text = [[self.arrays objectForKey:@"c_filters"] objectAtIndex:indexPath.row];
        
        if([[[self.arrays objectForKey:@"c_filters"] objectAtIndex:indexPath.row] isEqualToString:@"cgid"]){
            filterImageView.hidden = YES;
        }else{
            filterImageView.hidden = NO;
        }
        
        
    }else{
        NSString *title = @"";
        POHorizontalList *list;
        
        if ([indexPath row] == 0) {
            list = [[POHorizontalList alloc] initWithFrame:CGRectMake(0.0, 0.0, 352.0, 155.0) title:title items:freeList];
        }
        
        [list setDelegate:self];
        [cell.contentView addSubview:list];
    
    }
    
    return cell;
}



#pragma mark - Table View Delegate


- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.menuTableView ) {
        if (!indexPath.row) {
            
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            UIView *cellSectionBg = (UIView *)[cell viewWithTag:14];
            cellSectionBg.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"filter_bg.png"]];
            
        }
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.menuTableView ) {
        
        if ([self tableView:tableView canCollapseSection:indexPath.section])
        {
            if (!indexPath.row)
            {
                // only first row toggles exapand/collapse
                [tableView deselectRowAtIndexPath:indexPath animated:YES];
                
                NSInteger section = indexPath.section;
                BOOL currentlyExpanded = [expandedSections containsIndex:section];
                NSInteger rows;
                
                
                NSMutableArray *tmpArray = [NSMutableArray array];
                
                if (currentlyExpanded){
                    rows = [self tableView:tableView numberOfRowsInSection:section];
                    [expandedSections removeIndex:section];
                    
                }else{
                    [expandedSections addIndex:section];
                    rows = [self tableView:tableView numberOfRowsInSection:section];
                }
                
                
                for (int i=1; i<rows; i++)
                {
                    NSIndexPath *tmpIndexPath = [NSIndexPath indexPathForRow:i
                                                                   inSection:section];
                    [tmpArray addObject:tmpIndexPath];
                }
                
                UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
                UIView *cellSectionBg = (UIView *)[cell viewWithTag:14];
                UIView *accesorySection = (UIView *)[cell viewWithTag:13];
                
                cellSectionBg.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"filter_bg.png"]];
                
                
                
                if (currentlyExpanded)
                {
                    [tableView deleteRowsAtIndexPaths:tmpArray withRowAnimation:UITableViewRowAnimationTop];
                    cellSectionBg.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"filter_bg.png"]];
                    accesorySection.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"desplegar_icon.png"]];
                    
                } else {
                    [tableView insertRowsAtIndexPaths:tmpArray withRowAnimation:UITableViewRowAnimationTop];
                    cellSectionBg.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"opened_filter.png"]];
                    accesorySection.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Colapse_icon.png"]];
                    
                }
            } else {
                
                
                UITableViewCell *cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:indexPath.section]];
                UITableViewCell *cellSelected = [tableView cellForRowAtIndexPath:indexPath];
                UILabel *subCategoryName = (UILabel *)[cell viewWithTag:2];
                UILabel *subCategorySelected = (UILabel *)[cellSelected viewWithTag:7];
                UILabel *subCategoryValueSelected = (UILabel *)[cellSelected viewWithTag:8];
                
                subCategoryName.text = subCategorySelected.text;
                
                NSString *categoryType = [self.filterCategories objectAtIndex:indexPath.section];
                
                [tableView deselectRowAtIndexPath:indexPath animated:YES];
                
                NSInteger section = indexPath.section;
                BOOL currentlyExpanded = [expandedSections containsIndex:section];
                NSInteger rows;
                
                
                NSMutableArray *tmpArray = [NSMutableArray array];
                
                if (currentlyExpanded)
                {
                    rows = [self tableView:tableView numberOfRowsInSection:section];
                    [expandedSections removeIndex:section];
                    
                }
                else
                {
                    [expandedSections addIndex:section];
                    rows = [self tableView:tableView numberOfRowsInSection:section];
                }
                
                
                for (int i=1; i<rows; i++)
                {
                    NSIndexPath *tmpIndexPath = [NSIndexPath indexPathForRow:i
                                                                   inSection:section];
                    [tmpArray addObject:tmpIndexPath];
                }
                
                if (currentlyExpanded)
                {
                    [tableView deleteRowsAtIndexPaths:tmpArray withRowAnimation:UITableViewRowAnimationTop];
                    
                    
                }
                else
                {
                    [tableView insertRowsAtIndexPaths:tmpArray
                                     withRowAnimation:UITableViewRowAnimationTop];
                }
                
                
                self.menuQuery = [NSString stringWithFormat:@"%@=%@",
                                  categoryType, subCategoryValueSelected.text];
                
                //[self.producthits  removeAllObjects];
                [self closeMenu:self.leftMenu];
                [self performSegueWithIdentifier:@"CatalogReturn" sender:nil];
                //[self loadingFromWeb : self.menuQuery : self.searchQuery];
                
            }
            
        }
        
    }else if(tableView == self.selectionTableView){
        //UITableViewCell *cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:indexPath.section]];
        UITableViewCell *cellSelected = [tableView cellForRowAtIndexPath:indexPath];
        //UILabel *refine1 = (UILabel *)[cellSelected viewWithTag:13];
        UILabel *refine2 = (UILabel *)[cellSelected viewWithTag:14];
        
        NSMutableDictionary *SinFiltro = [[NSMutableDictionary alloc] init];
        NSArray *keys = [self.selected_refinements allKeys];
        
        for (NSString *key in keys) {
            //NSLog(@"%@ >>>>>>> %@ %@",key, refine2.text, [self.selected_refinements objectForKey:key]);
            if([key isEqualToString: refine2.text] && ![key isEqualToString: @"cgid"]){
                //[self.selected_refinements removeObjectForKey:key];
            }else{
                [SinFiltro setObject:[self.selected_refinements objectForKey:key] forKey:key];
            }
            
        }
        
        //[self.producthits  removeAllObjects];
        
        [self closeMenu:self.leftMenu];
        
        self.selected_refinements = SinFiltro;
        
        //NSLog(@" %@ ",self.selected_refinements);
        [self performSegueWithIdentifier:@"CatalogReturn" sender:nil];
        
    }
    
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(tableView == self.tableView ){
    return 155.0;
    }
   return 35.0;
}



#pragma mark - POHorizontal List Delegate

- (void) didSelectItem:(ListItem *)item {
    
    self.productIDLabel.text =  item.Product_id;
    [self loadingProductFromWeb:item.Product_id];

}

#pragma mark - DYRate View Delegate

- (void)rateView:(DYRateView *)rateView changedToNewRate:(NSNumber *)rate {
    //self.rateLabel.text = [NSString stringWithFormat:@"Rate: %d", rate.intValue;
}




- (void)colorPressed:(id)sender
{
    
    UIButton *colorButton = (UIButton *)sender;
    int valueSelected = (int)colorButton.tag;
    
    NSString *colorValue = [[self.arrays objectForKey:@"c_searchColor"] objectAtIndex:valueSelected];
    
    self.menuQuery = [NSString stringWithFormat:@"c_searchColor=%@",
                      colorValue];
    
    [self closeMenu:self.leftMenu];
    //[self.producthits removeAllObjects];
    //[self loadingFromWeb : self.menuQuery : self.searchQuery];
    [self performSegueWithIdentifier:@"CatalogReturn" sender:nil];
}

- (void)sizePressed:(id)sender
{
    
    UIButton *SizeButton = (UIButton *)sender;
    int valueSelected = (int)SizeButton.tag;
    
    NSString *sizeValue = [[self.arrays objectForKey:@"c_sizeSearchValue"] objectAtIndex:valueSelected];
    
    //    NSString *sizeLabel = [[self.arrays objectForKey:@"Size"] objectAtIndex:valueSelected];
    
    self.menuQuery = [NSString stringWithFormat:@"c_sizeSearchValue=%@",
                      sizeValue];
    
    [self closeMenu:self.leftMenu];
    //[self.producthits removeAllObjects];
    //[self loadingFromWeb : self.menuQuery : self.searchQuery];
    [self performSegueWithIdentifier:@"CatalogReturn" sender:nil];
}

- (IBAction)CleanAllPressed:(id)sender
{
    
    [self closeMenu:self.leftMenu];
    //[self.producthits removeAllObjects];
    
    NSArray *keys = [self.selected_refinements allKeys];
    self.menuQuery = nil;
    for (NSString *key in keys) {
        if([key isEqualToString: @"cgid"]){
            self.menuQuery = [NSMutableString stringWithFormat:@"%@=%@",key, [self.selected_refinements objectForKey:key]];
            //NSLog(@"refine %@ %@",key, [self.selected_refinements objectForKey:key]);
        }
        
    }
    //NSLog(@"NEW QUERY %@",self.menuQuery);
    self.selected_refinements = nil;
    [self performSegueWithIdentifier:@"CatalogReturn" sender:nil];
    //[self loadingFromWeb : self.menuQuery : self.searchQuery];
}


#pragma mark - Web Services Methods

-(void)loadingFromWeb : (NSString *)wsString : (NSString *)wsquery
{
    //Show Loading View
    UIView *loadingView = (UIView *)[self.view viewWithTag:10];
    
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleWhiteLarge];
    indicator.frame = CGRectMake(403, 225, 10, 10);
    indicator.color = [UIColor darkGrayColor];
    [indicator startAnimating];
    [loadingView addSubview:indicator];
    loadingView.hidden = NO;
    
    
    if ([self.arrays count] > 0) {
        [self.arrays removeAllObjects];
    } else {
        self.arrays = [[NSMutableDictionary alloc] init];
    }
    
    for (int i = 0, cantidad = [self.filterCategories count]; i < cantidad; i = i + 1)
    {
        NSString *arrayPrintvalues = [self.filterCategories objectAtIndex:i];
        [self functionCreateArray: arrayPrintvalues];
        
        NSString *arrayDisplayValues = [self.filterLabels objectAtIndex:i];
        [self functionCreateArray: arrayDisplayValues];
    }
    
    NSMutableString  *wsRefines = [[NSMutableString alloc] init];
    BOOL isNoFirst = YES;
    
    if ([self.selected_refinements count] > 0) {
        NSInteger valor = [self.selected_refinements count]+1;
        wsString = [self urlEncodeValue: wsString];
        wsRefines  = [NSMutableString stringWithFormat:@"refine_%i=%@",valor,wsString];
        isNoFirst = YES;
    }else{
        wsString = [self urlEncodeValue: wsString];
        wsRefines  = [NSMutableString stringWithFormat:@"refine_1=%@",wsString];
        isNoFirst = NO;
    }
    
    
    NSMutableString *filters = [[NSMutableString alloc] init];
    
    
    if (isNoFirst) {
        NSArray *keys = [self.selected_refinements allKeys];
        int i = 1;
        
        for (NSString *key in keys) {
            NSMutableString *intermedium =[NSString stringWithFormat:@"refine_%i=%@=%@",i,key,[self.selected_refinements objectForKey:key]];
            i++;
            filters = [NSString stringWithFormat:@"%@%@&",filters,intermedium];
        }
        
        if(wsString != nil){
            
            filters = [NSString stringWithFormat:@"%@%@",filters,wsRefines];
        }
        
    } else {
        if(wsString != nil){
            // filters = [NSString stringWithFormat:@"%@",[wsRefines stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            filters = [NSString stringWithFormat:@"%@", wsRefines];
        }
    }
    
    //NSLog(@"filters %@",filters);
    
    NSString *wsStringQuery = [[NSString alloc] init];
    if (!(wsquery == nil) && !(wsString == nil) ){
        
        wsStringQuery = [NSString stringWithFormat:@"http://development.store.adidasgroup.demandware.net/s/adidas-GB/dw/shop/v12_6/product_search?&client_id=6cb8ee1e-8951-421e-a3e6-b738b816dfc3&%@&q=%@&start=1&count=30&expand=prices,images",  filters, wsquery];
        
    } else if(wsquery == nil && filters != nil) {
        wsStringQuery = [NSString stringWithFormat:@"http://development.store.adidasgroup.demandware.net/s/adidas-GB/dw/shop/v12_6/product_search?&client_id=6cb8ee1e-8951-421e-a3e6-b738b816dfc3&%@&start=1&count=30&expand=prices,images", filters];
    } else {
        wsStringQuery = [NSString stringWithFormat:@"http://development.store.adidasgroup.demandware.net/s/adidas-GB/dw/shop/v12_6/product_search?&client_id=6cb8ee1e-8951-421e-a3e6-b738b816dfc3&q=%@&start=1&count=30&expand=images,prices", wsquery];
    }
    
    //wsStringQuery = [self urlEncodeValue: wsStringQuery];
    
    NSLog(@"valor wsquery %@ ",wsStringQuery);
    
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:wsStringQuery]];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        
        NSDictionary *mainDict = JSON;
        
        //self.hitsValues = [mainDict objectForKey:@"hits"];
        self.refinementsValues = [mainDict objectForKey:@"refinements"];
        self.sorting_optionsValues = [mainDict objectForKey:@"sorting_options"];
        
        self.selected_refinements = [mainDict objectForKey:@"selected_refinements"];
        
        
        if (!expandedSections)
        {
            expandedSections = [[NSMutableIndexSet alloc] init];
        }
        
        NSMutableArray *arrayActiveFilters = [self.arrays objectForKey:@"c_filters"];
        NSMutableArray *arrayActiveFilters2 = [self.arrays objectForKey:@"Filters"];
        
        NSArray *keys = [self.selected_refinements allKeys];
        
        UIView *breadcumViewComplete = (UIView *)[self.view viewWithTag:2];
        
        UIView *breadcumView = nil;
        
        breadcumView = (UIView *)[self.view viewWithTag:888];
        [breadcumView removeFromSuperview];
        breadcumView = [[UIView alloc] init];
        [breadcumView setTag:888];
        
        int x = 100;
        
        for (int k=0; k< self.filterOrder.count; k++) {
            NSString *filterName = [self.filterOrder objectAtIndex:k];
            
            for (NSString *key in keys) {
                
                if([key isEqualToString:filterName]){
                    //NSLog(@" %i %@",k,filterName);
                    [arrayActiveFilters addObject:key];
                    [arrayActiveFilters2 addObject:[self.selected_refinements objectForKey:key]];
                    
                    UILabel *breadcumLabel = [[UILabel alloc]initWithFrame:CGRectMake(x, 6, 100, 40)];
                    
                    [breadcumLabel setBackgroundColor:[UIColor clearColor]];
                    [breadcumLabel setText:[self.selected_refinements objectForKey:key]];
                    [breadcumLabel setTextColor:[UIColor darkGrayColor]];
                    [breadcumLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:14.0]];
                    [breadcumView addSubview:breadcumLabel];
                    
                    CGSize textSize = [[breadcumLabel text] sizeWithFont:[breadcumLabel font]];
                    
                    UIImageView *breadcumImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bread_crumb_separador.png"]];
                    [breadcumImage setFrame:CGRectMake(x + textSize.width + 10, 10, 13, 36)];
                    [breadcumView addSubview:breadcumImage];
                    
                    x = x + textSize.width + 40;
                    break;
                }
                
            }
            
        }
        
        if(self.searchQuery != nil){
            NSString *labelQuery = self.searchQuery;
            int widthlong = 100;
            if([labelQuery length] > 12){
                widthlong = 250;
            }else if([labelQuery length] > 15)  {
                widthlong = 390;
            }else if([labelQuery length] > 20)  {
                widthlong = 490;
            }
            
            UILabel *breadcumLabel = [[UILabel alloc]initWithFrame:CGRectMake(x, 6, widthlong, 40)];
            
            [breadcumLabel setBackgroundColor:[UIColor clearColor]];
            
            
            NSString *filename = [[labelQuery lastPathComponent] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            [breadcumLabel setText: filename];
            [breadcumLabel setTextColor:[UIColor darkGrayColor]];
            [breadcumLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:14.0]];
            [breadcumView addSubview:breadcumLabel];
            
            CGSize textSize = [[breadcumLabel text] sizeWithFont:[breadcumLabel font]];
            
            UIImageView *breadcumImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bread_crumb_separador.png"]];
            [breadcumImage setFrame:CGRectMake(x + textSize.width + 10, 10, 13, 36)];
            [breadcumView addSubview:breadcumImage];

            
        }
        
        [breadcumViewComplete addSubview:breadcumView];
        
        for (int k=0; k< self.refinementsValues.count; k++) {
            NSDictionary *TypeRefinement = [self.refinementsValues objectAtIndex:k];
            
            NSString *variableInfoValues = [TypeRefinement objectForKey:@"attribute_id"];
            NSString *variableInfoDisplay = [TypeRefinement objectForKey:@"label"];
            
            
            if([variableInfoValues isEqualToString: @"c_searchColor"] || [variableInfoValues isEqualToString: @"c_sizeSearchValue"] ||[variableInfoValues isEqualToString: @"c_division"] || [variableInfoValues isEqualToString: @"c_sport"]
               || [variableInfoValues isEqualToString: @"cgid"]
               || [variableInfoValues  isEqualToString: @"c_productType"]){
                
                NSMutableArray *arrayInfoDisplay = [self.arrays objectForKey:variableInfoDisplay];
                NSMutableArray *arrayInfoValues = [self.arrays objectForKey:variableInfoValues];
                
                
                NSArray *values =[TypeRefinement objectForKey:@"values"];
                
                for (int m=0; m < values.count; m++) {
                    NSDictionary *valueInfo = [values objectAtIndex:m];
                    //PRODUCT TYPE MAYOR A 10 PARA FILTRAR
                    
                    if([variableInfoValues  isEqualToString: @"c_productType"]
                       && ([[valueInfo objectForKey:@"hit_count" ] integerValue] > 10)){
                        
                        NSString *information = [NSString stringWithFormat:@"%@  (%@)", [valueInfo objectForKey:@"value"], [[valueInfo objectForKey:@"hit_count"] stringValue]];
                        [arrayInfoDisplay addObject:information];
                        [arrayInfoValues addObject:[valueInfo objectForKey:@"value"]];
                    }
                    
                    if([variableInfoValues isEqualToString: @"cgid"]
                       && ([[valueInfo objectForKey:@"hit_count"] integerValue] > 0)){
                        if([[valueInfo objectForKey:@"value"] isEqualToString:@"men"]){
                            NSArray *valuesCategory =[valueInfo objectForKey:@"values"];
                            
                            NSDictionary *valueCat;
                            for (valueCat in valuesCategory) {
                                NSString *information = [NSString stringWithFormat:@"%@  (%@)",
                                                         [valueCat objectForKey:@"value"], [[valueCat objectForKey:@"hit_count"] stringValue]];
                                [arrayInfoDisplay addObject:information];
                                [arrayInfoValues addObject:[valueCat objectForKey:@"value"]];
                            }
                        }
                    }
                    
                    if([variableInfoValues isEqualToString: @"c_division"] || [variableInfoValues isEqualToString: @"c_sport"]){
                        NSString *information = [NSString stringWithFormat:@"%@  (%@)", [valueInfo objectForKey:@"value"], [[valueInfo objectForKey:@"hit_count"] stringValue]];
                        
                        [arrayInfoValues addObject:[valueInfo objectForKey:@"value"]];
                        [arrayInfoDisplay addObject:information];
                        
                    }
                    
                    if([variableInfoValues isEqualToString: @"c_searchColor"] || [variableInfoValues isEqualToString: @"c_sizeSearchValue"]){
                        [arrayInfoDisplay addObject:[valueInfo objectForKey:@"label"]];
                        [arrayInfoValues addObject:[valueInfo objectForKey:@"value"]];
                    }
                    
                }
            }
        }
        
        
      
        [self.menuTableView reloadData];
        [self.selectionTableView reloadData];
                
        //Dismiss Loading View
        CATransition *animation = [CATransition animation];
        animation.type = kCATransitionFade;
        animation.duration = 0.4;
        [loadingView.layer addAnimation:animation forKey:nil];
        loadingView.hidden = YES;
        
        
    }failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSLog(@"Request Failed with Error: %@, %@", error, error.userInfo);
        
        UIView *loadingView = (UIView *)[self.view viewWithTag:10];
        loadingView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"product_cont_holder.png"]];
        loadingView.hidden = YES;
        
        UIView *errorView = (UIView *)[self.view viewWithTag:404];
        errorView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"product_cont_holder.png"]];
        errorView.hidden = NO;
        
    }];
    
    
    [operation start];
    
}

- (void)functionCreateArray:(NSString *)arrayName {
    NSMutableArray *arrayTemp = [[NSMutableArray alloc] init];
    [self.arrays setValue:arrayTemp forKey:arrayName];
}

- (NSString *)urlEncodeValue:(NSString *)str
{
    NSString *result = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)str, NULL, CFSTR("&"), kCFStringEncodingUTF8));
    return result;
}


- (IBAction)categorySelected:(id)sender
{
    UIButton *button = (UIButton *)sender;
    int buttonTag = button.tag;
    self.selected_refinements = nil;
    self.searchQuery = nil;
    switch (buttonTag) {
        case 4:
            self.menuQuery  = @"cgid=men";
            self.titleQuery = @"Men";
            [self performSegueWithIdentifier:@"CatalogReturn" sender:nil];
            break;
            
        case 5:
            self.menuQuery  = @"cgid=women";
            self.titleQuery = @"Women";
            [self performSegueWithIdentifier:@"CatalogReturn" sender:nil];
            break;
            
        case 6:
            self.menuQuery  = @"cgid=kids";
            self.titleQuery = @"Kids";
            [self performSegueWithIdentifier:@"CatalogReturn" sender:nil];
            break;
            
    }
    
}



@end