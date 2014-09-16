//
//  WMASetSongViewController.h
//  Wake Me App
//
//  Created by Kirby Fike on 5/30/14.
//  Copyright (c) 2014 Kirby Fike. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Song.h"

@protocol SetSongDelegate;

@interface WMASetSongViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) NSArray *itunesData;
@property (strong,nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong,nonatomic) IBOutlet UITableView *theTableView;
@property (strong,nonatomic) IBOutlet UILabel *noResultsFound;
@property (strong,nonatomic) IBOutlet UITableViewCell *customCell;
@property (strong,nonatomic) Song *currentSongSelected;
-(IBAction)selectSong: (id)sender;
@property (nonatomic, weak) id<SetSongDelegate> delegate;

@property (nonatomic, weak) IBOutlet UIButton *selectSongButton;


@end

@protocol SetSongDelegate <NSObject>
- (void)didSetSongSuccessfully:(Song *)songSelected;
@end