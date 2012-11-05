//
//  Project.h
//  iSwhrs
//
//  Created by Tommy Wendelborg on 9/20/12.
//  Copyright (c) 2012 Steria. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Project : NSObject

@property (nonatomic, readonly, copy) NSString *projectNumber;
@property (nonatomic, readonly, copy) NSString *activityCode;
@property (nonatomic, readonly, copy) NSString *description;

-(id)initWithprojectNumber:(NSString *) projectNumber andActivityCode:(NSString *) activityCode andDescription:(NSString *) description;

@end