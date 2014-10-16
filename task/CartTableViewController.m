//
//  CartTableViewController.m
//  task
//
//  Created by OsamaMac on 10/16/14.
//  Copyright (c) 2014 VF. All rights reserved.
//

#import "CartTableViewController.h"
#import "UIImageView+WebCache.h"

@interface CartTableViewController ()

@end

@implementation CartTableViewController
{
    NSMutableArray* uiniqueCart;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    uiniqueCart = [[NSMutableArray alloc]init];
    for(int i = 0 ; i < self.cart.count; i++)
    {
        NSDictionary* dict  = [self.cart objectAtIndex:i];
        BOOL search = YES;
        for(NSDictionary* dict2 in uiniqueCart)
        {
            if([[[dict2 objectForKey:@"entry"] objectForKey:@"prodName"]isEqualToString:[dict objectForKey:@"prodName"]])
            {
                search = NO;
                break;
            }
        }
        
        int total = 1;
        if(search)
        {
            for(int j = (i+1); j < self.cart.count ; j++)
            {
                NSDictionary* dict3 = [self.cart objectAtIndex:j];
                if([[dict objectForKey:@"prodName"]isEqualToString:[dict3 objectForKey:@"prodName"]])
                {
                    total++;
                }
            }
            NSDictionary* uniqueAdd = [[NSDictionary alloc]initWithObjects:@[[NSString stringWithFormat:@"%iX",total],dict] forKeys:@[@"count",@"entry"]];
            [uiniqueCart addObject:uniqueAdd];
        }
        
    }
    
    [self.tableView reloadData];
    [self.tableView setNeedsDisplay];
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
    return uiniqueCart.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* cellID = @"cartCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    
    if(!cell)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    
    
    NSDictionary* current = [uiniqueCart objectAtIndex:indexPath.row];
    
    [(UILabel*)[cell viewWithTag:1]setText:[current objectForKey:@"count"]];
    [(UIImageView*)[cell viewWithTag:2] setImageWithURL:[NSURL URLWithString:[[current objectForKey:@"entry"] objectForKey:@"prodImage"]]];

    
    
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

@end
