//
//  Products.h
//  eStore
//
//  Created by Axel De Leon on 3/24/13.
//  Copyright (c) 2013 CLH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Products : NSManagedObject

@property (nonatomic, retain) NSString * currency;
@property (nonatomic, retain) NSString * identifier;
@property (nonatomic, retain) NSData * image;
@property (nonatomic, retain) NSString * link;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * price;
@property (nonatomic, retain) NSDate * sortDate;

@end
