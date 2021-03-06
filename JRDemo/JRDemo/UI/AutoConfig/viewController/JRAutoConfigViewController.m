//
//  JRAutoConfigViewController.m
//  JRDemo
//
//  Created by Home on 16/04/2018.
//  Copyright © 2018 Ginger. All rights reserved.
//

#import "JRAutoConfigViewController.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#import "JRAutoConfigManager.h"

@interface JRAutoConfigViewController () <JRAutoConfigManagerDelegate, JRAutoConfigCallback>

@property (nonatomic, assign) JRAutoConfigPort port;

@end

@implementation JRAutoConfigViewController

- (instancetype)init
{
    if ([super init]) {
        [JRAutoConfigManager sharedInstance].delegate = self;
        [JRAutoConfig sharedInstance].delegate = self;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"选择自动配置环境" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *commercial = [UIAlertAction actionWithTitle:@"商用局" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.port = JRAutoConfigPortCommercial;
        [[JRAutoConfigManager sharedInstance] requestLoginAuthInPs];
        [SVProgressHUD showWithStatus:@"自动配置中.."];
    }];
    UIAlertAction *test = [UIAlertAction actionWithTitle:@"测试局" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.port = JRAutoConfigPortTest;
        [[JRAutoConfigManager sharedInstance] requestLoginAuthInPs];
        [SVProgressHUD showWithStatus:@"自动配置中.."];
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:commercial];
    [alert addAction:test];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [SVProgressHUD dismiss];
}

#pragma mark - JRAutoConfigManagerDelegate

- (void)cmccCpGetAuthInformationSucceed:(NSString *)userName password:(NSString *)password token:(NSString *)token {
    [[JRAutoConfig sharedInstance] startAutoConfig:userName password:password token:token port:self.port];
    if (self.port == JRAutoConfigPortTest) {
        //    // 测试局下多方视频appId
        JRAccountConfigParam *param = [[JRAccountConfigParam alloc] init];
        //    // 和飞信
        //    param.stringParam = @"47";
        //    // 菊风
        param.stringParam = @"189";
        [JRAccount setAccount:userName config:param forKey:JRAccountConfigKeyConfId];
    }
}

- (void)cmccCpGetAuthInformationFailed:(NSUInteger)resultCode {
    [SVProgressHUD dismiss];
    [SVProgressHUD showErrorWithStatus:@"自动配置失败"];
}

#pragma mark - JRAutoConfigCallback

- (void)onAutoConfigResult:(BOOL)result code:(JRAutoConfigError)code {
    [SVProgressHUD dismiss];
    if (!result) {
        [SVProgressHUD showErrorWithStatus:@"自动配置失败"];
    } else {
        [SVProgressHUD showSuccessWithStatus:@"自动配置成功"];
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.navigationController popViewControllerAnimated:YES];
    });
}

- (void)onAutoConfigExpire {
    [[JRAutoConfigManager sharedInstance] requestLoginAuthInPs];
}

- (void)onAutoConfigAuthInd {
    [[JRAutoConfigManager sharedInstance] requestLoginAuthInPs];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
