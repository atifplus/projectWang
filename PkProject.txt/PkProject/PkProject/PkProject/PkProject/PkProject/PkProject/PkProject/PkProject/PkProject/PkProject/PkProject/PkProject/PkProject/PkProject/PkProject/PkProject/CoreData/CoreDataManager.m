//
//  CoreDataManager.m
//  WeatherReport
//
//  Created by roiland on 13-9-4.
//  Copyright (c) 2013年 Genpact. All rights reserved.
//

#import "CoreDataManager.h"
#import "Survey.h"
#import "Answer.h"
#import "CMUUID.h"
#import "JSONKit.h"

#import "ASIHTTPRequest.h"

static CoreDataManager* coreDataRequest = nil;
@implementation CoreDataManager

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;


+(CoreDataManager *)getInstance
{
    //分配唯一网络控制实例对象
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        coreDataRequest = [[CoreDataManager alloc]init];
    });
	return coreDataRequest ;
}

- (id)init
{
    self = [super init];
    if (self) {
        [self managedObjectContext];
        //        currentSurvey = [[Survey alloc] init];
        
    }
    return self;
}
- (NSFetchRequest*)setEntity:(NSString*)entityName
                     sortStr:(NSString*)sortStr
                       field:(NSString*)field
                      filter:(NSString*)filter

                       isASC:(BOOL)isASC
{
    //创建取回数据请求
    NSFetchRequest *request = [[NSFetchRequest alloc] init] ;
    //托管对象
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:self.managedObjectContext];
    [request setEntity:entity];
    //指定对结果的排序方式
    if (sortStr!=nil) {
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sortStr ascending:isASC];
        NSArray *sortDescriptions = [[NSArray alloc]initWithObjects:sortDescriptor, nil];
        [request setSortDescriptors:sortDescriptions];
    }
    if (filter != nil&&field != nil) {
        NSPredicate *predicate;
        if ([field isEqualToString:@"surveyID"]) {
            predicate = [NSPredicate predicateWithFormat:@"surveyID = %@",filter];
        }
        if ([field isEqualToString:@"questionTitle"]) {
            predicate = [NSPredicate predicateWithFormat:@"questionTitle = %@",filter];
        }
        [request setPredicate:predicate];
    }
    return request;
}

#pragma mark - logic
//内部方法
- (int )getLastSurveyID
{
    int lastSurveyID = 0;
    NSFetchRequest *request = [self setEntity:@"Survey" sortStr:@"surveyID" field:nil filter:nil isASC:YES];
    NSError *error;
    NSMutableArray *fetchResults = [[self.managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    if ([fetchResults count]>0)   {
        NSManagedObject *lastObj =[fetchResults objectAtIndex:[fetchResults count]-1];
        NSString * str = [lastObj valueForKey:@"surveyID"];
       lastSurveyID = [[[str componentsSeparatedByString:@"-"] objectAtIndex:0] intValue];
    }else{
        NSLog(@"没找到调研信息");
    }
    NSLog(@"lastSurveyID--%d",lastSurveyID);
    return lastSurveyID;
}
- (void)setObj:(NSManagedObject*)obj WithDict:(NSDictionary *)dict
{
    NSArray *arr = [dict allKeys];
    [currentSurvey setValue:[NSDate date] forKey:@"updateTime"];
    for (NSString * key in arr) {
        //edited by wang 0912
        if ([dict objectForKey:key] != nil) {
            [obj setValue:[dict objectForKey:key] forKey:key];
        }else{
            NSLog(@"%@对应的值为空",key);
        }
        
    }
    if ([obj isKindOfClass:[Survey class]]) {
        NSLog(@"设置object的类别为Survey");
        int index = [self getLastSurveyID]+1;
        //edited by wang 0912
        if (index >= 0) {
            [obj setValue:[self createARandomStrngBy:index] forKey:@"surveyID"];
        }else{
            NSLog(@"NSNumber *surveyID错误");
        }
        
    }else{
        NSLog(@"设置object的类别为非Survey类");
    }
    
}
- (NSString *)createARandomStrngBy:(int)index
{
    CMUUID *uuid = [CMUUID randomUuid];
    NSString *returnString = [NSString stringWithFormat:@"%d-%@",index,uuid.stringValue];
    NSLog(@"returnString : %@",returnString);
    return returnString;
}
- (void)deleteAsurveyBySurveyID:(NSString*)surveyID
{

    
    NSFetchRequest *request = [self setEntity:@"Survey" sortStr:@"surveyID" field:@"surveyID" filter:surveyID isASC:NO];
    NSError *error;
    NSMutableArray *fetchResults = [[self.managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    int count = [fetchResults count];
    if (count>0)   {
        [self.managedObjectContext deleteObject:[fetchResults objectAtIndex:0]];
        [self deleteEndAction];
    }else{
        NSLog(@"没没找到调研信息");
    }

}

- (NSDictionary *)getDictfromObj:(NSManagedObject *)obj withKeys:(NSArray *)keys
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    for (NSString *key in keys) {
        if ([obj valueForKey:key] != nil) {
            [dict setObject:[obj valueForKey:key] forKey:key];
        }else{
            if ([key isEqualToString:@"answers"] == NO) {
                [dict setObject:@"" forKey:key];
            }
    
        }
        
        if([key isEqualToString:@"answers"])
        {
            NSSet *answerObjs = [obj valueForKey:@"answers"];
            NSArray *tempArr = [answerObjs allObjects];
            NSMutableArray *answerList = [[NSMutableArray alloc] init];
            NSArray *answerKeys = [NSArray arrayWithObjects:@"answer",@"questionTitle",@"comment",@"other", nil];
            
            for (NSManagedObject *obj in tempArr) {
                NSLog(@"questionTitle-%@",[obj valueForKey:@"questionTitle"]);
                NSMutableDictionary *answer = [[NSMutableDictionary alloc] init];
                for (NSString *key in answerKeys) {
                    if ([obj valueForKey:key] == nil) {
                        [answer setObject:@"" forKey:key];
                    }else{
                        [answer setObject:[obj valueForKey:key] forKey:key];
                    }
                }
                [answerList addObject:answer];
            }
            //排序
            NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
                                                initWithKey:@"questionTitle" ascending:YES];
            NSArray *sortDesS =[NSArray arrayWithObject:sortDescriptor];
            NSArray *answerListFinal = [answerList sortedArrayUsingDescriptors:sortDesS];
            
            [dict setObject:answerListFinal forKey:key];
        }
    }
    return dict;
}

//内部方法---end
- (void)createASurveyWithSurveyInfo:(NSDictionary *)surveyInfo;
{
    NSManagedObject* newObject = [NSEntityDescription insertNewObjectForEntityForName:@"Survey" inManagedObjectContext:self.managedObjectContext];
    currentSurvey = (Survey *)newObject;
    [self setObj:newObject WithDict:surveyInfo];
    [self updateEndAction];
    
}
- (void)updateCurrentSurveyWithSurveyInfo:(NSDictionary *)dict
{
    NSArray *keys = [dict allKeys];
    for (NSString *key in keys) {
        if ([[dict objectForKey:key] isKindOfClass:[NSString class]]) {
            NSString *filedValueStr = [dict objectForKey:key];
            if (currentSurvey != nil&& filedValueStr !=  nil) {
                [currentSurvey setValue:[dict objectForKey:key] forKey:key];
            }
        }else{
            NSLog(@"更新的字段，不是字符串");
        }
       
    }
    NSDate *now = [NSDate date];
    [currentSurvey setValue:now forKey:@"updateTime"];
    [self updateEndAction];
}
-(void)saveCurrentSurvey:(NSString *)surveyID
{
    [self updateEndAction];
}
- (void )setCurrentSurveywithSurveyID:(NSString*)surveyID
{
    NSFetchRequest *request = [self setEntity:@"Survey" sortStr:@"surveyID" field:@"surveyID" filter:surveyID isASC:YES];
    NSError *error;
    NSMutableArray *fetchResults = [[self.managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    int count = [fetchResults count];
    if (count>0)   {
        currentSurvey = (Survey*)[fetchResults objectAtIndex:0];
    }else{
        NSLog(@"没没找到调研信息");
    }
}

- (NSDictionary *)getAnswerInfoWithQestionTitle:(NSString*)questionTitle
{
    NSMutableDictionary *answerInfo  = [[NSMutableDictionary alloc] init];

    NSArray *keys = [NSArray arrayWithObjects:@"answer", @"questionTitle", @"comment", @"other", nil];
    if (currentSurvey != nil) {
        NSArray *answerList = [currentSurvey.answers allObjects];
        for (NSManagedObject *obj in answerList) {
            if ([questionTitle isEqualToString:[obj valueForKey:@"questionTitle"]]) {
//                NSLog(@"找到问题对应的答案了");
                for (NSString *key in keys) {
                    if ([obj valueForKey:key] != nil) {
                        [answerInfo setValue:[obj valueForKey:key] forKey:key];
                    }else{
                        [answerInfo setValue:@"" forKey:key];
                    }
                }
            }else{
//                NSLog(@"会有问题");
//                answerStr = @"";
            }
        }
    }else{
        NSLog(@"有问题，没找到答案，因为上级表单为空，上级表单为survey表");
    }
    return answerInfo;
}
- (int)getCurrentSurveyPercent
{
    NSArray *temArr = [currentSurvey.answers allObjects];
    int i = 0;
    for (NSManagedObject *obj in temArr) {
        if (([obj valueForKey:@"answer"] != nil&&[[obj valueForKey:@"answer"] length]>0)||([obj valueForKey:@"other"] != nil&&[[obj valueForKey:@"other"] length]>0)) {
            i++;
        }
    }
    NSLog(@"i");
    int percent = 100*i/43;
    return percent;
}
- (NSArray *)searchSurveyInfoWithSurveyID:(NSString*)surveyID
{
    
    NSFetchRequest *request = [self setEntity:@"Survey" sortStr:@"updateTime" field:@"surveyID" filter:surveyID isASC:NO];
    NSError *error;
    NSMutableArray *fetchResults = [[self.managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    int count = [fetchResults count];
    NSMutableArray *serveyList = [[NSMutableArray alloc] init];
    NSArray *keys = [NSArray arrayWithObjects:@"surveyID",@"employeeID",@"employeeName",@"surveyDealer",@"surveyComment",@"answers", @"flag",@"updateTime" , nil];
    if (count>0)   {
        for (NSManagedObject *obj in fetchResults) {
            [serveyList addObject:[self getDictfromObj:obj withKeys:keys]];
        }
    }else{
        NSLog(@"没没找到调研信息");
    }
    return [serveyList mutableCopy];
}
- (void)updateAnswerInfo:(NSDictionary *)answerInfo
{
    
    if (currentSurvey != nil) {
        NSArray *objects = [currentSurvey.answers allObjects];
//        NSArray *keys = [NSArray arrayWithObjects:@"answer",@"other",@"comment" ,nil];
        NSLog(@"上级表不为空，可以插入");
        if ([objects count]>0) {
            BOOL ISNEEDINSERT = YES;
            for (NSManagedObject *oneObject in objects) {
                NSString *dbQustionTitle = [oneObject valueForKey:@"questionTitle"];
                if ([dbQustionTitle isEqualToString: [answerInfo objectForKey:@"questionTitle"]]) {
                    //更新回来的值
                    [self setObj:oneObject WithDict:answerInfo];
                    //24日下午变更的
//                    for (NSString *key in keys) {
//                        [oneObject setValue:[answerInfo objectForKey:key] forKey:key];
//                    }
                    ISNEEDINSERT = NO;
                }
            
            }
            if (ISNEEDINSERT == YES) {
                NSManagedObject *newObj  = [NSEntityDescription insertNewObjectForEntityForName:@"Answer" inManagedObjectContext:self.managedObjectContext];
                [self setObj:newObj WithDict:answerInfo];
                [newObj setValue:currentSurvey forKey:@"survey"];
            }
        }else{
            
            NSLog(@"currentSurvey的answer中没有任何值");
            NSManagedObject *newObj  = [NSEntityDescription insertNewObjectForEntityForName:@"Answer" inManagedObjectContext:self.managedObjectContext];
            [self setObj:newObj WithDict:answerInfo];
            [newObj setValue:currentSurvey forKey:@"survey"];
            
        }
    }else{
        NSLog(@"上级表为空，不能插入");
        
    }
    [self updateEndAction];
}


#pragma mark -
- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

- (void)deleteEndAction
{
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    NSLog(@"delete success");

    
}
- (void)updateEndAction
{
    if ([self.managedObjectContext hasChanges]) {
        NSError *error = nil;
        if (![self.managedObjectContext save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
        NSLog(@"update success");
               
    }else{
        NSLog(@"update Error");
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Model" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Model.sqlite"];;
    
    
    NSError *error = nil;
    
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
