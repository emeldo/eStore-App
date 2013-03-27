//
//  Product.h
//  eStore
//
//  Created by VQL Developer on 3/18/13.
//  Copyright (c) 2013 CLH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Product : NSObject

@property (nonatomic, strong) NSString *product_id; // name of product_id
@property (nonatomic, strong) NSString *product_name; // product_name
@property (nonatomic, strong) NSString *link; // link
@property (nonatomic, strong) NSString *image; // image
@property (nonatomic, strong) NSString *currency; // currency
@property (nonatomic, strong) NSString *price; // price
@property (nonatomic, strong) UIImage *imageValue; // price

@end
