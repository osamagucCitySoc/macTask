//
//  MainViewTableViewController.m
//  task
//
//  Created by OsamaMac on 10/16/14.
//  Copyright (c) 2014 VF. All rights reserved.
//

#import "MainViewTableViewController.h"
#import "UIView+RNActivityView.h"

@interface MainViewTableViewController ()<NSURLConnectionDataDelegate,NSURLConnectionDelegate>

@end

@implementation MainViewTableViewController
{
    NSMutableData* accumlatedData;
    NSMutableArray* productsWithCats;
    NSMutableArray* cats;
    NSURLConnection* getCatsProductsConnection;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setTitle:@"Categories & Products"];
    
    [self loadCategoriesAndProducts];
}


-(void)loadCategoriesAndProducts
{
    dispatch_async(dispatch_get_main_queue(), ^{
    [self.navigationController.view showActivityViewWithLabel:@"Working.." detailLabel:@"Please Wait.."];
    });
    
    accumlatedData = [[NSMutableData alloc]init];
    
    NSString *post = @"";
    
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:NO];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[post length]];
    
    NSURL *url = [NSURL URLWithString:@"http://osamalogician.com/arabDevs/DefneAdefak/V2/sendMacData.php"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:90.0];
    [request setHTTPMethod:@"POST"];
    
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    
    [request setHTTPBody:postData];
    
    getCatsProductsConnection = [[NSURLConnection alloc]initWithRequest:request delegate:self    startImmediately:NO];
    
    [getCatsProductsConnection scheduleInRunLoop:[NSRunLoop mainRunLoop]
                                 forMode:NSDefaultRunLoopMode];
    [getCatsProductsConnection start];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return cats.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* cellID = @"catCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    if(!cell)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    
    // Configure the cell...
    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
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
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


#pragma mark connection delegate
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if(connection == getCatsProductsConnection)
    {
        [accumlatedData appendData:data];
    }
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSError* error;
    if(connection == getCatsProductsConnection)
    {
        NSDictionary* loadedCats = [NSJSONSerialization JSONObjectWithData:accumlatedData
                                                              options:NSJSONReadingAllowFragments
                                                                error:&error];
        cats = [loadedCats objectForKey:@"cats"];
        productsWithCats = [loadedCats objectForKey:@"products"];
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.navigationController.view hideActivityViewWithAfterDelay:0];
            [self.tableView reloadData];
            [self.tableView setNeedsDisplay];
        });
    }
}

@end
