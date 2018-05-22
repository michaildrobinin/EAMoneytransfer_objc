//
//  DataManager.m
//  EA
//
//  Created by PSIHPOK on 2/2/18.
//  Copyright © 2018 PSIHPOK. All rights reserved.
//

#import "DataManager.h"
#import "XMLDictionary.h"

static DataManager* g_Instance = NULL;
static NSDictionary* corsDic = NULL;
static NSString* corsDicStr = NULL;

@implementation DataManager

    +(DataManager*) getInstance {
        if (g_Instance == NULL) {
            g_Instance = [[DataManager alloc] init];
            g_Instance->bEditSendMoneyInfo = false;
            [backendless setHostUrl:SERVER_URL];
            [backendless initApp:APPLICATION_ID APIKey:API_KEY];
        }
        return g_Instance;
    }
    
+ (NSString*) getDateStr:(NSDictionary*) dic key:(NSString*) key {
    NSString* dateStr = @"";
    
    NSDate* date = (NSDate*) [dic objectForKey:key];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setFormatterBehavior:NSDateFormatterBehavior10_4];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    dateStr = [formatter stringFromDate:date];
    
    return dateStr;
}

+ (double) getDouble:(NSDictionary*) dic key:(NSString*) key {
    NSNumber* num = [dic objectForKey:key];
    return [num doubleValue];
}

+ (NSString*) getNameStr:(NSString*) firstName lastName:(NSString*) lastName {
    NSString* nameStr = [firstName stringByAppendingString:@" "];
    nameStr = [nameStr stringByAppendingString:lastName];
    return nameStr;
}

+ (NSString*) appendStr:(NSString*) first second:(NSString*) second {
    return [first stringByAppendingString:second];
}

+ (void) loadCORSTable:(void (^)(NSDictionary*)) completion  {
    if (corsDic != NULL) {
        completion(corsDic);
    }
    NSString* urlStr = @"https://www.treasury.gov/ofac/downloads/consolidated/consolidated.xml";
    NSURL* url = [NSURL URLWithString:urlStr];
    NSURLSession* session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSURLSessionDataTask* task = [session dataTaskWithURL:url completionHandler:^(NSData* data, NSURLResponse* response, NSError* error) {
        if (data != NULL) {
            corsDic = [NSDictionary dictionaryWithXMLData:data];
            corsDicStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"%@", corsDicStr);
        }
        completion(corsDic);
    }];
    [task resume];
}

+ (float) getCORS:(NSDictionary*) trans {
    if (corsDicStr == NULL) return 0;
    
    NSString* sendFName = [trans objectForKey:@"senderFirstName"];
    NSString* sendLName = [trans objectForKey:@"senderLastName"];
    NSString* recFName = [trans objectForKey:@"recFirstName"];
    NSString* recLName = [trans objectForKey:@"recLastName"];
    NSString* country = [trans objectForKey:@"recCountry"];
    NSDate* birthday = (NSDate*)[trans objectForKey:@"senderBirthday"];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd MMM YYYY"];
    NSString* birthStr = [formatter stringFromDate:birthday];

    float score = 0;
    
    if ([corsDicStr rangeOfString:sendFName].location != NSNotFound) {
        score += 25;
    }
    if ([corsDicStr rangeOfString:sendLName].location != NSNotFound) {
        score += 25;
    }
    if ([corsDicStr rangeOfString:recFName].location != NSNotFound) {
        score += 25;
    }
    if ([corsDicStr rangeOfString:recLName].location != NSNotFound) {
        score += 25;
    }
    if (country != nil && [corsDicStr rangeOfString:country].location != NSNotFound) {
        score += 25;
    }
    if (birthStr != nil && [corsDicStr rangeOfString:birthStr].location != NSNotFound) {
        score += 25;
    }
    
    if (score > 100) score = 100;
    
    return score;
}



@end
