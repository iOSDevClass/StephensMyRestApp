//
//  ApiManager.h
//  ApiTest
//
//  Created by ios on 10/23/15.
//  Copyright © 2015 Brandon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

@interface ApiManager : NSObject

@property (readonly, nonatomic) BOOL isAuthenticated;

+ (instancetype)getInstance;

- (void)authenticateUser:(NSString *)username withPassword:(NSString *)password completion:(void (^)(NSString *))completion failure:(void (^)(void))failure;

- (void)fetchAllUserDataWithCompletion:(void (^)(NSArray<User *> *))completion failure:(void (^)(void))failure;

- (void)registerNewUsername:(NSString *)username withPassword:(NSString *)password completion:(void(^)(NSString *))completion failure:(void(^)(void))failure;

- (void)saveDevice:(Device *)device forUser:(User *)user completion:(void(^)(void))completion failure:(void(^)(void))failure;

- (void)logout;

@end
