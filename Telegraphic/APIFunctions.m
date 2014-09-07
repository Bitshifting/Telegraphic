//
//  APIFunctions.m
//  Telegraphic
//
//  Created by Kenneth Siu on 9/6/14.
//  Copyright (c) 2014 Base Twelve. All rights reserved.
//

#import "APIFunctions.h"

@implementation APIFunctions

#pragma mark Post Functions

//see who is controlling the fountain and how is in queue
+(NSMutableURLRequest*) getUserList:(NSString*)url withAccessToken:(NSString*)apiToken {
    return [self queryWithBody:[NSString stringWithFormat:@"%@/user/list", url] withDictionary:@{@"accessToken": apiToken}];
}

+(NSMutableURLRequest*) registerUser:(NSString*)url withUsername:(NSString*)username withPassHash:(NSString*)passHash withPhoneNumb:(NSString*)phoneNumb {
    return [self queryWithBody:[NSString stringWithFormat:@"%@/user/register", url] withDictionary:@{@"username": username, @"passwordHash" : passHash, @"phoneNumber":phoneNumb}];
}

+(NSMutableURLRequest*) loginUser:(NSString*)url withUsername:(NSString*)username withPassHash:(NSString*)passHash {
    return [self queryWithBody:[NSString stringWithFormat:@"%@/user/login", url] withDictionary:@{@"username": username, @"passwordHash" : passHash}];
}

+(NSMutableURLRequest*) createImage:(NSString*)url withAccessToken:(NSString*)apiToken withEditTime:(NSNumber*)editTime withHopsLeft:(NSNumber*)hopsLeft withNextUser:(NSString*)nextUser withImage:(NSString*)image {
    return [self queryWithBody:[NSString stringWithFormat:@"%@/image/create", url] withDictionary:@{@"accessToken": apiToken, @"editTime" : editTime, @"hopsLeft" : hopsLeft, @"nextUser" : nextUser, @"image" : image}];
}

+(NSMutableURLRequest*) updateImage:(NSString*)url withUUID:(NSString*)uuid withAccessToken:(NSString*)apiToken withNextUser:(NSString*)nextUser withImage:(NSString*)image {
    
    return [self queryWithBody:[NSString stringWithFormat:@"%@/image/update", url] withDictionary:@{@"accessToken": apiToken,  @"nextUser" : nextUser, @"image" : image, @"uuid" : uuid}];
}

+(NSMutableURLRequest*) queryImage:(NSString*)url withAccessToken:(NSString*)apiToken {
    
    return [self queryWithBody:[NSString stringWithFormat:@"%@/image/query", url] withDictionary:@{@"accessToken": apiToken}];
}

+(NSMutableURLRequest*) seenImage:(NSString*)url withAccessToken:(NSString*)apiToken withUUID:(NSString*)uuid {
    return [self queryWithBody:[NSString stringWithFormat:@"%@/image/seen", url] withDictionary:@{@"accessToken": apiToken, @"uuid" : uuid}];
}

+(NSMutableURLRequest*) getFriends:(NSString*)url withAccessToken:(NSString*)apiToken {
    return [self queryWithBody:[NSString stringWithFormat:@"%@/friends", url] withDictionary:@{@"accessToken" : apiToken}];
}

+(NSMutableURLRequest*) addFriend:(NSString*)url withUsername:(NSString*)username withAccessToken:(NSString*)apiToken {
    return [self queryWithBody:[NSString stringWithFormat:@"%@/friends/add", url] withDictionary:@{@"accessToken" : apiToken, @"friend" : username}];
}

+(NSMutableURLRequest*) removeFriend:(NSString*)url withUsername:(NSString*)username withAccessToken:(NSString*)apiToken {
    return [self queryWithBody:[NSString stringWithFormat:@"%@/friends/delete", url] withDictionary:@{@"accessToken" : apiToken, @"friend" : username}];
}


#pragma mark Helper Functions

//query for get requests, insert url
+(NSURLRequest*) queryNoBody:(NSString*)urlString {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSURL *urlSend = [NSURL URLWithString:urlString];
    
    return [[NSURLRequest alloc] initWithURL:urlSend];
}

//qery with body (POST requests)
+(NSMutableURLRequest*) queryWithBody:(NSString*)urlString withDictionary:(NSDictionary*)dict {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSURL *urlSend = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[urlSend standardizedURL]];
    [req setHTTPMethod:@"POST"];
    
    //set up string from dictionary
    NSArray *arrayKeys = [dict allKeys];
    NSString *dataString = @"{";
    for(int i = 0; i < [arrayKeys count]; i++) {
        id key = [arrayKeys objectAtIndex:i];
        id value = [dict objectForKey:key];
        NSString *newData =  [NSString stringWithFormat:@" \"%@\":\"%@\"", key, value];
        dataString = [dataString stringByAppendingString: newData];
        
        //if last object in array, append bracket, else append comma
        if(i == [arrayKeys count] - 1) {
            dataString = [dataString stringByAppendingString:@"}"];
        } else {
            dataString = [dataString stringByAppendingString:@","];
        }
    }
    
    //set reqest type
    [req setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    //set post data
    [req setHTTPBody:[dataString dataUsingEncoding:NSUTF8StringEncoding]];
    
    return req;
}

@end
