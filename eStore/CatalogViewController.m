//
//  CatalogViewController.m
//  eComm Mobile
//
//  Created by HNL on 2/28/13.
//  Copyright (c) 2013 CLH. All rights reserved.
//

#import "CatalogViewController.h"
#import "AFJSONRequestOperation.h"
#import "Product.h"
#import "Products.h"
#import "ProductViewController.h"
#import "StoresViewController.h"
#import "HistoryViewController.h"
#import "SettingsViewController.h"
#import "UIImageView+WebCache.h"
#import "CoreDataHelper.h"
#import "Settings.h"

@interface CatalogViewController () {
    int rightMenuY;
    int rightBevelWidth;
    int leftMenuY;
    int leftBevelWidth;
    
    
    NSString *categoryValue;
    NSString *categoryValueName;
    
    NSMutableIndexSet *expandedSections;
    NSArray *category;
    NSArray *productCategory;
    NSArray *brand;
    NSArray *sport;
    NSArray *color;
    NSArray *sizes;
}

@property (nonatomic, assign) BOOL leftMenuVisible;
@property (nonatomic, assign) BOOL rightMenuVisible;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (strong, nonatomic) NSArray *settings;
@property (strong, nonatomic) Settings *userInfo;
@property (strong, nonatomic) DACircularProgressView *largeProgressView;
@property (strong, nonatomic) Product *productSelected;
//////////////////////////////////////////////////EMELDO
@property (nonatomic, strong) NSArray *filterCategories;
@property (nonatomic, strong) NSArray *filterLabels;
@property (nonatomic, strong) NSArray *filterOrder;

@property (nonatomic, strong) NSArray *refinementsValues;
@property (nonatomic, strong) NSArray *hitsValues;
@property (nonatomic, strong) NSArray *sorting_optionsValues;
//@property (nonatomic, strong) NSMutableDictionary *selected_refinements;
@property (nonatomic, strong) NSMutableArray *pageImages;
@property (nonatomic, strong) UILabel *breadcrumb;

@property (nonatomic, readwrite, retain) NSMutableDictionary *arrays;


@property (nonatomic, strong) NSArray  *recipeImages;
@property (nonatomic, strong) NSArray  *recipes;
@property (nonatomic, strong) NSMutableArray  *producthits;


//////////////////////////////////////////////////EMELDO

@end

@implementation CatalogViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


#pragma mark - Instance Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Setting Main Background
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_catalog.png"]];
    
    UIView *catalogView = (UIView *)[self.view viewWithTag:9];
    catalogView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"product_cont_holder.png"]];
    
    
    //Setting Search Bar
    [[UISearchBar appearance] setImage:[UIImage imageNamed:@"icon_search.png"] forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
    
    UIImage *searchFieldBg = [UIImage imageNamed:@"catalog_search_bar.png"];
    [[UISearchBar appearance] setSearchFieldBackgroundImage:searchFieldBg forState:UIControlStateNormal];
    [[UISearchBar appearance] setSearchFieldBackgroundPositionAdjustment:UIOffsetMake(0, -1)];
    
    
    //Setting Navigation Bar
    UIImageView* img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo_adidas_02.png"]];
    self.navigationItem.titleView = img;
    
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 184, 27)];
    self.searchBar.backgroundImage = [[UIImage alloc] init];
    self.searchBar.delegate = self;
    
    UITextField *searchField = [self.searchBar valueForKey:@"_searchField"];
    searchField.textColor = [UIColor whiteColor];
    searchField.font = [UIFont boldSystemFontOfSize:[UIFont systemFontSize]];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.searchBar];
    
    //Setting Breadcum Bar
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
    
    
    self.filterCategories = [[NSArray alloc] initWithObjects: @"c_productType", @"c_sport", @"cgid", @"c_division", @"c_searchColor",  @"c_sizeSearchValue", @"c_filters", nil];
    
    self.filterLabels = [[NSArray alloc] initWithObjects: @"Product Type", @"Sport", @"Category", @"Brand", @"Colour", @"Size", @"Filters", nil];
    
    
    self.filterOrder = [[NSArray alloc] initWithObjects:  @"cgid", @"c_division", @"c_sport", @"c_productType", @"c_searchColor",  @"c_sizeSearchValue", nil];
    
    self.producthits = [[NSMutableArray alloc] init];
    
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]
                                   initWithTitle: @"Back"
                                   style: UIBarButtonItemStyleBordered
                                   target: nil action: nil];
    
    [self.navigationItem setBackBarButtonItem: backButton];
    
    
    [self loadingFromWeb : self.menuQuery : self.searchQuery];
    
    
}


- (void)viewDidAppear:(BOOL)animated {
    
    self.settings = [CoreDataHelper getObjectsForEntity:@"Settings" withSortKey:@"catalogView" andSortAscending:YES andContext:self.managedObjectContext];
    
    if ([self.settings count] == 0) {
        self.userInfo = [NSEntityDescription insertNewObjectForEntityForName:@"Settings" inManagedObjectContext:self.managedObjectContext];
        self.userInfo.catalogView = @"Colletion";
        NSError *error = nil;
        if (![self.managedObjectContext save:&error]) {
            NSLog(@"Whoops, couldn't save changes: %@", [error localizedDescription]);
        }
        self.settings = [CoreDataHelper getObjectsForEntity:@"Settings" withSortKey:@"catalogView" andSortAscending:YES andContext:self.managedObjectContext];
    }
    
    self.userInfo = [self.settings objectAtIndex:0];
    
    if ([self.userInfo.catalogView isEqualToString:@"Table"])
    {
        self.productTableView.hidden = NO;
        self.collectionView.hidden = YES;
    } else {
        self.productTableView.hidden = YES;
        self.collectionView.hidden = NO;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(yourNotificationHandler:)
                                                 name:@"MODELVIEW" object:nil];
    
}



//Now create yourNotificationHandler: like this in parent class
-(void)yourNotificationHandler:(NSNotification *) notification{
    
    self.productSelected = nil;
    NSDictionary *userInfo = notification.userInfo;
    self.productSelected = [userInfo objectForKey:@"someKey"];
    
    NSLog(@"%@", self.productSelected.product_name);
    [self performSegueWithIdentifier:@"sendshowProductDetail" sender:nil];
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}


- (void)viewDidUnload
{
    [self setLeftMenu:nil];
    [self setRightMenu:nil];
    [self setProductTableView:nil];
    [self setMenuQuery:nil];
    [self setSearchQuery:nil];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.leftMenu.frame = CGRectMake(self.leftMenu.frame.size.width * -1 + leftBevelWidth, leftMenuY, self.leftMenu.frame.size.width, self.leftMenu.frame.size.height);
    self.leftMenu.hidden = false;
    
    self.rightMenu.frame = CGRectMake(self.view.frame.size.width - rightBevelWidth, rightMenuY, self.rightMenu.frame.size.width, self.rightMenu.frame.size.height);
    self.rightMenu.hidden = false;
}


- (IBAction)changeViews:(id)sender
{
    
    // Saving data in Core Data for settings
    [CoreDataHelper deleteAllObjectsForEntity:@"Settings" andContext:self.managedObjectContext];
    self.userInfo = [NSEntityDescription insertNewObjectForEntityForName:@"Settings" inManagedObjectContext:self.managedObjectContext];
    
    UIButton *button = (UIButton *)sender;
    int buttonTag = button.tag;
    
    switch (buttonTag) {
        case 11:
            self.collectionView.hidden = NO;
            self.productTableView.hidden = YES;
            self.userInfo.catalogView = @"Colletion";
            break;
            
        case 12:
            self.collectionView.hidden = YES;
            self.productTableView.hidden = NO;
            self.userInfo.catalogView = @"Table";
            break;
    }
    
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Whoops, couldn't save changes: %@", [error localizedDescription]);
    }
    
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

#pragma mark - Web Services Methods

-(void)loadingFromWeb : (NSString *)wsString : (NSString *)wsquery
{
    NSLog(@"REVISANDO DATOS %@ -- %@ ",wsString,wsquery);
    //Show Loading View
    
    self.leftMenu.userInteractionEnabled = NO;
    self.rightMenu.userInteractionEnabled = NO;
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
            NSMutableString *intermedium =[NSString stringWithFormat:@"refine_%i=%@=%@",i,key,
                                           [self urlEncodeValue: [self.selected_refinements objectForKey:key]]];
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
    
    NSLog(@"filters %@",filters);
    
    NSString *wsStringQuery = [[NSString alloc] init];
    if (!(wsquery == nil) && !(wsString == nil) ){
        
        wsStringQuery = [NSString stringWithFormat:@"http://development.store.adidasgroup.demandware.net/s/adidas-GB/dw/shop/v12_6/product_search?&client_id=6cb8ee1e-8951-421e-a3e6-b738b816dfc3&%@&q=%@&start=1&count=40&expand=prices,images",  filters, wsquery];
        
    } else if(wsquery == nil && filters != nil) {
        wsStringQuery = [NSString stringWithFormat:@"http://development.store.adidasgroup.demandware.net/s/adidas-GB/dw/shop/v12_6/product_search?&client_id=6cb8ee1e-8951-421e-a3e6-b738b816dfc3&%@&start=1&count=40&expand=prices,images", filters];
    } else {
        wsStringQuery = [NSString stringWithFormat:@"http://development.store.adidasgroup.demandware.net/s/adidas-GB/dw/shop/v12_6/product_search?&client_id=6cb8ee1e-8951-421e-a3e6-b738b816dfc3&q=%@&start=1&count=40&expand=images,prices", wsquery];
    }
    
    //wsStringQuery = [self urlEncodeValue: wsStringQuery];
    
    NSLog(@"valor wsquery %@ ",wsStringQuery);
    
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:wsStringQuery]];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        
        
        //Dismiss Loading View
        CATransition *animation = [CATransition animation];
        animation.type = kCATransitionFade;
        animation.duration = 0.4;
        [loadingView.layer addAnimation:animation forKey:nil];
        
        NSDictionary *mainDict = JSON;
        
        self.hitsValues = [mainDict objectForKey:@"hits"];
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
                    NSLog(@" %i %@",k,filterName);
                    [arrayActiveFilters addObject:key];
                    [arrayActiveFilters2 addObject:[self.selected_refinements objectForKey:key]];
                    int withlong = 100;
                    if([[self.selected_refinements objectForKey:key] length] > 13){
                        withlong = 150;
                    }
                    UILabel *breadcumLabel = [[UILabel alloc]initWithFrame:CGRectMake(x, 6, withlong, 40)];
                    
                    [breadcumLabel setBackgroundColor:[UIColor clearColor]];
                    NSString *text = [self.selected_refinements objectForKey:key];
                    NSString *capitalized = [[[text substringToIndex:1] uppercaseString] stringByAppendingString:[text substringFromIndex:1]];

                    [breadcumLabel setText:capitalized];
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
            NSLog(@"PILLA %@ ",filename);
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
        
        
        for (int k=0; k< self.hitsValues.count; k++) {
            NSDictionary *hits = [self.hitsValues objectAtIndex:k];
            
            Product *product = [Product new];
            product.product_id = [hits objectForKey:@"product_id"];
            product.product_name = [hits objectForKey:@"product_name"];
            product.price = [hits objectForKey:@"price"];
            
            product.currency = [hits objectForKey:@"currency"];
            product.link = [hits objectForKey:@"link"];
            
            NSDictionary *imageView = [hits objectForKey:@"image"];
            
            NSArray *keys = [imageView allKeys];
            
            for (NSString *key in keys) {
                if([key isEqualToString: @"link"]){
                    product.image = [imageView objectForKey:key];
                }
            }
            
            [self.producthits addObject:product];
            
        }
               
        if(self.hitsValues.count == 0){
            UIView *errorView = (UIView *)[self.view viewWithTag:404];
            errorView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"product_cont_holder.png"]];
            errorView.hidden = NO;
        }
        
        [self.collectionView reloadData];
        [self.productTableView reloadData];
        [self.menuTableView reloadData];
        [self.selectionTableView reloadData];
        
        
        self.leftMenu.userInteractionEnabled = YES;
        self.rightMenu.userInteractionEnabled = YES;
        
        loadingView.hidden = YES;
       
        
    }failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSLog(@"Request Failed with Error: %@, %@", error, error.userInfo);
        
        UIView *loadingView = (UIView *)[self.view viewWithTag:10];
        loadingView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"product_cont_holder.png"]];
        loadingView.hidden = YES;
       // [self stopAnimation];
        
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


#pragma mark - Search Bar Delegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self.producthits  removeAllObjects];
    [searchBar resignFirstResponder];
    [self loadingFromWeb : nil : [searchBar.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    searchBar.text = @"";
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
    } else if (tableView == self.selectionTableView) {
        NSMutableArray *arraySelection = [self.arrays objectForKey:@"Filters"];
        return [arraySelection count];
    }
    return [self.producthits count];
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
        cellIdentifier = @"CatalogCell";
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
        
        //NSLog(@" %@ %@ ",filters.text,filterName.text);
        
        if([[[self.arrays objectForKey:@"c_filters"] objectAtIndex:indexPath.row] isEqualToString:@"cgid"]){
            filterImageView.hidden = YES;
        }else{
            filterImageView.hidden = NO;
        }
        
        
    } else {
        
        UILabel *ProductName = (UILabel *)[cell viewWithTag:203];
        UILabel *ProducCode = (UILabel *)[cell viewWithTag:204];
        
        //UILabel *ProductColor = (UILabel *)[cell viewWithTag:205];
        UILabel *ProductPrice = (UILabel *)[cell viewWithTag:206];
        UILabel *ProductCurrency = (UILabel *)[cell viewWithTag:207];
        
        UIView *ratingView = (UIView *)[cell viewWithTag:208];
        UIImageView *imageProduct = (UIImageView *)[cell viewWithTag:200];
        imageProduct.hidden = YES;
        
        
        DYRateView *rateView = [[DYRateView alloc] initWithFrame:CGRectMake(0, 0, 200, 20)];
        rateView.padding = 10;
        rateView.rate = 3;
        rateView.alignment = RateViewAlignmentLeft;
        [ratingView addSubview:rateView];
        
        Product *product = [self.producthits objectAtIndex:indexPath.row];
        NSString *string = product.price;
        
        
        NSURL *urlImage = [NSURL URLWithString:[product.image stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        
        
        UIActivityIndicatorView *animation = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        animation.tag = indexPath.row;
        animation.center = CGPointMake(60, 52);
        [animation startAnimating];
        [cell addSubview:animation];
        
        SDWebImageManager *manager = [SDWebImageManager sharedManager];
        
        [manager downloadWithURL:urlImage
                         options:0
                        progress:^(NSUInteger receivedSize, long long expectedSize)
         {
             
         }
                       completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL dummy)
         {
             
             
             [animation stopAnimating];
             if(error == nil){
             if (image)
             {
                 imageProduct.image = image;
                 imageProduct.hidden = NO;
             }
              else {
                 imageProduct.image = [UIImage imageNamed:@"img_not_available_03.png"];
                 imageProduct.hidden = NO;
             }
             }else{
                 imageProduct.image = [UIImage imageNamed:@"img_not_available_03.png"];
                 imageProduct.hidden = NO;
             }
         }];
        
        
        ProducCode.text = product.product_id;
        ProductName.text = product.product_name;
        ProductPrice.text = [NSString stringWithFormat:@"%@", string];
        ProductCurrency.text = product.currency;
        
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
    } }


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
                
                [self.producthits  removeAllObjects];
                [self closeMenu:self.leftMenu];
                
                [self loadingFromWeb : self.menuQuery : self.searchQuery];
                
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
                //NSLog(@"%@ a borrar %@",key, [self.selected_refinements objectForKey:key]);
                //[self.selected_refinements removeObjectForKey:key];
            }else{
                [SinFiltro setObject:[self.selected_refinements objectForKey:key] forKey:key];
            }
            
        }
        
        [self.producthits  removeAllObjects];
        
        [self closeMenu:self.leftMenu];
        
        self.selected_refinements = SinFiltro;
        
        NSLog(@" %@ ",self.selected_refinements);
        
        [self loadingFromWeb :nil : self.searchQuery];
        
    }else if(tableView == self.productTableView){
        Product *product = [self.producthits objectAtIndex:indexPath.row];
        
        // Saving data in Core Data for historcial use
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Products" inManagedObjectContext:self.managedObjectContext];
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
        
        Products *productFound = [NSEntityDescription insertNewObjectForEntityForName:@"Products" inManagedObjectContext:self.managedObjectContext];
        productFound.identifier = product.product_id;
        productFound.name = product.product_name;
        productFound.link = product.link;
        productFound.price = [NSString stringWithFormat:@"%@",product.price];
        productFound.sortDate = [NSDate date];
        
        
        //NSLog(@" %@ <-~~~-  -~~~-> %@ ",self.titleQuery , self.searchQuery);
        
        if(self.searchQuery != nil){
            productFound.category = self.searchQuery;
        }else{
            productFound.category = self.titleQuery;
        }
        
        
        
        productFound.currency = product.currency;
        
        UIImageView *thumbnailImageView = [[UIImageView alloc] init];
        
        thumbnailImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 130, 114)];
        thumbnailImageView.contentMode  = UIViewContentModeScaleAspectFit;
        thumbnailImageView.image = product.imageValue;
        
        productFound.image = UIImagePNGRepresentation(thumbnailImageView.image);
        
        NSError *error = nil;
        if (![self.managedObjectContext save:&error]) {
            NSLog(@"Whoops, couldn't save changes: %@", [error localizedDescription]);
        }
        
    }

    
}


#pragma mark - Collection View DataSource


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [self.producthits count];
    
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"Cell";
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    Product *product = [self.producthits objectAtIndex:indexPath.row];
    UIImageView *recipeImageView = (UIImageView *)[cell viewWithTag:100];
    
    
    UILabel *productNameLabel = (UILabel *)[cell viewWithTag:102];
    productNameLabel.text = product.product_name;
    
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
    
  
    
    
    NSString* urlString = product.image;
    
    
    
    recipeImageView.hidden = YES;
    
    if(urlString != nil) {
        UIActivityIndicatorView *animation = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        animation.tag = indexPath.row;
        animation.center = CGPointMake(60, 52);
        [animation startAnimating];
        [cell addSubview:animation];
       
       
        
        NSURL *urlImage = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        
        SDWebImageManager *manager = [SDWebImageManager sharedManager];
        
        [manager downloadWithURL:urlImage
                         options:0
                        progress:^(NSUInteger receivedSize, long long expectedSize)
         {
            // NSLog(@"URL STRING: %@ %@", urlString,product.product_name);
         }
                       completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL dummy)
         {
             
            // NSLog(@"Error %@",error);
             
             [animation stopAnimating];
             if(error == nil){
                 if (image)
                 {
                     recipeImageView.image = image;
                     product.imageValue = image;
                     recipeImageView.hidden = NO;
                 }else{
                     product.imageValue = nil;
                     recipeImageView.image = [UIImage imageNamed:@"img_not_available_03.png"];
                     recipeImageView.hidden = NO;
                 }
             }else{
                 product.imageValue = nil;
                 recipeImageView.image = [UIImage imageNamed:@"img_not_available_03.png"];
                 recipeImageView.hidden = NO;
             }
         }];
        
    }
    
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showProductDetail"]) {
        
        NSIndexPath *indexPath = [[self.collectionView indexPathsForSelectedItems] lastObject];
        ProductViewController *destViewController = segue.destinationViewController;
        destViewController.product = [self.producthits objectAtIndex:indexPath.row];
        destViewController.selected_refinements = self.selected_refinements;
        destViewController.arrays = self.arrays;
        destViewController.managedObjectContext = self.managedObjectContext;
        
    }
    
    
    if ([segue.identifier isEqualToString:@"Catalog"]) {
        
        CatalogViewController *catalogViewController = [segue destinationViewController];
        catalogViewController.menuQuery = categoryValue;
        catalogViewController.titleQuery = categoryValueName;
        catalogViewController.searchQuery = [self.searchBar.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        catalogViewController.managedObjectContext = self.managedObjectContext;
        self.searchBar.text = nil;
        category = nil;
    }
    
    
    if ([segue.identifier isEqualToString:@"Stores"]) {
        StoresViewController *storesViewController = [segue destinationViewController];
        storesViewController.managedObjectContext = self.managedObjectContext;
        
    }
    
    if ([segue.identifier isEqualToString:@"History"]) {
        HistoryViewController *historyViewController = [segue destinationViewController];
        historyViewController.managedObjectContext = self.managedObjectContext;
        
    }
    
    if ([segue.identifier isEqualToString:@"sendshowProductDetail"]) {
        
        ProductViewController *destViewController = segue.destinationViewController;
        Product *product = self.productSelected;
        destViewController.product = product;
        destViewController.managedObjectContext = self.managedObjectContext;
        
    }
    
    if ([segue.identifier isEqualToString:@"Settings"]) {
        SettingsViewController *settingsViewController = [segue destinationViewController];
        settingsViewController.managedObjectContext = self.managedObjectContext;
        
    }

}


#pragma mark - Collection View Delegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    Product *product = [self.producthits objectAtIndex:indexPath.row];
    
    // Saving data in Core Data for historcial use
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Products" inManagedObjectContext:self.managedObjectContext];
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
    
    Products *productFound = [NSEntityDescription insertNewObjectForEntityForName:@"Products" inManagedObjectContext:self.managedObjectContext];
    productFound.identifier = product.product_id;
    productFound.name = product.product_name;
    productFound.link = product.link;
    productFound.price = [NSString stringWithFormat:@"%@",product.price];
    productFound.sortDate = [NSDate date];
    
    if(self.searchQuery != nil){
        productFound.category = self.searchQuery;
    }else{
        productFound.category = self.titleQuery;
    }
    
    
    
    productFound.currency = product.currency;
    
    UIImageView *thumbnailImageView = [[UIImageView alloc] init];
    
    thumbnailImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 130, 114)];
    thumbnailImageView.contentMode  = UIViewContentModeScaleAspectFit;
    thumbnailImageView.image = product.imageValue;
    
    productFound.image = UIImagePNGRepresentation(thumbnailImageView.image);
    
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Whoops, couldn't save changes: %@", [error localizedDescription]);
    }
    
}

#pragma mark - DYRateView Delegate

- (void)rateView:(DYRateView *)rateView changedToNewRate:(NSNumber *)rate {
    // self.rateLabel.text = [NSString stringWithFormat:@"Rate: %d", rate.intValue];
}

- (void)setUpEditableRateView {
    DYRateView *rateView = [[DYRateView alloc] initWithFrame:CGRectMake(0, 40, self.view.bounds.size.width, 20) fullStar:[UIImage imageNamed:@"StarFullLarge.png"] emptyStar:[UIImage imageNamed:@"StarEmptyLarge.png"]];
    rateView.padding = 20;
    rateView.alignment = RateViewAlignmentCenter;
    rateView.editable = YES;
    rateView.delegate = self;
    [self.view addSubview:rateView];
    
}

#pragma BORRAR DESPUES

- (IBAction)categorySelected:(id)sender
{
    
    
    UIButton *button = (UIButton *)sender;
    int buttonTag = button.tag;
    self.selected_refinements = nil;
    self.searchBar.text = nil;
    [self.producthits removeAllObjects];
    
    switch (buttonTag) {
        case 4:
            self.menuQuery  = @"cgid=men";
            self.titleQuery = @"Men";
            break;
            
        case 5:
            self.menuQuery  = @"cgid=women";
            self.titleQuery = @"Women";
            break;
            
        case 6:
            self.menuQuery  = @"cgid=kids";
            self.titleQuery = @"Kids";
            break;
            
           }
    
    [self closeMenu:self.rightMenu];
    [self loadingFromWeb : self.menuQuery : self.searchQuery];
    
    
}

-(int) getRandomNumberBetweenMin:(int)min andMax:(int)max
{
	return ( (arc4random() % (max-min+1)) + min );
}


- (void)colorPressed:(id)sender
{
    
    UIButton *colorButton = (UIButton *)sender;
    int valueSelected = (int)colorButton.tag;
    
    NSString *colorValue = [[self.arrays objectForKey:@"c_searchColor"] objectAtIndex:valueSelected];
    
    self.menuQuery = [NSString stringWithFormat:@"c_searchColor=%@",
                      colorValue];
    
    [self closeMenu:self.leftMenu];
    [self.producthits removeAllObjects];
    [self loadingFromWeb : self.menuQuery : self.searchQuery];
    
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
    
    [self.producthits removeAllObjects];
    
    [self loadingFromWeb : self.menuQuery : self.searchQuery];
}

- (IBAction)CleanAllPressed:(id)sender
{
    
    [self closeMenu:self.leftMenu];
    
    [self.producthits removeAllObjects];
    
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
    [self loadingFromWeb : self.menuQuery : self.searchQuery];
}

- (NSString *)urlEncodeValue:(NSString *)str
{
    NSString *result = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)str, NULL, CFSTR("&"), kCFStringEncodingUTF8));
    return result;
}

#pragma CIRCULAR REFERENCE
/*
- (void)progressChange
{
    for (DACircularProgressView *progressView in [NSArray arrayWithObjects: self.largeProgressView, nil])
    {
        CGFloat progress = ![self.timer isValid] ? self.stepper.value / 10.f : progressView.progress + 0.01f;
        [progressView setProgress:progress animated:YES];
        
        if (progressView.progress >= 1.0f && [self.timer isValid])
        {
            [progressView setProgress:0.f animated:YES];
        }
        
        self.progressLabel.text = [NSString stringWithFormat:@"%.2f", progressView.progress];
    }
}

- (void)startAnimation
{
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.03 target:self selector:@selector(progressChange) userInfo:nil repeats:YES];
    self.continuousSwitch.on = YES;
}

- (void)stopAnimation
{
    [self.timer invalidate];
    self.timer = nil;
    self.continuousSwitch.on = NO;
}

- (IBAction)toggleAnimation:(id)sender
{
    if (self.continuousSwitch.on)
    {
        [self startAnimation];
    }
    else
    {
        [self stopAnimation];
    }
}

- (IBAction)toggleIndeterminate:(id)sender
{
    for (DACircularProgressView *progressView in [NSArray arrayWithObjects: self.largeProgressView, nil])
    {
        progressView.indeterminate = self.indeterminateSwitch.on;
    }
}

- (IBAction)step:(id)sender
{
    [self stopAnimation];
    [self progressChange];
}
*/

@end
