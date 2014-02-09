//
//  MainViewController.h
//  PkProject
//
//  Created by dhkj001 on 14-1-2.
//  Copyright (c) 2014年 dhkj001. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "MapViewController.h"
#import "PunchCell.h"

@interface MainViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,CLLocationManagerDelegate,UIActionSheetDelegate,UIPickerViewDelegate,UINavigationControllerDelegate,MapViewControllerDelegate,PanchDelegate>

@property(nonatomic,strong) IBOutlet UITableView *tableView;
@property(nonatomic,strong)  UIImagePickerController *imagePickerController;
//@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@end
