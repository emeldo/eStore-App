//
//  ShoppingCart.h
//  eStore
//
//  Created by VQL Developer on 5/8/13.
//  Copyright (c) 2013 VQL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ShoppingCart : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * identifier;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSNumber * qty;
@property (nonatomic, retain) NSString * size;
@property (nonatomic, retain) NSString * price;
@property (nonatomic, retain) NSString * currency;
@property (nonatomic, retain) NSData * image;

@end
