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
@property NSMutableArray *distanceToPizzeriasArray;
@property  double timeToTravel;
@property double finalTimeTraveled;
@property NSMutableArray* timeToGetToNextPizzaArray;
@property NSString *tempStr;
@property (weak, nonatomic) IBOutlet UILabel *totalTimeLabel;

@end

@implementation PizzaListViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.locationManager = [CLLocationManager new];

    //set the delegate for the current view controller.
    self.locationManager.delegate = self;

    //call helper method to update user's current location.
    [self UpdateUserCurrentLocation];

    self.timeToTravel = 0.0;
    self.finalTimeTraveled = 0.0;


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
    self.pizzaPlacesArray = [NSArray new];
    //Do a local search
    MKLocalSearch *search = [[MKLocalSearch alloc]initWithRequest:request];
    [search startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error) {


        NSArray *mapItems = response.mapItems;
        NSMutableArray *tempArray = [NSMutableArray new];

        for (int i = 0; i< 4; i++){
            MKMapItem *mapItem = [mapItems objectAtIndex:i];
            CLLocationDistance metersAway = [mapItem.placemark.location distanceFromLocation:location];

            //Calculate distance to each pizzeria.Then add to distance array.
            float distance = metersAway/1609.34;
            NSString *tempString = [NSString stringWithFormat:@"%f", distance];

            [self.distanceToPizzeriasArray addObject:tempString];



            Pizzeria *pizzeria = [Pizzeria new];

            pizzeria.distanceToPizzeria = distance;
            pizzeria.mapItem = mapItem;
            pizzeria.location = location;

            [tempArray addObject:pizzeria];

            NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"distanceToPizzeria" ascending: true];
            NSArray *sortedArray = [tempArray sortedArrayUsingDescriptors:@[sortDescriptor]];

            self.pizzaPlacesArray = [NSArray arrayWithArray:sortedArray];
             [self calculateTotalDistanceTraveled:self.pizzaPlacesArray];

            [self.tableView reloadData];

          // NSLog(@"%@", self.pizzaPlacesArray);

        }



    }];


   // NSLog(@"%f",self.totalDistance);


}
-(void)calculateTotalDistanceTraveled:(NSArray *)pizzaPlaces{
    MKMapItem *source = [MKMapItem mapItemForCurrentLocation];
    //self.totalDistance = 0.0;
    double timeWaitAtRestaurant = 50;
self.timeToGetToNextPizzaArray = [NSMutableArray new];
    for (Pizzeria *pizzeria in pizzaPlaces) {
        MKDirectionsRequest *request = [MKDirectionsRequest new];
        request.source = source;
        request.destination = pizzeria.mapItem;
        request.transportType = MKDirectionsTransportTypeWalking;
        MKDirections *directions = [[MKDirections alloc] initWithRequest:request];
        [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error)
         {
             MKRoute *route = response.routes.firstObject;
             self.timeToTravel += route.expectedTravelTime/60 + timeWaitAtRestaurant;
             self.finalTimeTraveled = self.timeToTravel;
             NSString *tempTimeStr = [NSString new];
             tempTimeStr = [NSString stringWithFormat:@"Total Time = %f Minutes to get to all the locations.",self.finalTimeTraveled];

             self.totalTimeLabel.text = tempTimeStr;
             [self.timeToGetToNextPizzaArray addObject:tempTimeStr];
             NSLog(@"%.2f minutes", self.timeToTravel);
             self.tempStr = [NSString stringWithFormat:@"%f", self.finalTimeTraveled];
             //self.totalDistance = [NSString stringWithFormat:@"%.2f minutes", self.numberTotalTime];

         }];
        source = pizzeria.mapItem;
    }




}

#pragma Mark CLLocationManager-Delegate Methods

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{

    self.currentLocation = locations.firstObject;
   // NSLog(@"%@",self.currentLocation);
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



    
   // NSLog(@"%@", self.distanceToPizzeriasArray);
    return cell;
}

-(NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section{
    //[tableView reloadData];

  //  [tableView footerViewForSection:section].textLabel.text = @"HHHH";

    return self.tempStr;
}



@end
