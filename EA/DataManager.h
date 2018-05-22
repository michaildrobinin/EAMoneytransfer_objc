//
//  DataManager.h
//  EA
//
//  Created by PSIHPOK on 2/2/18.
//  Copyright © 2018 PSIHPOK. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Backendless.h"

#define APPLICATION_ID @"895B469C-E8E8-47A6-FFC3-C0E19C985B00"
#define API_KEY @"BEC4A680-8A59-65C1-FF82-E190FCFD3600"
#define SERVER_URL @"https://api.backendless.com"

#define backendless [Backendless sharedInstance]

typedef enum {
    TS_PENDING = 0,
    TS_PROCESSING,
    TS_CALLED_PHONE,
    TS_NO_ANSWER,
    TS_PAID
} TRANS_STATUS;

@interface DataManager : NSObject {
    @public BOOL bEditSendMoneyInfo;
}

+(DataManager*) getInstance;
    
    @property(nonatomic) NSString* senderName;
    @property(nonatomic) NSString* senderAddress;
    @property(nonatomic) NSString* senderPhone;
    
    @property(nonatomic) NSString* receiverName;
    @property(nonatomic) NSString* receiverAddress;
    @property(nonatomic) NSString* receiverPhone;
    @property(nonatomic) NSString* receiverAltPhone;
    
    @property(nonatomic) NSString* amountInUSD;
    @property(nonatomic) NSString* amountLocal;
    @property(nonatomic) NSString* serviceCharge;
    @property(nonatomic) NSString* totalTransAmount;


@property(nonatomic) NSDictionary<NSString*,id> *sendMoneyInfo;


+ (NSString*) getDateStr:(NSDictionary*) dic key:(NSString*) key;
+ (double) getDouble:(NSDictionary*) dic key:(NSString*) key;
+ (NSString*) getNameStr:(NSString*) firstName lastName:(NSString*) lastName;
+ (NSString*) appendStr:(NSString*) first second:(NSString*) second;
+ (void) loadCORSTable:(void (^)(NSDictionary*)) completion;

+ (float) getCORS:(NSDictionary*) trans;
    
@end
