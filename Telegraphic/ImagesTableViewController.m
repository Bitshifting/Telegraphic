//
//  ImagesTableViewController.m
//  Telegraphic
//
//  Created by Kenneth Siu on 9/6/14.
//  Copyright (c) 2014 Base Twelve. All rights reserved.
//

#import "ImagesTableViewController.h"
#import "APIFunctions.h"
#import "SecretKeys.h"
#import "TabViewController.h"

@interface ImagesTableViewController ()

@end

@implementation ImagesTableViewController

@synthesize queue, arrOfPrevUsers, accessToken, arrOfUUID, arrOfHops, arrOfBase64, navCont, imageTimer;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(id) initWithAccessToken:(NSString*)apiToken withNavigationController:(UINavigationController*)nNavCont {
    self = [super init];
    
    if(self) {
        accessToken = apiToken;
        navCont = nNavCont;
        
        [navCont setNavigationBarHidden:NO animated:YES];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addImage:)];
        
    }
    
    return self;
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    imageTimer = [NSTimer scheduledTimerWithTimeInterval:3.0f target:self selector:@selector(checkImages:) userInfo:self repeats:YES];
    
    [imageTimer fire];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Images";
    
    self.edgesForExtendedLayout = UIRectEdgeAll;
    self.tableView.contentInset = UIEdgeInsetsMake(20.0f + self.tabBarController.navigationController.navigationBar.frame.size.height, 0.0f, CGRectGetHeight(self.tabBarController.tabBar.frame), 0.0f);

    
    queue = [[NSOperationQueue  alloc] init];
    
    imageTimer = [NSTimer scheduledTimerWithTimeInterval:3.0f target:self selector:@selector(checkImages:) userInfo:self repeats:YES];
    
    [imageTimer fire];
    
    // Uncomment the following line to preserve selection between presentations.
    //self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(IBAction)checkImages:(NSTimer*)timer {
    NSURLRequest *req = [APIFunctions queryImage:[SecretKeys getURL] withAccessToken:accessToken];
    
    [NSURLConnection sendAsynchronousRequest:req queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        //if there is an error, return
        if(error) {
            return;
        }
        
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        
        if(dict && [[dict objectForKey:@"success"] boolValue]) {
            
            NSArray *arrImg = [dict objectForKey:@"items"];
            
            NSMutableArray *images = [[NSMutableArray alloc] init];
            
            NSMutableArray *uuid = [[NSMutableArray alloc] init];
            
            NSMutableArray *hops = [[NSMutableArray alloc] init];
            
            NSMutableArray *base64 = [[NSMutableArray alloc] init];
            
            for(NSDictionary *dictImages in arrImg) {
                [images addObject:[dictImages objectForKey:@"previousUser"]];
                [uuid addObject:[dictImages objectForKey:@"imageUUID"]];
                [hops addObject:[dictImages objectForKey:@"hopsLeft"]];
                [base64 addObject:[dictImages objectForKey:@"image"]];
            }
            
            arrOfPrevUsers = images;
            arrOfUUID = uuid;
            arrOfHops = hops;
            arrOfBase64 = base64;
            
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

//TODO: ADD IMAGE BY PUSHING THE TAB
-(IBAction)addImage:(id)sender {
    [imageTimer invalidate];
    
    [navCont pushViewController:[[TabViewController alloc] initWithImage:nil withAccessToken:accessToken isEditable:YES isCreate:YES withUUID:nil] animated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    BOOL isLast = NO;
    
    if(cell.backgroundColor == [UIColor greenColor]) {
        isLast = YES;
    }
    
    //convert string to image
    NSString *image = [arrOfBase64 objectAtIndex:indexPath.row];
    
    NSData *data = [[NSData alloc]initWithBase64EncodedString:image options:NSDataBase64DecodingIgnoreUnknownCharacters];
    
    [imageTimer invalidate];
    
    [navCont pushViewController:[[TabViewController alloc] initWithImage:[UIImage imageWithData:data] withAccessToken:accessToken isEditable:!isLast isCreate:NO withUUID:[arrOfUUID objectAtIndex:indexPath.row]] animated:YES];
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
    return [arrOfPrevUsers count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = @"imageCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if([[arrOfHops objectAtIndex:indexPath.row] intValue] != 0) {
        [cell setBackgroundColor:[UIColor orangeColor]];
    } else {
        [cell setBackgroundColor:[UIColor greenColor]];
    }
    
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    // set text
    cell.textLabel.text = [arrOfPrevUsers objectAtIndex:indexPath.row];
    
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
