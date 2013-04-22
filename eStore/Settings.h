//
//  Settings.h
//  eStore
//
//  Created by Axel De Leon on 4/21/13.
//  Copyright (c) 2013 VQL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Settings : NSManagedObject

@property (nonatomic, retain) NSString * catalogView;
@property (nonatomic, retain) NSString * city;
@property (nonatomic, retain) NSString * country;
@property (nonatomic, retain) NSString * countryIdentifier;
@property (nonatomic, retain) NSString * storeIdentifier;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * store;

@end
