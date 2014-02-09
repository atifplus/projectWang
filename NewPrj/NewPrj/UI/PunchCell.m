//
//  RPActivitiesCell.m
//  RunUp
//
//  Created by roiland on 13-5-28.
//  Copyright (c) 2013年 RunUpStudio. All rights reserved.
//

#import "PunchCell.h"

@implementation PunchCell



- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.fieldName = [[UILabel alloc] initWithFrame:CGRectMake(5, 20, 75, 40)];
        self.fieldName.textAlignment = NSTextAlignmentRight;
        self.contentLbl = [[UILabel alloc] initWithFrame:CGRectMake(5, 80, 180, 40)];
        self.contentImageView = [[UIImageView alloc] initWithFrame:CGRectMake(27, 50, 60, 60)];
        self.btnGet = [[UIButton alloc] initWithFrame:CGRectMake(200, 10, 120, 40)];
        self.btnGet.backgroundColor = [UIColor redColor];
         [self.btnGet addTarget:self action:@selector(btnGetClicked:)  forControlEvents:UIControlEventTouchUpInside];
        self.btnUpload = [[UIButton alloc] initWithFrame:CGRectMake(200, 70, 120, 40)];
        self.btnUpload.backgroundColor = [UIColor redColor];
        [self.btnUpload addTarget:self action:@selector(btnUploadClicked:)  forControlEvents:UIControlEventTouchUpInside];
        
        [self.contentView addSubview:_fieldName];
        [self.contentView addSubview:_contentLbl];
        [self.contentView addSubview:_contentImageView];
        [self.contentView addSubview:_btnGet];
//        [self.contentView addSubview:_btnUpload];
    }
    return self;
}

- (void)initWithInfo:(NSDictionary*)dict
{
    NSString *nameLabelStr = [NSString stringWithFormat:@"%@:",[dict objectForKey:@"fieldName"]];
    NSString *nameBtnStr = [NSString stringWithFormat:@"get_%@",[dict objectForKey:@"fieldName"]];
    NSString *nameBtnUploadStr = [NSString stringWithFormat:@"upload_%@",[dict objectForKey:@"fieldName"]];
    self.fieldName.text = nameLabelStr;
    
    [self.btnGet setTitle:nameBtnStr forState:UIControlStateNormal];
    [self.btnGet setTitle:nameBtnStr forState:UIControlStateHighlighted];
    [self.btnGet setTitle:nameBtnStr forState:UIControlStateSelected];
    
    [self.btnUpload setTitle:nameBtnUploadStr forState:UIControlStateNormal];
    [self.btnUpload setTitle:nameBtnUploadStr forState:UIControlStateHighlighted];
    [self.btnUpload setTitle:nameBtnUploadStr forState:UIControlStateSelected];
   
    if (([dict objectForKey:@"contentLbl"] == nil)&&([dict objectForKey:@"contentImageView"] == nil))
    {
        self.btnGet.hidden = NO;
        self.contentImageView.hidden = YES;
        self.contentLbl.hidden = YES;
    }else{
        self.btnGet.hidden = YES;
        if (([dict objectForKey:@"contentLbl"] == nil)) {
            self.contentLbl.hidden = YES;
        }else{
            self.contentLbl.text = [dict objectForKey:@"contentLbl"];
            self.contentLbl.hidden = NO;
        }
        if (([dict objectForKey:@"contentImageView"] == nil)) {
            self.contentImageView.hidden = YES;
        }else{
            self.contentImageView.hidden = NO;
            self.contentImageView.image = [[UIImage alloc] initWithContentsOfFile:[dict objectForKey:@"contentImageView"]];
        }
    }
    //    self.recordTextView.backgroundColor = [UIColor clearColor];
    //    self.recordTextView.font = [UIFont systemFontOfSize:17.0];
    //    self.recordTextView.textColor = RGB_COLOR(232, 232, 232);
    //    self.recordTextView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    //    self.userInteractionEnabled = NO;
    //    self.recordID.textColor = RGB_COLOR(232, 232, 232);
    //    self.recordID.text = [dict objectForKey:@"id"];
    //    self.date.text = [dict objectForKey:@"date1"];
    //    self.date.textColor =RGB_COLOR(232, 232, 232);
    //    self.recordTextView.text = [dict objectForKey:@"jilu"];
}
-(IBAction)btnUploadClicked:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    [self.delegate uploadBeClickedWithBtnTag:btn.tag];
}
-(IBAction)btnGetClicked:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    [self.delegate getBeClickedWithBtnTag:btn.tag];
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
