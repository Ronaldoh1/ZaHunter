//
//  Pizzeria.h
//  ZaHunter
//
//  Created by Ronald Hernandez on 3/25/15.
//  Copyright (c) 2015 Ron. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface Pizzeria : NSObject

@property NSString *address;
@property float milesDifference; 
@property MKMapItem *mapItem;

@end
