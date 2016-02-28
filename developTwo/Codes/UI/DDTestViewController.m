//
//  DDTestViewController.m
//  DDESAN
//
//  Created by 杨超杰 on 15/11/30.
//  Copyright © 2015年 Air-canvas Information Techonology Co. Ltd. All rights reserved.
//

#import "DDTestViewController.h"

@interface DDTestViewController ()<ASIHTTPRequestDelegate>
{
ASIHTTPRequest* _campaignListRequest;
}
@end

@implementation DDTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSURL* r=getConfigListUrlTwo();
    NSLog(@"%@",r);
    ASIFormDataRequest* requset=[[ASIFormDataRequest alloc]initWithURL:r];
    [requset setDelegate:self];
    [requset startAsynchronous];
    
    
    _campaignListRequest = requset;
    // Do any additional setup after loading the view.
}

- (void)requestFinished: (ASIHTTPRequest*)request {
    if(request == _campaignListRequest) {
        _campaignListRequest = nil;
        
        
        
        int httpStatusCode = [request responseStatusCode];
        if(httpStatusCode != 200) {
            NSLog(@"HTTP - %d", httpStatusCode);
            
            alert(@"无法获取活动列表（接口返回无效状态）。");
            
            return;
        }
        
        NSData* responseData = [request responseData];
        NSString* responseString = [[NSString alloc] initWithData: responseData encoding: NSUTF8StringEncoding];
        NSLog(@"OUT - %@", responseString);
        
        NSDictionary* responseParameters = [[NSJSONSerialization JSONObjectWithData: responseData options: 0 error: NULL] asDictionary];
        if(responseParameters == nil) {
            alert(@"无法获取活动列表（接口返回格式不正确）。");
            
            return;
        }
        
        NSString* responseStatus = responseParameters[@"status"];
        if(![[responseStatus lowercaseString] isEqualToString: @"ok"]) {
            NSDictionary* jsonError = [responseParameters[@"error"] asDictionary];
            
            NSString* errorCode = [jsonError[@"code"] asString];
            if([errorCode isEqualToString: @"ERR007"]) {
                return;
            }
            else {
                NSString* errorMessage = [jsonError[@"msg"] asString];
                if(errorMessage == nil) {
                    errorMessage = @"无法获取活动列表（发生未知错误）。";
                }
                
                alert(errorMessage);
            }
            
            return;
        }
        
        
        NSDictionary* jsonData = [responseParameters[@"data"] asDictionary];
        NSLog(@"%@2394025=================================================================",jsonData);
        //NSArray* jsonCampaigningStationList = [jsonData[@"list"] asArray];
        
        return;
    }
}

- (void)requestFailed: (ASIHTTPRequest*)request {
    if(request == _campaignListRequest) {
        _campaignListRequest = nil;
        
       
        
        alert(@"无法获取活动列表（网络连接失败）。");
        
  
    }
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

@end
