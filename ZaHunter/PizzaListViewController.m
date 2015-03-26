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
#import "Pizzeria.h"

@interface PizzaListViewController ()<CLLocationManagerDelegate, UITableViewDataSource,UITableViewDelegate>

//---Need a location manager to manage user's current location --//

@property CLLocationManager *locationManager;
@property CLLocation *currentLocation;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property NSArray *pizzaPlacesArray;

@end

@implementation PizzaListViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.locationManager = [CLLocationManager new];

    //set the delegate for the current view controller.
    self.locationManager.delegate = self;

    //call helper method to update user's current location.
    [self UpdateUserCurrentLocation];

}

//--Helper method to update the current location--//
-(void)UpdateUserCurrentLocation{
    [self.locationManager requestAlwaysAuthorization];
    [self.locationManager startUpdatingLocation];

}
//--Helper method to find local pizzeria's//
-(void)findPizzerias:(CLLocation *)location{
    MKLocalSearchRequest *request = [MKLocalSearchRequest new];
    request.naturalLanguageQuery = @"pizza";
    request.region = MKCoordinateRegionMake(location.coordinate, MKCoordinateSpanMake(0.05, 0.05));

    //Do a local search
    MKLocalSearch *search = [[MKLocalSearch alloc]initWithRequest:request];
    [search startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error) {


        NSArray *mapItems = response.mapItems;
        NSMutableArray *tempArray = [NSMutableArray new];

        for (int i = 0; i< 4; i++){
            MKMapItem *mapItem = [mapItems objectAtIndex:i];
            CLLocationDistance metersAway = [mapItem.placemark.location distanceFromLocation:location];

            float distance = metersAway/1609.34;
            Pizzeria *pizzeria = [Pizzeria new];

            pizzeria.distanceToPizzeria = distance;
            pizzeria.mapItem = mapItem;

            [tempArray addObject:pizzeria];

            NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"distanceToPizzeria" ascending: true];
            NSArray *sortedArray = [tempArray sortedArrayUsingDescriptors:@[sortDescriptor]];

            self.pizzaPlacesArray = [NSArray arrayWithArray:sortedArray];
            [self.tableView reloadData];

            NSLog(@"%@", pizzeria.mapItem.name);

        }


    }];

}


#pragma Mark CLLocationManager-Delegate Methods

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{

    self.currentLocation = locations.firstObject;
    NSLog(@"%@",self.currentLocation);
    [self.locationManager stopUpdatingLocation];
    [self findPizzerias:self.currentLocation];

}

#pragma Mark TableView-Delegate Methods
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    return self.pizzaPlacesArray.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellID"];
    cell.textLabel.text = [[[self.pizzaPlacesArray objectAtIndex:indexPath.row]mapItem]name];
    float miles  = [[self.pizzaPlacesArray objectAtIndex:indexPath.row]distanceToPizzeria];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%f Miles",miles];
    
    
    return cell;
}



@end
