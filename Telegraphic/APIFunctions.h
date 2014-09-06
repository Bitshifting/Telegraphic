//
//  APIFunctions.h
//  Telegraphic
//
//  Created by Kenneth Siu on 9/6/14.
//  Copyright (c) 2014 Base Twelve. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface APIFunctions : NSObject

+(NSMutableURLRequest*) getUserList:(NSString*)url withAccessToken:(NSString*)apiToken;
+(NSMutableURLRequest*) registerUser:(NSString*)url withUsername:(NSString*)username withPassHash:(NSString*)passHash withPhoneNumb:(NSString*)phoneNumb;
+(NSMutableURLRequest*) loginUser:(NSString*)url withUsername:(NSString*)username withPassHash:(NSString*)passHash;
+(NSMutableURLRequest*) createImage:(NSString*)url withAccessToken:(NSString*)apiToken withEditTime:(NSNumber*)editTime withHopsLeft:(NSNumber*)hopsLeft withNextUser:(NSString*)nextUser withImage:(NSString*)image;
+(NSMutableURLRequest*) updateImage:(NSString*)url withUUID:(NSString*)uuid withAccessToken:(NSString*)apiToken withNextUser:(NSString*)nextUser withImage:(NSString*)image;
+(NSMutableURLRequest*) queryImage:(NSString*)url withAccessToken:(NSString*)apiToken;
@end
