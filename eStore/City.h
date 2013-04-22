//
//  City.h
//  eStore
//
//  Created by Axel De Leon on 4/21/13.
//  Copyright (c) 2013 VQL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface City : NSManagedObject

@property (nonatomic, retain) NSString * country;
@property (nonatomic, retain) NSString * name;

@end
