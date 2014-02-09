//
//  RPActivitiesCell.h
//  RunUp
//
//  Created by roiland on 13-5-28.
//  Copyright (c) 2013年 RunUpStudio. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PanchDelegate;
@interface PunchCell : UITableViewCell
{
    UIImageView *contextBackImg;
}

@property(nonatomic,strong)  UILabel* fieldName;
@property(nonatomic,strong)  UILabel* contentLbl;
@property(nonatomic,strong)  UIImageView* contentImageView;
@property(nonatomic,strong)  UIButton* btnGet;
@property(nonatomic,strong)  UIButton* btnUpload;
@property(nonatomic,weak) id<PanchDelegate> delegate;
- (void)initWithInfo:(NSDictionary*)dict;
@end
@protocol PanchDelegate <NSObject>
-(void)getBeClickedWithBtnTag:(int)tag;
-(void)uploadBeClickedWithBtnTag:(int)tag;

-(void)textViewBeginEdite:(NSDictionary *)textViewInfo;
-(void)textViewDidEndEdite:(NSDictionary *)textViewInfo;
@end
