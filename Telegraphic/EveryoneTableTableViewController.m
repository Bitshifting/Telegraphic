//
//  EveryoneTableTableViewController.m
//  Telegraphic
//
//  Created by Kenneth Siu on 9/6/14.
//  Copyright (c) 2014 Base Twelve. All rights reserved.
//

#import "EveryoneTableTableViewController.h"
#import "APIFunctions.h"
#import "SecretKeys.h"

@interface EveryoneTableTableViewController ()

@end

@implementation EveryoneTableTableViewController

@synthesize queue, arrOfEveryone, delegate, accessToken, everyoneTimer, temporaryName;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(id)initWithAccessToken:(NSString*)apiToken {
    self = [super init];
    
    if(self) {
        accessToken = apiToken;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeAll;
    self.tableView.contentInset = UIEdgeInsetsMake(20.0f + self.navigationController.navigationBar.frame.size.height, 0.0f, CGRectGetHeight(self.tabBarController.tabBar.frame), 0.0f);
    
    
    queue = [[NSOperationQueue alloc] init];
    
    everyoneTimer = [NSTimer scheduledTimerWithTimeInterval:10.0f target:self selector:@selector(checkEveryone:) userInfo:nil repeats:YES];
    
    [everyoneTimer fire];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    everyoneTimer = [NSTimer scheduledTimerWithTimeInterval:10.0f target:self selector:@selector(checkEveryone:) userInfo:self repeats:YES];
    
    [everyoneTimer fire];
    
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = 1.0; //seconds
    lpgr.delegate = self;
    [self.tableView addGestureRecognizer:lpgr];
}

-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    CGPoint p = [gestureRecognizer locationInView:self.tableView];
    
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:p];
    if (indexPath != nil) {
        
        if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
            NSLog(@"long press on table view at row %d", indexPath.row);
            
            temporaryName = [self.tableView cellForRowAtIndexPath:indexPath].textLabel.text;
            
            //now show uialert allowing one to add as friend
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Add as Friend" message:[NSString stringWithFormat:@"Add %@ to friend's list?", temporaryName] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
            
            [alert show];
        }
    }
}

-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(buttonIndex == 0) {
        NSLog(@"Cancelled");
    } else {
        NSMutableURLRequest *req = [APIFunctions addFriend:[SecretKeys getURL] withUsername:temporaryName withAccessToken:accessToken];
        
        [NSURLConnection sendAsynchronousRequest:req queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
            
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            
            //if there is an error, return
            if(error) {
                return;
            }
            
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            
            if(dict && [[dict objectForKey:@"success"] boolValue]) {
                NSLog(@"Friend Added");
            }
            
        }];
        
        
    }
}

-(IBAction)checkEveryone:(NSTimer*)timer {
    NSURLRequest *req = [APIFunctions getUserList:[SecretKeys getURL] withAccessToken:accessToken];
    
    [NSURLConnection sendAsynchronousRequest:req queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        //if there is an error, return
        if(error) {
            return;
        }
        
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        
        if(dict && [[dict objectForKey:@"success"] boolValue]) {
            
            NSArray *arrOfUsers = [dict objectForKey:@"items"];
            
            NSMutableArray *users = [[NSMutableArray alloc] init];
            
            for(NSDictionary *dictUsers in arrOfUsers) {
                [users addObject:[dictUsers objectForKey:@"username"]];
            }
            
            arrOfEveryone = users;
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [self.tableView reloadData];
            }];
            
        }
        
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    [everyoneTimer invalidate];
    [delegate sendImageEveryone:cell.textLabel.text];
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
    return [arrOfEveryone count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = @"everyoneCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    // Configure the cell...
    cell.textLabel.text = [arrOfEveryone objectAtIndex:indexPath.row];
    
    return cell;
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
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
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
