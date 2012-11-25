//
//  WeekViewController.h
//  Hours
//
//  Created by Tommy Wendelborg on 11/4/12.
//  Copyright (c) 2012 steria. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppState.h"

@interface WeekViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property(nonatomic, strong) AppState *state;
@end
