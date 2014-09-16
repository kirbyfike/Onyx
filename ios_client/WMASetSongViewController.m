//
//  WMASetSongViewController.m
//  Wake Me App
//
//  Created by Kirby Fike on 5/30/14.
//  Copyright (c) 2014 Kirby Fike. All rights reserved.
//

#import "WMASetSongViewController.h"
#import "AFHTTPRequestOperationManager.h"
#import "WMASelectSongTableViewCell.h"
#import "Song.h"
#import "WMACredentialStore.h"

@interface WMASetSongViewController () {
    AFHTTPRequestOperationManager *manager;
    NSTimer *searchDelayer;
    UIActivityIndicatorView * activityindicator1;
}

@end

@implementation WMASetSongViewController

@synthesize itunesData, searchBar, theTableView, selectSongButton, noResultsFound;



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [selectSongButton setEnabled:NO];
    
    noResultsFound.hidden = YES;
    
    manager = [AFHTTPRequestOperationManager manager];
    
    _currentSongSelected = [[Song alloc] init];
    // Do any additional setup after loading the view.
    
    activityindicator1 = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(150, 200, 30, 30)];
    [activityindicator1 setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [activityindicator1 setColor:[UIColor blueColor]];
    [self.view addSubview:activityindicator1];
    
    [activityindicator1 stopAnimating];
    

    NSArray *array = [[NSArray alloc] initWithObjects: nil];
    
    // Copying the array you just created to your data array for use in your table.
    self.itunesData = array;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Table View Data Source Methods

// This will tell your UITableView how many rows you wish to have in each section.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.itunesData count];
}

// This will tell your UITableView what data to put in which cells in your table.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifer = @"CustomTableCell";
    //WMASelectSongTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifer];
    
    //static NSString *CellIdentifier = @"CustomTableCell";
    WMASelectSongTableViewCell *cell = (WMASelectSongTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifer];
    
    
    // Using a cell identifier will allow your app to reuse cells as they come and go from the screen.
    if (cell == nil) {
        cell = [[WMASelectSongTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifer];
    }
    
    // Deciding which data to put into this particular cell.
    // If it the first row, the data input will be "Data1" from the array.
    
    if ([itunesData count] != 0) {
        NSUInteger row = [indexPath row];
        Song *song = [itunesData objectAtIndex:row];
        cell.info = song;
        
        cell.trackCensoredName.text = song.trackCensoredName;
        cell.artist.text = song.artist;
        //ecell.thumbnailImageView.image = [UIImage imageNamed:song.thumbnailImageView];
        cell.thumbnailImageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:song.thumbnailImageView]]];
        
        cell.songUrl = song.songUrl;
        cell.itunesID = song.itunesID;
    }
    
    return cell;
}

-(void) searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    NSArray *array = [[NSArray alloc] initWithObjects: nil];
    
    self.itunesData = array;
    
    [self.theTableView reloadData];
    
    noResultsFound.hidden = YES;
    [activityindicator1 startAnimating];
    
    [searchDelayer invalidate], searchDelayer=nil;
    searchDelayer = [NSTimer scheduledTimerWithTimeInterval:1.5
                                                     target:self
                                                   selector:@selector(doSearch:)
                                                   userInfo:searchText
                                                        repeats:NO];
}

- (void) doSearch:(NSTimer *)t {
    NSString* url = @"https://itunes.apple.com/search";
    
    self.itunesData = [NSArray arrayWithObjects: nil];
    
    id params = @{
                  @"term": searchDelayer.userInfo,
                  @"entity": @"musicTrack"
                  };
    
    
    [manager.operationQueue cancelAllOperations];
    
    
    [manager GET:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *array = [responseObject objectForKey:@"results"];
        
        NSMutableArray *mystr = [[NSMutableArray alloc] init];
        
        for (id object in array) {
            Song *song = [[Song alloc] init];
            song.artist = [object objectForKey:@"artistName"];
            song.thumbnailImageView = [object objectForKey:@"artworkUrl60"];
            song.trackCensoredName = [object objectForKey:@"trackCensoredName"];
            song.songUrl = [object objectForKey:@"previewUrl"];
            song.itunesID = [object objectForKey:@"trackId"];
            song.purchaseUrl = [object objectForKey:@"trackViewUrl"];
            
            
            [mystr addObject:song];
        }
        
        if (mystr == nil || [mystr count] == 0) {
            noResultsFound.hidden = NO;
        }
        
        self.itunesData = mystr;
        
        [activityindicator1 stopAnimating];
        
        [self.theTableView reloadData];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

- (void) tableView: (UITableView *) tableView didSelectRowAtIndexPath:(NSIndexPath *) indexPath {
    
    WMASelectSongTableViewCell *cell = (WMASelectSongTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    
    _currentSongSelected.itunesID = cell.info.itunesID;
    _currentSongSelected.songUrl = cell.info.songUrl;
    _currentSongSelected.artist = cell.info.artist;
    _currentSongSelected.thumbnailImageView = cell.info.thumbnailImageView;
    _currentSongSelected.trackCensoredName = cell.info.trackCensoredName;
    _currentSongSelected.purchaseUrl = cell.info.purchaseUrl;
    
    [selectSongButton setEnabled:YES];
    
    [self.searchBar resignFirstResponder];
}

-(IBAction)selectSong: (id)sender {
    
    [self.delegate didSetSongSuccessfully:_currentSongSelected];
    
    [self.navigationController popViewControllerAnimated:YES];
}




/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
