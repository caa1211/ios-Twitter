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
        
         NSLog(@"%@", self.mediaUrl);
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

//- (NSString*)timestamp
//{
//    // Calculate distance time string
//    //
//    time_t now;
//    time(&now);
//    NSString *timestamp;
//    int distance = (int)difftime(now, _createdAt);
//    if (distance < 0) distance = 0;
//    
//    if (distance < 60) {
//        timestamp = [NSString stringWithFormat:@"%d %s", distance, (distance == 1) ? "second ago" : "seconds ago"];
//    }
//    else if (distance < 60 * 60) {
//        distance = distance / 60;
//        timestamp = [NSString stringWithFormat:@"%d %s", distance, (distance == 1) ? "minute ago" : "minutes ago"];
//    }
//    else if (distance < 60 * 60 * 24) {
//        distance = distance / 60 / 60;
//        timestamp = [NSString stringWithFormat:@"%d %s", distance, (distance == 1) ? "hour ago" : "hours ago"];
//    }
//    else if (distance < 60 * 60 * 24 * 7) {
//        distance = distance / 60 / 60 / 24;
//        timestamp = [NSString stringWithFormat:@"%d %s", distance, (distance == 1) ? "day ago" : "days ago"];
//    }
//    else if (distance < 60 * 60 * 24 * 7 * 4) {
//        distance = distance / 60 / 60 / 24 / 7;
//        timestamp = [NSString stringWithFormat:@"%d %s", distance, (distance == 1) ? "week ago" : "weeks ago"];
//    }
//    else {
//        static NSDateFormatter *dateFormatter = nil;
//        if (dateFormatter == nil) {
//            dateFormatter = [[NSDateFormatter alloc] init];
//            [dateFormatter setDateStyle:NSDateFormatterShortStyle];
//            [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
//        }
//        
//        NSDate *date = [NSDate dateWithTimeIntervalSince1970:createdAt];
//        timestamp = [dateFormatter stringFromDate:date];
//    }
//    return timestamp;
//}
@end
