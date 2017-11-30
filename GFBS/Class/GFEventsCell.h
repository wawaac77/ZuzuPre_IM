//
//  GFEventsCell.h
//  GFBS
//
//  Created by Alice Jin on 17/5/2017.
//  Copyright © 2017 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZZContentModel.h"
@class ZZContentModel;

@interface GFEventsCell : UITableViewCell

/*数据*/
@property (strong, nonatomic) ZZContentModel *event;
@property (strong, nonatomic) NSString *type;

@end
