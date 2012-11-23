//
//  StaticsViewController.m
//  Location_sample
//
//  Created by 승원 김 on 12. 11. 6..
//  Copyright (c) 2012년 승원 김. All rights reserved.
//

#import "StaticsViewController.h"
#import "DetailViewController.h"

@interface StaticsViewController ()

@end

@implementation StaticsViewController

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
    // Do any additional setup after loading the view from its nib.
    
    _array = [[NSArray alloc] initWithObjects:@"Sleepy", @"Sneezy",
					  @"Bashful", @"Happy", @"Doc", @"Grumpy", @"Dopey", @"Thorin",
					  @"Dorin", @"Nori", @"Ori", @"Balin", @"Dwalin", @"Fill", @"Kili",
					  @"Oin", @"Gloin", @"Bifur", @"Bofur", @"Bombur", nil];
    
    // db 생성및확인
    NSString *docsDir;
    NSArray *dirPaths;
    
    // documents 디렉토리확인하기
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = [dirPaths objectAtIndex:0];
    
    databasePath = [[NSString alloc] initWithString:[docsDir stringByAppendingPathComponent:@"ridings.db"]];
    
    const char *dbpath = [databasePath UTF8String];
    sqlite3_stmt *statement;
    
    if (sqlite3_open(dbpath, &ridingDB) == SQLITE_OK) {
        NSString *querySQL = [NSString stringWithFormat:@"SELECT * FROM ridings ORDER BY id DESC"];
        const char *query_stmt = [querySQL UTF8String];

        _recording = [[NSMutableArray alloc] init];
        if (sqlite3_prepare_v2(ridingDB, query_stmt, -1, &statement, NULL) == SQLITE_OK) {
            while (sqlite3_step(statement) == SQLITE_ROW) {
                NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
                [dic setObject:[[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(statement, 0)] forKey:@"id"];
                [dic setObject:[[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(statement, 1)] forKey:@"time"];
                [dic setObject:[[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(statement, 2)] forKey:@"distance"];
                [dic setObject:[[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(statement, 3)] forKey:@"speed"];
                [dic setObject:[[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(statement, 4)] forKey:@"altitude"];
                [dic setObject:[[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(statement, 5)] forKey:@"calorie"];
                //NSString *timeField = [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(statement, 1)];
                [_recording addObject:dic];
    
            }
            NSLog(@"%@",[_recording[0] objectForKey:@"id"]);
            
        }
        else {
            NSLog(@"Match not found");
        }
        sqlite3_finalize(statement);
    }
    sqlite3_close(ridingDB);

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


# pragma mark -

# pragma mark Table View DataSource & Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSLog(@"%d", [_recording count]);
    return [_recording count];
//    return [_array count];
    
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    
    NSUInteger row = [indexPath row];
//    NSString *rowData = [_array objectAtIndex:row];
    NSDictionary *rowData = [_recording objectAtIndex:row];

    cell.textLabel.text = [rowData objectForKey:@"id"];
//    cell.textLabel.text = rowData;
    
    return cell;
}

#pragma mark -
#pragma mark Table View Delegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSUInteger row = [indexPath row];
	NSLog(@"didSelectRowAtIndexPath : %d", row);
	//NSUInteger row = [indexPath row];
	NSDictionary *rowData = [_recording objectAtIndex:row];
//	NSString *message = [[NSString alloc] initWithFormat:@"You selected %@", [rowData objectForKey:@"id"]];
//	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Row Selected!"
//                                                    message:message delegate:nil
//                                          cancelButtonTitle:@"Yes I Did" otherButtonTitles:nil];
//	[alert show];
//	[tableView deselectRowAtIndexPath:indexPath animated:YES];
    DetailViewController *detailViewController = [[DetailViewController alloc] initWithNibName:@"DetailViewController" bundle:nil];
    [self.navigationController pushViewController:detailViewController animated:YES];
    detailViewController.recordingTime.text = [rowData objectForKey:@"time"];
    detailViewController.distance.text = [rowData objectForKey:@"distance"];
    detailViewController.averageSpeed.text = [rowData objectForKey:@"speed"];
    detailViewController.altitude.text = [rowData objectForKey:@"altitude"];
    detailViewController.calorie.text = [rowData objectForKey:@"calorie"];
    [detailViewController release];
    
}

@end
