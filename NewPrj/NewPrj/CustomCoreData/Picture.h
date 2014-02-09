//
//  Picture.h
//  PkProject
//
//  Created by dhkj001 on 14-1-2.
//  Copyright (c) 2014年 dhkj001. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Picture : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * location;
@property (nonatomic, retain) NSData * image;

@end
