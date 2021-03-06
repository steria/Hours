//
//  DataFactory.h
//  Hours
//
//  Created by Tommy Wendelborg on 11/4/12.
//  Copyright (c) 2012 steria. All rights reserved.
//

#import <Foundation/Foundation.h>
#import"AppState.h"
#import "Week.h"
#import "LoginState.h"

@interface DataFactory : NSObject
@property(nonatomic, readonly, weak) id<AppStateReceiver> appStateReceiver;
@property(nonatomic, readonly, weak) id<LoginStateReceiver> loginStateReceiver;
@property(nonatomic, readonly, weak) id<AppStateSaver> appStateSaver;
-(void)startCheckAuthenticationForLoginState:(LoginState *)loginState andDelegateReceiver:(id<LoginStateReceiver>) receiver;
-(void)startGetDataForDate:(NSDate *)date andDelegateReceiver:(id<AppStateReceiver>) receiver;
-(void)startSavingRegistration:(Registration *)registration forDate:(NSDate *) date forDelegate:(id<AppStateSaver>) saver;
-(void)submitWeek:(Week *) week forDelegate:(id<AppStateSubmitter>) delegate;
+ (AppState *)sharedAppState;
+ (LoginState *) sharedLoginState;
+ (void)clearState;
@end
