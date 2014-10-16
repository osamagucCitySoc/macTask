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
    __weak IBOutlet UILabel *totalLabel;
    NSMutableData* accumlatedData;
    NSMutableArray* productsWithCats;
    NSMutableArray* cats;
    NSMutableArray* added;
    NSURLConnection* getCatsProductsConnection;
    NSIndexPath* expandedIndex;
    CGRect origianlRect;
    UIScrollView* parent;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView sendSubviewToBack:addView];
    [self.view sendSubviewToBack:addView];
    
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
    
    UIScrollView* scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(8, 40, self.tableView.frame.size.width, 45)];
    scrollView.tag = 4;
    scrollView.delegate = self;
    [scrollView setUserInteractionEnabled:YES];
    [scrollView setBackgroundColor:[UIColor clearColor]];
    [scrollView setCanCancelContentTouches:NO];
    
    scrollView.indicatorStyle = UIScrollViewIndicatorStyleBlack;
    scrollView.clipsToBounds = NO;
    scrollView.scrollEnabled = YES;
    
    
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
        /*UserDataTapGestureRecognizer *tapGestureRecognizer = [[UserDataTapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapFrom:)];
        [tapGestureRecognizer setHolder:dict];
        
        UILongPressGestureRecognizer *mouseDrag = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleDrag:)];
        mouseDrag.numberOfTapsRequired=1;
        mouseDrag.minimumPressDuration=0.05;
        
        [tapGestureRecognizer requireGestureRecognizerToFail:mouseDrag];*/
        
        UserDataTapGestureRecognizer *longPress = [[UserDataTapGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(handleDrag:)];
        [longPress setHolder:dict];
        NSURL* imageToDownload = [NSURL URLWithString:[dict objectForKey:@"prodImage"]];
        
        UIImageView *imageView = [[UIImageView alloc] init];
        [imageView setImageWithURL:imageToDownload];
        [imageView setUserInteractionEnabled:YES];
        [imageView addGestureRecognizer:longPress];
        
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
        added = [[NSMutableArray alloc]init];
        
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


- (void)handleDrag:(UserDataTapGestureRecognizer *)recognizer
{
    CGPoint location = [recognizer locationInView:self.view];

    NSLog(@"%f -- %f",location.x,location.y);
    //location.y = location.y-100 - (expandedIndex.row*44);
    //alocation.x-=30;
        if(recognizer.state == UIGestureRecognizerStateBegan)
            //NSLog(@"handleLongPress: StateBegan");
        {
            origianlRect = [[recognizer view]frame];
            parent = (UIScrollView*)[[recognizer view]superview];
        }else if(recognizer.state == UIGestureRecognizerStateChanged)
        {
            [self.view bringSubviewToFront:[recognizer view]];
            CGRect origFrame = recognizer.view.frame;
            origFrame.origin.y = location.y-100 - (expandedIndex.row*44);
           // origFrame.origin.x = location.x-30;
            [recognizer.view setFrame:origFrame];
        }else if (recognizer.state == UIGestureRecognizerStateEnded)
        {
            [[recognizer view]setFrame:origianlRect];
            

            if(location.y >= addView.frame.origin.y && location.y <= addView.frame.origin.y+addView.frame.size.height)
            {
                [added addObject:[recognizer holder]];
                float price = 0;
                for(NSDictionary* dict in added)
                {
                    price += [[dict objectForKey:@"prodPrice"] floatValue];
                }
                totalLabel.text = [NSString stringWithFormat:@"%@ : %f",@"Total",price];
                
                UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"ADDED" message:[[recognizer holder] objectForKey:@"prodName"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            }
        }
}@end
