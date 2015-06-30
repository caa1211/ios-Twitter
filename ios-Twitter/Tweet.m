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
        self.idStr = dictionary[@"id_str"];
        self.retweeted = dictionary[@"retweeted"];
        self.favorited = dictionary[@"favorited"];
        @try {
            self.mediaUrl = dictionary[@"entities"][@"media"][0][@"media_url"];
        }
        @catch (NSException *exception) {
        }
        NSString *createAtString = dictionary[@"created_at"];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"EEE MMM d HH:mm:ss Z y";
        self.createdAt = [formatter dateFromString:createAtString];
        self.timestamp = [self compareCurrentTime:self.createdAt];
        
        // NSLog(@"%@", self.mediaUrl);
    }
    return self;
    
}

-(void) setFavorite:(NSInteger)value {
    self.favorited = [@(value) stringValue];
}

-(void) setRetweet:(NSInteger)value {
     self.retweeted = [@(value) stringValue];
}

+(NSArray *) tweetsWithArray: (NSArray *) array {
    NSMutableArray *tweets = [NSMutableArray array];
    for(NSDictionary *dictionary in array) {
        [tweets addObject:[[Tweet alloc] initWithDictionary:dictionary]];
    }
    return tweets;
}

- (NSString *) compareCurrentTime:(NSDate*) compareDate
//
{
    NSTimeInterval  timeInterval = [compareDate timeIntervalSinceNow];
    timeInterval = -timeInterval;
    long temp = 0;
    NSString *result;
    if (timeInterval < 60) {
        result = [NSString stringWithFormat:@"%f sec", timeInterval];
    }
    else if((temp = timeInterval/60) <60){
        result = [NSString stringWithFormat:@"%ld min",temp];
    }
    
    else if((temp = temp/60) <24){
        result = [NSString stringWithFormat:@"%ld h",temp];
    }
    
    else if((temp = temp/24) <30){
        result = [NSString stringWithFormat:@"%ld day",temp];
    }
    
    else if((temp = temp/30) <12){
        result = [NSString stringWithFormat:@"%ld mon",temp];
    }
    else{
        temp = temp/12;
        result = [NSString stringWithFormat:@"%ld y",temp];
    }
    
    return  result;
}

@end
