//
//  MainViewController.m
//  PkProject
//
//  Created by dhkj001 on 14-1-2.
//  Copyright (c) 2014年 dhkj001. All rights reserved.
//

#import "MainViewController.h"
#import "JSONKit.h"
#import "CoreDataManager.h"
#import "NSData+Base64.h"
#import "MBProgressHUD.h"
#import "ASIFormDataRequest.h"
#import "DIOSNode.h"
#import "DIOSFile.h"

@interface MainViewController ()
{
    BOOL isFullScreen;
    NSArray *dataSource;
    CoreDataManager *coreDataManager;
    NSString *location;
    NSMutableDictionary *loctionInfo;
    NSMutableDictionary *photoInfo;
    MBProgressHUD *mbProgress;
    NSString *fid;
    NSString *uri;
    
}

@end

@implementation MainViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [self.tableView reloadData];
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self restartAction];
    
    coreDataManager = [CoreDataManager getInstance];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;

    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 50, 44)];
    view.backgroundColor = [UIColor clearColor];
    UIButton *rightButton =  [UIButton buttonWithType:UIButtonTypeCustom];
    
    [rightButton addTarget:self action:@selector(restartAction) forControlEvents:UIControlEventTouchUpInside];
    [rightButton setFrame:CGRectMake(0,0,50,44)];
    
    UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"btn_new.png"]];
    imgView.frame = CGRectMake(7,10,19,17);
    [view addSubview:imgView];
    [view addSubview:rightButton];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:view];
    self.navigationItem.rightBarButtonItem = rightItem;
    // Do any additional setup after loading the view from its nib.
}
- (void)restartAction
{
    self.imagePickerController = nil;
    loctionInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Location",@"fieldName", nil];
    photoInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Photo",@"fieldName", nil];
    dataSource = [NSArray arrayWithObjects:loctionInfo,photoInfo, nil];
    [self.tableView reloadData];
}
- (void)btnCameraClicked
{
    UIActionSheet *sheet;
    
    // 判断是否支持相机
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        sheet  = [[UIActionSheet alloc] initWithTitle:@"选择" delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"取消" otherButtonTitles:@"拍照",@"从相册选择", nil];
    }
    else {
        
        sheet = [[UIActionSheet alloc] initWithTitle:@"选择" delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"取消" otherButtonTitles:@"从相册选择", nil];
    }
    
    sheet.tag = 255;
    
    [sheet showInView:self.view];

}
//- (IBAction)grabURLInBackground:(id)sender
//{
//
//    NSArray *arr = [[loctionInfo objectForKey:@"contentLbl"] componentsSeparatedByString:@","];
//    NSString *longitudeStr = [arr objectAtIndex:0];
//    NSString *latitudeStr = [arr objectAtIndex:1];
//    NSArray *arrLongitude = [self getFormatterDictWithString:longitudeStr];
//    NSArray *arrLatitude = [self getFormatterDictWithString:latitudeStr];
//    
//    NSString *pathStr= @"http://www.banokabazaar.com/iphoneapi/node";
//    NSURL *url = [NSURL URLWithString:@""];
//    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
//    httpClient.parameterEncoding = AFJSONParameterEncoding;
////    [httpClient setDefaultHeader:@"Accept" value:@"text/json"];
//
//    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"helloKity",@"title",@"location",@"type", arrLatitude,@"field_latitude",arrLongitude,@"field_longitude",nil];
//    NSMutableURLRequest *request = [httpClient requestWithMethod:@"POST" path:pathStr parameters:dict];
//    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
//    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
//     {
//         NSLog(@"成功！！！！ = %@  ",operation.responseString);
//     }                               failure:^(AFHTTPRequestOperation *operation, NSError *error){
//         NSLog(@"失败！！");
//     }];
//    [operation start];
//
//}
- (IBAction)uploadPhoto:(id)sender
{
    // 获取沙盒目录
    NSString *fullPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"tempImg.png"];
    UIImage *image = [[UIImage alloc] initWithContentsOfFile:fullPath];
    NSData *imageData = UIImageJPEGRepresentation(image, 0.5);
    NSString *base64Str = [imageData base64EncodedString];
    
//    NSString *urlString = @"www.banokabazaar.com/iphoneapi/file";
//    NSURL *url = [NSURL URLWithString:urlString];
    
    NSString *fileName = @"testPostImage";
    NSString *filePath = [NSString stringWithFormat:@"public://%@.png",fileName];
    
    NSMutableDictionary *nodeData = [NSMutableDictionary new];
    [nodeData setValue:fileName forKey:@"filename"];
    [nodeData setValue:filePath forKey:@"filepath"];
    [nodeData setValue:base64Str forKey:@"file"];
    mbProgress = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    //如果设置此属性则当前的view置于后台
//    mbProgress.labelText = @"Uploading";
    [self.view addSubview:mbProgress];
    
    
//    [DIOSNode nodeSave:nodeData success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        //Do Something with the responseObject
//        NSLog(@"%@", responseObject);
//        NSDictionary *responseDict=  (NSDictionary*)responseObject;
//        fid = [responseDict objectForKey:@"fid"];
////        uri = [responseDict objectForKey:@"uri"];
//        
//        [mbProgress removeFromSuperview];
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        //we failed, uh-oh lets error log this.
//        NSLog(@"%@,  %@", [error localizedDescription], [operation responseString]);
//        [mbProgress removeFromSuperview];
//    }];
    
    
    [DIOSFile fileSave:nodeData success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //Do Something with the responseObject
        NSLog(@"%@", responseObject);
        NSDictionary *responseDict=  (NSDictionary*)responseObject;
        fid = [responseDict objectForKey:@"fid"];
        //        uri = [responseDict objectForKey:@"uri"];
        
        [mbProgress removeFromSuperview];
    }  failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //we failed, uh-oh lets error log this.
        NSLog(@"%@,  %@", [error localizedDescription], [operation responseString]);
        [mbProgress removeFromSuperview];
    }];
    
}
- (IBAction)uploadLocation:(id)sender
{
    NSArray *arr = [[loctionInfo objectForKey:@"contentLbl"] componentsSeparatedByString:@","];
    NSString *longitudeStr = [arr objectAtIndex:0];
    NSString *latitudeStr = [arr objectAtIndex:1];
    id longitude = [self getFormatterDictWithString:longitudeStr];
    id latitude = [self getFormatterDictWithString:latitudeStr];
    id fidObj = [self getFidFormatterDictWithString];
    if (fidObj == nil) {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Notice" message:@"Make sure you have uploaded the photo" delegate:nil cancelButtonTitle:@"Yes" otherButtonTitles:nil, nil];
        
        [alert show];
        return;
    }
    NSMutableDictionary *nodeData = [NSMutableDictionary new];
    [nodeData setValue:@"appSentPhoto" forKey:@"title"];
    [nodeData setValue:@"location" forKey:@"type"];
    [nodeData setValue:latitude forKey:@"field_latitude"];
    [nodeData setValue:longitude forKey:@"field_longitude"];
    [nodeData setValue:fidObj forKey:@"field_camera_image1"];
    
    mbProgress = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self.view addSubview:mbProgress];
    [DIOSNode nodeSave:nodeData success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //Do Something with the responseObject
        NSLog(@"%@", responseObject);
        [mbProgress removeFromSuperview];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //we failed, uh-oh lets error log this.
        NSLog(@"%@,  %@", [error localizedDescription], [operation responseString]);
        [mbProgress removeFromSuperview];
    }];
}

//- (IBAction)grabURLInBackground:(id)sender
//{
//    NSURL *url = [NSURL URLWithString:@"http://www.banokabazaar.com/iphoneapi/node"];
//    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
//    //    title
//    //    type = basic page
//    [request setPostValue:@"1510" forKey:@"title"];
//    [request setPostValue:@"location" forKey:@"type"];
//    
//    
//    
//    NSArray *arr = [[loctionInfo objectForKey:@"contentLbl"] componentsSeparatedByString:@","];
//    NSString *longitudeStr = [arr objectAtIndex:0];
//    NSString *latitudeStr = [arr objectAtIndex:1];
//    
//    NSArray *arrLongitude = [self getFormatterDictWithString:longitudeStr];
//    NSArray *arrLatitude = [self getFormatterDictWithString:latitudeStr];
//
//
//  
////    [request set]
//    [request setPostValue:arrLatitude forKey:@"field_latitude"];
//    [request setPostValue:arrLongitude forKey:@"field_longitude"];
//    [request setDelegate:self];
//    [request startAsynchronous];
//}
-(NSDictionary *)getFormatterDictWithString:(NSString*)string
{
    NSDictionary *dict = [NSDictionary dictionaryWithObject:string forKey:@"value"];
    NSArray *unds = [NSArray arrayWithObjects:dict, nil];
    NSDictionary *dictUnd = [NSDictionary dictionaryWithObject:unds forKey:@"und"];
    return dictUnd;
}
-(NSDictionary *)getFidFormatterDictWithString
{
    if (fid == nil) {
        return nil;
    }else{
    NSDictionary *dict = [NSDictionary dictionaryWithObject:fid forKey:@"fid"];
    NSArray *unds = [NSArray arrayWithObjects:dict, nil];
    NSDictionary *dictUnd = [NSDictionary dictionaryWithObject:unds forKey:@"und"];
        return dictUnd;
    }
}

- (void) requestFinished:(ASIHTTPRequest *)request
{
    // Use when fetching text data
    NSString *responseString = [request responseString];
    NSLog(@"responseString--%@",responseString);
    // Use when fetching binary data
//    NSData *responseData = [request responseData];
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    NSLog(@"error--%@",error);
}
#pragma mark
-(void)uploadBeClickedWithBtnTag:(int)tag
{
    if ([[[dataSource objectAtIndex:tag] objectForKey:@"fieldName"] isEqualToString:@"Location"]) {
        [self uploadLocation:nil];
    }
    if ([[[dataSource objectAtIndex:tag] objectForKey:@"fieldName"] isEqualToString:@"Photo"]) {
        [self uploadPhoto:nil];
    }
}
-(void)getBeClickedWithBtnTag:(int)tag
{
    if ([[[dataSource objectAtIndex:tag] objectForKey:@"fieldName"] isEqualToString:@"Location"]) {
        MapViewController *mapViewCon = [[MapViewController alloc] init];
        mapViewCon.delegate = self;
        [self.navigationController pushViewController:mapViewCon animated:YES];
    }
    if ([[[dataSource objectAtIndex:tag] objectForKey:@"fieldName"] isEqualToString:@"Photo"]) {
        if (TARGET_IPHONE_SIMULATOR) {
            
            UIImage *image = [UIImage imageNamed:@"aaa.png"];
            NSData *imageData = UIImageJPEGRepresentation(image, 0.5);
            // 获取沙盒目录
            NSString *fullPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"tempImg.png"];
            // 将图片写入文件
            [imageData writeToFile:fullPath atomically:YES];
        }else{
            self.imagePickerController = [[UIImagePickerController alloc] init];
            self.imagePickerController.delegate = self;
            self.imagePickerController.allowsEditing = YES;
            
            self.imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
            [self presentViewController:self.imagePickerController animated:YES completion:^{}];
        }
        
    }
}
#pragma mark 
-(void)curretnLocationRecived:(NSString* )gpsString
{
    [loctionInfo setObject:gpsString forKey:@"contentLbl"];
}

#pragma mark UITabelViewDelegate And DataSource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 120;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return dataSource.count;

}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
   
}
// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"PunchCell";
    PunchCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
       cell = [[PunchCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.delegate = self;
    cell.btnGet.tag = indexPath.row;
    cell.btnUpload.tag = indexPath.row;
    [cell initWithInfo:[dataSource objectAtIndex:indexPath.row]];
    return cell;
}


#pragma mark - image picker delegte
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	[picker dismissViewControllerAnimated:YES completion:^{}];
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    NSData *imageData = UIImageJPEGRepresentation(image, 0.5);
    // 获取沙盒目录
    NSString *fullPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"tempImg.png"];
    // 将图片写入文件
    [imageData writeToFile:fullPath atomically:YES];
    [photoInfo setObject:fullPath forKey:@"contentImageView"];
    [self.tableView reloadData];
//    [self.tableView setNeedsDisplay];
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
	[self dismissViewControllerAnimated:YES completion:^{}];
}
#pragma mark - actionsheet delegate
-(void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 255) {
        
        NSUInteger sourceType = 0;
        
        // 判断是否支持相机
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            
            switch (buttonIndex) {
                case 0:
                    // 取消
                    return;
                case 1:
                    // 相机
                    sourceType = UIImagePickerControllerSourceTypeCamera;
                    break;
                case 2:
                    // 相册
                    sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                    break;
            }
        }
        else {
            if (buttonIndex == 0) {
                
                return;
            } else {
                sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
            }
        }
        // 跳转到相机或相册页面
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.delegate = self;
        
        imagePickerController.allowsEditing = YES;
        
        imagePickerController.sourceType = sourceType;
        
        [self presentViewController:imagePickerController animated:YES completion:^{}];

    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
