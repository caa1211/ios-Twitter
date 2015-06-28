//
//  User.m
//  ios-Twitter
//
//  Created by Carter Chang on 6/29/15.
//  Copyright (c) 2015 Carter Chang. All rights reserved.
//

#import "User.h"

@implementation User

-(id)initWithDictionary: (NSDictionary *)dictionary {
    self = [self init];
    
    if(self){
        self.name = dictionary[@"name"];
        self.screenname = dictionary[@"screenname"];
        self.profileImageUrl = dictionary[@"profile_image_url"];
        self.tagline = dictionary[@"description"];
    }
    
    return self;
    
}

@end
