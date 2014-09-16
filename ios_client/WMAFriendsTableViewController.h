//
//  WMAFriendsTableViewController.h
//  Wake Me App
//
//  Created by Kirby Fike on 2/4/14.
//  Copyright (c) 2014 Kirby Fike. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WMAFriendsTableViewController : UITableViewController
@property (strong, nonatomic) NSArray *activityArrayFromAFNetworking;
@property (strong, nonatomic) NSArray *finishedActivityArray;
@property (strong, nonatomic) NSString *userID;
@end
