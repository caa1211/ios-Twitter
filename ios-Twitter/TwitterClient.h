//
//  TwitterClient.h
//  ios-Twitter
//
//  Created by Carter Chang on 6/29/15.
//  Copyright (c) 2015 Carter Chang. All rights reserved.
//

#import "BDBOAuth1RequestOperationManager.h"
#import "User.h"

@interface TwitterClient : BDBOAuth1RequestOperationManager
+ (TwitterClient *) sharedInstance;
-(void) loginWithCompletion: (void(^)(User *user, NSError *error))completion;
-(void)openUrl:(NSURL *)url;
@end
