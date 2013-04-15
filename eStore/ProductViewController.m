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

@interface ProductViewController () {
    NSMutableArray *itemArray;
    NSMutableArray *freeList;
    NSMutableArray *paidList;
    NSMutableArray *grossingList;
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

@property (nonatomic, strong) NSMutableArray  *Commenthits;

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
    
    NSMutableArray *arrayActiveFilters = [self.arrays objectForKey:@"c_filters"];
    NSMutableArray *arrayActiveFilters2 = [self.arrays objectForKey:@"Filters"];
    
    
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
    
    for (NSString *key in keys) {
        
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
    }
    
    [breadcumViewComplete addSubview:breadcumView];
    
    self.Commenthits = [[NSMutableArray alloc] init];

    //Loading Overview and Color Information
    [self loadingProductFromWeb:product.product_id];
    [self loadingCommentProductFromWeb:product.product_id];

      [self.mybuttonComments addTarget:self action:@selector(myButtonClick:) forControlEvents:(UIControlEvents)UIControlEventTouchDown];
    
}


- (void)myButtonClick:(id)sender {
    NSLog(@"Clicked");
    //MJComments *mjViewController = [[MJComments alloc] initWithNibName:@"MJComments" bundle:nil];
    //mjViewController.Commenthits = self.Commenthits;
    
    //[self presentPopupViewController:mjViewController animationType:0];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)loadScrollView {
    //NSLog(@"pageimage %i - images %i ",[self.pageImages count],[self.imagesByArticle count]);
    
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

-(void)loadingProductFromWeb : (NSString *)wsProduct_SKU
{
    //Show Loading View
    UIView *loadingView = (UIView *)[self.view viewWithTag:501];
    loadingView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"product_cont_holder.png"]];

    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleWhiteLarge];
    indicator.frame = CGRectMake(499, 225, 10, 10);
    indicator.color = [UIColor darkGrayColor];
    [indicator startAnimating];
    [loadingView addSubview:indicator];
    loadingView.hidden = NO;
    
    
    
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
        CATransition *animation = [CATransition animation];
        animation.type = kCATransitionFade;
        animation.duration = 0.4;
        [loadingView.layer addAnimation:animation forKey:nil];
        loadingView.hidden = YES;


    }failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSLog(@"Request Failed with Error: %@, %@", error, error.userInfo);
        
        //  [self performSegueWithIdentifier:@"notFound" sender:nil];
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
            
             NSLog(@"total  %i", [ContextDataValues count]);
            
            for(int j = 0 ; j < [ContextDataValuesOrder count]; j++){
               NSString *value =  [ContextDataValuesOrder objectAtIndex:j];
               NSLog(@" %@",value);
               
                
                 for(int K = 0 ; K < [ContextDataValues count]; K++){
                // NSDictionary *xa =  [ContextDataValues :K];
                // NSLog(@" %@ ", xa );
                 }
            
                   
                
  
            }
            
            
            [self.Commenthits addObject:Comment];
           }
       

        
    }failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSLog(@"Request Failed with Error: %@, %@", error, error.userInfo);
        
        //[self performSegueWithIdentifier:@"notFound" sender:nil];
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
    
    
}


-(void)loadingOverviewtFromWeb : (NSString *)wsStringQuery
{

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
        
        NSString *htmlBody = [[NSString alloc] initWithFormat:@"<html> \n"
                              "<head> \n"
                              "<style type=\"text/css\"> \n"
                              "body {font-family: \"helvetica\"; font-size: 13px;}\n"
                              "</style> \n"
                              "</head> \n"
                              "<body><div align='justify' style='font-family=Arial'>%@ <br> %@<div></body> \n"
                              "</html>", short_description,bullets_description];
        
        [self.webviewName loadHTMLString:htmlBody baseURL:nil];
        
    }failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSLog(@"Request Failed with Error: %@, %@", error, error.userInfo);
    }];
    
    [operation start];
    
}


- (void)addButtonsSize {
    
    int positionx = 20;
    int positiony = 0;
    int counter = 0;
   
    
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

        positionx = positionx + 46;
        counter++;
        
        if(counter >= 7){
            positiony = positiony + 40;
            positionx = 20;
            counter = 0;
        }
        
        [self.scrollViewSize addSubview:playButton]; 
    }
   
    [self.scrollViewSize setContentSize:(CGSizeMake(320, positiony))];
    
    //[playButton addTarget:self action:@selector(playAction:) forControlEvents:UIControlEventTouchUpInside];
  
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

#pragma mark - Table View DataSources

- (int)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 155.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    NSString *title = @"";
    POHorizontalList *list;
    
    if ([indexPath row] == 0) {
        list = [[POHorizontalList alloc] initWithFrame:CGRectMake(0.0, 0.0, 352.0, 155.0) title:title items:freeList];
    }
    
    [list setDelegate:self];
    [cell.contentView addSubview:list];
    
    return cell;
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





@end