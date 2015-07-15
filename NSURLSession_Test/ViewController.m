//
//  ViewController.m
//  NSURLSession_Test
//
//  Created by 周建顺 on 15/7/3.
//  Copyright (c) 2015年 周建顺. All rights reserved.
//

#import "ViewController.h"
#import "UrlSessionDemoViewController.h"

NSString *str;

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    NSString *str = @"12345";
    int i = [str integerValue];
    NSLog(@"%i",i);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    if (indexPath.row == 2) {
        UrlSessionDemoViewController *vc = [[UrlSessionDemoViewController alloc] initWithNibName:@"UrlSessionDemoViewController" bundle:nil];
        [self.navigationController pushViewController:vc animated:YES];
    }

}

@end
