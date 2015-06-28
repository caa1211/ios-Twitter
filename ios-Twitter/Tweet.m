//
//  Tweet.m
//  ios-Twitter
//
//  Created by Carter Chang on 6/29/15.
//  Copyright (c) 2015 Carter Chang. All rights reserved.
//

#import "Tweet.h"

@implementation Tweet

-(id)initWithDictionary: (NSDictionary *)dictionary {

    self = [super init];
    
    if (self) {
        self.user = [[User alloc] initWithDictionary: dictionary[@"user"]];
        self.text = dictionary[@"text"];
        NSString *createAtString = dictionary[@"created_at"];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"EEE MMM d HH:mm:ss Z y";
        self.createdAt = [formatter dateFromString:createAtString];
    }
    return self;
    
}

+(NSArray *) tweetsWithArray: (NSArray *) array {
    NSMutableArray *tweets = [NSMutableArray array];
    for(NSDictionary *dictionary in array) {
        [tweets addObject:[[Tweet alloc] initWithDictionary:dictionary]];
    }
    return tweets;
}

@end
