//
//  MainViewController.h
//  PkProject
//
//  Created by dhkj001 on 14-1-2.
//  Copyright (c) 2014年 dhkj001. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface MainViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,CLLocationManagerDelegate,UIActionSheetDelegate,UIPickerViewDelegate,UINavigationControllerDelegate>
@property(nonatomic,strong) CLLocationManager *locationManager;
@property(nonatomic,strong) CLLocation *checkinLocation;
@property(nonatomic,strong) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@end
