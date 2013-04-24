//
//  StoreLocation.h
//  Store Stock
//
//  Created by VQL on 12/29/12.
//  Copyright (c) 2012 VQL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface StoreLocation : NSObject <MKAnnotation>

- (id)initWithName:(NSString*)name address:(NSString*)address coordinate:(CLLocationCoordinate2D)coordinate;
- (MKMapItem*)mapItem;

@end

