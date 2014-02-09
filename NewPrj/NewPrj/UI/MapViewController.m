//
//  MapViewController.m
//  PkProject
//
//  Created by dhkj001 on 14-1-6.
//  Copyright (c) 2014年 dhkj001. All rights reserved.
//

#import "MapViewController.h"
#import "Annotation.h"
#import "MBProgressHUD.h"
@interface MapViewController ()
{
    MKMapView *mapView;
    CLLocationManager *locationManager;
    CLLocation *currentLoc;
    MBProgressHUD *mbProgress;
    
}

@end

@implementation MapViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        // Custom initialization
    }
    return self;
}
#pragma mark CLLocationManagerDelegate

- (void) setupLocationManager {
    self.locationManager = [[CLLocationManager alloc] init];
    if ([CLLocationManager locationServicesEnabled]) {
        NSLog( @"Starting CLLocationManager" );
        self.locationManager.delegate = self;
        self.locationManager.distanceFilter = 5;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        mbProgress = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [self.view addSubview:mbProgress];
        [self.locationManager startUpdatingLocation];
    } else {
        NSLog( @"Cannot Starting CLLocationManager" );
        /*self.locationManager.delegate = self;
         self.locationManager.distanceFilter = 200;
         locationManager.desiredAccuracy = kCLLocationAccuracyBest;
         [self.locationManager startUpdatingLocation];*/
    }
}

- (void)locationManager:(CLLocationManager *)manager
	 didUpdateLocations:(NSArray *)locations
{
    CLLocation *currentLocation = [locations objectAtIndex:0];
    currentLoc =currentLocation;
    NSLog(@"longitude---%f,latitude---%f",currentLocation.coordinate.longitude,currentLocation.coordinate.latitude);
    self.locationStr = [NSString stringWithFormat:@"%f,%f",currentLocation.coordinate.longitude,currentLocation.coordinate.latitude];
    [self.delegate curretnLocationRecived:self.locationStr];
    [self showMap];
   
//    [mbProgress removeFromSuperview];
    //将经纬度转变成具体的位置
//    CLGeocoder *geocoder=[[CLGeocoder alloc]init];
//    [geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error){
//        CLPlacemark *placemark = [placemarks objectAtIndex:0];
//        location = placemark.name;
//    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupLocationManager];
    // Do any additional setup after loading the view from its nib.
}

-(void)showMap
{
    mapView = [[MKMapView alloc] initWithFrame:self.view.frame];
    mapView.mapType = MKMapTypeStandard;
    mapView.showsUserLocation = YES;
    CLLocationCoordinate2D coords = mapView.userLocation.location.coordinate;
    CLLocationCoordinate2D centerCoordinate = currentLoc.coordinate;
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(centerCoordinate,2000, 2000);
    MKCoordinateRegion adjustedRegion = [mapView regionThatFits:viewRegion];
    [mapView setRegion:adjustedRegion animated:YES];
    mapView.delegate = self;
    [self.view addSubview:mapView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
