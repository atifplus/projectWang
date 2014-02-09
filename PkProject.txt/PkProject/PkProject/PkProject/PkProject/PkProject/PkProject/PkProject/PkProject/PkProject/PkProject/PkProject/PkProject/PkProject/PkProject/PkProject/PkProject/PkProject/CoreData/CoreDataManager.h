//
//  CoreDataManager.h
//  WeatherReport
//
//  Created by roiland on 13-9-4.
//  Copyright (c) 2013年 Genpact. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
@class Survey;
@interface CoreDataManager :  NSObject<NSFetchedResultsControllerDelegate>
{
    Survey *currentSurvey;
}
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
+ (CoreDataManager *)getInstance;


//增加掉查问卷
- (void)createASurveyWithSurveyInfo:(NSDictionary *)surveyInfo;
//删除调查问卷
- (void)deleteAsurveyBySurveyID:(NSString*)surveyID;
//改变调查问卷的信息
- (void)updateCurrentSurveyWithSurveyInfo:(NSDictionary *)dict;
//查找调查问卷
- (NSArray *)searchSurveyInfoWithSurveyID:(NSString*)surveyID;
//设置当前的调查问卷
- (void )setCurrentSurveywithSurveyID:(NSString*)surveyID;
//获取当前调查问卷完成的百分比例
- (int)getCurrentSurveyPercent;
//通过题目获取到题目答案
- (NSDictionary *)getAnswerInfoWithQestionTitle:(NSString*)questionTitle;
//更新问题答案信息
- (void)updateAnswerInfo:(NSDictionary *)answerInfo;

@end
