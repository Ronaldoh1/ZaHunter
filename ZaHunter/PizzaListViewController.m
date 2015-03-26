//
//  ViewController.m
//  ZaHunter
//
//  Created by Ronald Hernandez on 3/25/15.
//  Copyright (c) 2015 Ron. All rights reserved.
//

#import "PizzaListViewController.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface PizzaListViewController ()<CLLocationManagerDelegate>

//---Need a location manager to manage user's current location --//

@property CLLocationManager *locationManager;
@property CLLocation *currentLocation;

@end

@implementation PizzaListViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    //set the delegate for the current view controller.

    self.locationManager.delegate = self;
    self.locationManager = [CLLocationManager new];

    //call helper method to update user's current location.
    [self UpdateUserCurrentLocation];

 
}

-(void)UpdateUserCurrentLocation{
    [self.locationManager requestWhenInUseAuthorization];
    [self.locationManager startUpdatingLocation];

}


#pragma Mark CLLocationManager-Delegate Methods

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{

    self.currentLocation = locations.firstObject;
    NSLog(@"%@",self.currentLocation);

}


@end
