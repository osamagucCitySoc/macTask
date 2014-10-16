//
//  MainViewTableViewController.m
//  task
//
//  Created by OsamaMac on 10/16/14.
//  Copyright (c) 2014 VF. All rights reserved.
//

#import "MainViewTableViewController.h"
#import "UIView+RNActivityView.h"
#import "UIImageView+WebCache.h"
#import "UserDataTapGestureRecognizer.h"

@interface MainViewTableViewController ()<NSURLConnectionDataDelegate,NSURLConnectionDelegate>

@end

@implementation MainViewTableViewController
{
    __weak IBOutlet UIView *addView;
    NSMutableData* accumlatedData;
    NSMutableArray* productsWithCats;
    NSMutableArray* cats;
    NSURLConnection* getCatsProductsConnection;
    NSIndexPath* expandedIndex;
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
    
    NSDictionary* currentCat = [cats objectAtIndex:indexPath.row];
    
    [(UILabel*)[cell viewWithTag:2] setText:[currentCat objectForKey:@"catName"]];
    
    
    
    [(UIImageView*)[cell viewWithTag:1] setImageWithURL:[NSURL URLWithString:[currentCat objectForKey:@"catImage"]]];
    
    
    [[cell viewWithTag:4]removeFromSuperview];
    
    UIScrollView* scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(8, 40, 320, 45)];
    scrollView.tag = 4;
    scrollView.delegate = self;
    [scrollView setUserInteractionEnabled:YES];
    [scrollView setBackgroundColor:[UIColor clearColor]];
    [scrollView setCanCancelContentTouches:NO];
    
    scrollView.indicatorStyle = UIScrollViewIndicatorStyleBlack;
    scrollView.clipsToBounds = NO;
    scrollView.scrollEnabled = YES;
    scrollView.pagingEnabled = YES;
    
    
    NSMutableArray* links = [[NSMutableArray alloc]init];
    
    for(NSDictionary* dict in productsWithCats)
    {
        if([[dict objectForKey:@"catName"]isEqualToString:[currentCat objectForKey:@"catName"]])
        {
            [links addObject:dict];
            [links addObject:dict];
            [links addObject:dict];
            [links addObject:dict];
            [links addObject:dict];
            [links addObject:dict];
            [links addObject:dict];
            [links addObject:dict];
            [links addObject:dict];
        }
    }
    
    CGFloat cx = 0;
    
    
    for(int i = 0 ; i < links.count ; i++)
    {
        NSDictionary* dict = [links objectAtIndex:i];
        UserDataTapGestureRecognizer *tapGestureRecognizer = [[UserDataTapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapFrom:)];
        [tapGestureRecognizer setHolder:dict];
        
        NSURL* imageToDownload = [NSURL URLWithString:[dict objectForKey:@"prodImage"]];
        
        UIImageView *imageView = [[UIImageView alloc] init];
        [imageView setImageWithURL:imageToDownload];
        [imageView setUserInteractionEnabled:YES];
        [imageView addGestureRecognizer:tapGestureRecognizer];
        
        CGRect rect = imageView.frame;
        rect.size.height = 40;
        rect.size.width = 40;
        rect.origin.x = cx;
        rect.origin.y = 0;
        
        imageView.frame = rect;
        imageView.tag = 1000;
        [scrollView addSubview:imageView];
        
        cx += imageView.frame.size.width+5;
    }
    
    if(expandedIndex && expandedIndex == indexPath)
    {
        [(UIImageView*)[cell viewWithTag:3] setImage:[UIImage imageNamed:@"up.png"]];
        [scrollView setContentSize:CGSizeMake(cx, 45)];
        [cell addSubview:scrollView];
    }else
    {
        [(UIImageView*)[cell viewWithTag:3] setImage:[UIImage imageNamed:@"down.png"]];
        [scrollView setContentSize:CGSizeMake(cx, 0)];
    }
    
    
    return cell;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(expandedIndex && expandedIndex == indexPath)
    {
        return 100;
    }else
    {
        return 44;
    }
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(expandedIndex && expandedIndex == indexPath)
    {
        expandedIndex = nil;
    }else
    {
        expandedIndex = indexPath;
    }
    [self.tableView beginUpdates];
    [self.tableView reloadData];
//    [self.tableView setNeedsDisplay];
    [self.tableView endUpdates];
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


#pragma mark touch delegate
- (void) handleTapFrom: (UserDataTapGestureRecognizer *)recognizer
{
    NSLog(@"%@",[recognizer holder]);
}


- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    
    [[touch view] setCenter:[touch locationInView:self.view]];
}

@end
