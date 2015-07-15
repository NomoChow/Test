//
//  Test1ViewController.m
//  NSURLSession_Test
//
//  Created by 周建顺 on 15/7/3.
//  Copyright (c) 2015年 周建顺. All rights reserved.
//

#import "Test1ViewController.h"

@interface Test1ViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

@end

@implementation Test1ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    str = @"21312312";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)loadData:(UIBarButtonItem *)sender {
    self.spinner.hidden = NO;
    [self.spinner startAnimating];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.baidu.com"]];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        [self showResponseCode:response];
        
        [self.webView loadData:data MIMEType:@"text/html" textEncodingName:@"utf-8" baseURL:nil];
        [self.spinner stopAnimating];
        self.spinner.hidden = YES;
    }];
    
    [dataTask resume];
}



- (IBAction)uploadFile:(id)sender {
}
- (IBAction)downloadFile:(id)sender {
    [self.spinner startAnimating];
    NSURLSession *session= [NSURLSession sharedSession];
    NSURLSessionDownloadTask *downloadSession = [session downloadTaskWithURL:[NSURL URLWithString:@"http://b.hiphotos.baidu.com/image/w%3D2048/sign=6be5fc5f718da9774e2f812b8469f919/8b13632762d0f703b0faaab00afa513d2697c515.jpg"   ] completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
        [self showResponseCode:response];
        
        NSLog(@"location:%@",location);
        
        NSString *path = [self getDoucmentsPath];
        NSURL *pathUrl = [NSURL fileURLWithPath:path];
        NSURL *fileUrl = [pathUrl URLByAppendingPathComponent:[response.URL lastPathComponent]];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:[fileUrl path]]) {
            NSError *error;
            [[NSFileManager defaultManager] removeItemAtURL:fileUrl error:&error];
        }
        NSError *nsError;
        //[[NSFileManager defaultManager] moveItemAtPath:[location path] toPath:[fileUrl path] error:&nsError];
        [[NSFileManager defaultManager] moveItemAtURL:location toURL:fileUrl error:&nsError];
        NSURLRequest *req = [NSURLRequest requestWithURL:fileUrl];
        [self.webView loadRequest:req];
        
        [self.spinner stopAnimating];
        
        

    }];
    
    [downloadSession resume];
}

-(NSString*)getDoucmentsPath{
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES) firstObject];
    return path;
}

/* 输出http响应的状态码 */
- (void)showResponseCode:(NSURLResponse *)response {
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
    NSInteger responseStatusCode = [httpResponse statusCode];
    NSLog(@"%ld", (long)responseStatusCode);
}

@end
