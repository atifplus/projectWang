//
//  MapViewController.h
//  PkProject
//
//  Created by dhkj001 on 14-1-6.
//  Copyright (c) 2014年 dhkj001. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
@protocol MapViewControllerDelegate;
@interface MapViewController : UIViewController<MKMapViewDelegate,UITableViewDelegate>
@property(nonatomic,strong) CLLocationManager *locationManager;
@property(nonatomic,strong) CLLocation *currentLoc;
@property(nonatomic,strong) NSString *locationStr;
@property(nonatomic,weak) id<MapViewControllerDelegate> delegate;
@end
@protocol MapViewControllerDelegate <NSObject>
-(void)curretnLocationRecived:(NSString* )gpsString;

@end
