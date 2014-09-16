//
//  WMAFriendsTableViewController.m
//  Wake Me App
//
//  Created by Kirby Fike on 2/4/14.
//  Copyright (c) 2014 Kirby Fike. All rights reserved.
//

#import "WMAFriendsTableViewController.h"
#import "WMAFriendTableViewCell.h"
#import "AFHTTPRequestOperationManager.h"
#import "WMACredentialStore.h"
#import "WMAProfileViewController.h"
#import "WMAUserButton.h"

@interface WMAFriendsTableViewController () {
    UIActivityIndicatorView * activityindicator1;
}


@end

@implementation WMAFriendsTableViewController

@synthesize userID;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    activityindicator1 = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(150, 200, 30, 30)];
    [activityindicator1 setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [activityindicator1 setColor:[UIColor blueColor]];
    [self.view addSubview:activityindicator1];
    
    [activityindicator1 startAnimating];
    
    self.tabBarController.tabBar.hidden = NO;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.finishedActivityArray = [[NSArray alloc] init];
    [self checkUserID];
    [self makeRequest];
    
    [self resetTitle];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self checkUserID];
}

- (void) checkUserID
{
    NSString *userIDString = [NSString stringWithFormat:@"%@", self.userID];
    
    WMACredentialStore *wmaCredentialStore = [[WMACredentialStore alloc] init];
    
    if (!self.userID || [userIDString isEqualToString: [wmaCredentialStore wmaID]]) {
        WMACredentialStore *wmaCredentialStore = [[WMACredentialStore alloc] init];
        
        self.userID = [wmaCredentialStore wmaID];
        
        self.tabBarController.tabBar.hidden = NO;
        
    } else {
        self.tabBarController.tabBar.hidden = YES;
    }
}

- (void) resetTitle;
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.font = [UIFont boldSystemFontOfSize:14.0];
    label.textAlignment = NSTextAlignmentCenter;
    
    label.textColor = [UIColor blackColor]; // change this color
    label.text = NSLocalizedString(@"Friends", @"");
    [label sizeToFit];
    self.navigationItem.titleView = label;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.activityArrayFromAFNetworking count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *tempDictionary= [self.activityArrayFromAFNetworking objectAtIndex:indexPath.row];
    
    NSString *cellType = @"Friend";
    WMAFriendTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellType forIndexPath:indexPath];
    
    [cell loadSpecificView: tempDictionary];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

-(void)makeRequest
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSString* url = @"http://enigmatic-tundra-7064.herokuapp.com/api/v1/users/";
    
    url = [url stringByAppendingString:self.userID];
    url = [url stringByAppendingString:@"/friendships"];
    
    id params = @{
                  @"status": @"accepted"
                  };
    
    [manager GET:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        self.activityArrayFromAFNetworking = [responseObject objectForKey:@"friends"];
        NSLog(@"%@", self.activityArrayFromAFNetworking);
        
        [activityindicator1 stopAnimating];
        [self.tableView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}




/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

 #pragma mark - Navigation
 
 // In a story board-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
     if ([[segue identifier] isEqualToString:@"userProfile"]) {
         WMAUserButton *button = sender;
         
         WMAProfileViewController *profile = [segue destinationViewController];
         profile.userID = button.userID;
         profile.fullName = button.titleLabel.text;
     }
     
     // Get the new view controller using [segue destinationViewController].
     // Pass the selected object to the new view controller.
}
 

@end