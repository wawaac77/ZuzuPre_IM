//
//  NotificationItem.m
//  GFBS
//
//  Created by Alice Jin on 4/7/2017.
//  Copyright © 2017 apple. All rights reserved.
//

#import "NotificationItem.h"
#import "ZBLocalized.h"
#import <MJExtension.h>

@implementation NotificationItem

/*全局变量 */
static NSDateFormatter *fmt_;
static NSDateFormatter *outputFmt_;
static NSCalendar *calendar_;
static NSTimeZone *inputTimeZone_;
static NSTimeZone *outputTimeZone_;

+ (NSDictionary *)mj_replacedKeyFromPropertyName {
    
    return @{
             @"notificationText" : @"title",
             @"updatedAt" : @"updatedAt",
             @"notificationType" : @"type",
             @"memberId" : @"member",
             @"isRead" : @"isRead",
            };
}

/**
 只调用一次
 */
+(void)initialize
{
    fmt_ = [[NSDateFormatter alloc] init];
    outputFmt_ = [[NSDateFormatter alloc] init];
    calendar_ = [NSCalendar gf_calendar];
    inputTimeZone_ = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
    outputTimeZone_ = [NSTimeZone localTimeZone];
    
    [fmt_ setTimeZone:inputTimeZone_];
    [outputFmt_ setTimeZone:outputTimeZone_];
}


- (NSString *)updatedAt {
    fmt_.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'";
    
    NSString *userLang = [[NSUserDefaults standardUserDefaults] objectForKey:@"KEY_USER_LANG"];
    if ([userLang isEqualToString:@"en"]) {
        outputFmt_.dateFormat = @"dd MMM HH:mm";
    } else {
        outputFmt_.dateFormat = @"M月d日 HH:mm";
    }
    
    
    NSDate *creatAtDate = [fmt_ dateFromString:_updatedAt];
    
    if (creatAtDate.isThisYear) {//今年
        if ([calendar_ isDateInToday:creatAtDate]) {//今天
            //当前时间
            NSDate *nowDate = [NSDate date];
            
            NSCalendarUnit unit = NSCalendarUnitYear | NSCalendarUnitMonth |NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
            NSDateComponents *comps = [calendar_ components:unit fromDate:creatAtDate toDate:nowDate options:0];
            
            if (comps.hour >= 1) {
                return [NSString stringWithFormat:@"%zd %@",comps.hour, ZBLocalized(HourAgoStr, nil)];
            }else if (comps.minute >= 1){
                return [NSString stringWithFormat:@"%zd %@",comps.minute, ZBLocalized(MinAgoStr, nil)];
            }else
            {
                return ZBLocalized(JustNowStr, nil);
            }
            
        }else if ([calendar_ isDateInYesterday:creatAtDate]){//昨天
            if ([userLang isEqualToString:@"en"]) {
                outputFmt_.dateFormat = @"'Yesterday' HH:mm";
            } else {
                outputFmt_.dateFormat = @"昨天 HH:mm";
            }
            return [outputFmt_ stringFromDate:creatAtDate];
            
        }else{//其他
            //outputFmt_.dateFormat = @"dd MMM HH:mm";
            return [outputFmt_ stringFromDate:creatAtDate];
            
        }
        
    }else{//非今年
        //outputFmt_.dateFormat = @"dd MMM yyyy";
        if ([userLang isEqualToString:@"en"]) {
            outputFmt_.dateFormat = @"dd MMM yyyy";
        } else {
            outputFmt_.dateFormat = @"yyyy年M月d日";
        }
        return [outputFmt_ stringFromDate:creatAtDate];
    }
    
    //fmt_.doesRelativeDateFormatting = YES;
    return _updatedAt;
}

@end
