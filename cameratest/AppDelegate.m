//
//  AppDelegate.m
//  CameraTest
//
//  Created by Aditya on 02/10/13.
//  Copyright (c) 2013 Aditya. All rights reserved.
//

#import "AppDelegate.h"
#import <AWSCore/AWSCore.h>
#import <AWSS3/AWSS3.h>
#import <AWSCognito/AWSCognito.h>
#import "Constants.h"

#import "ViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    //Create a default service configuration
    
    AWSCognitoCredentialsProvider *credentialsProvider = [[AWSCognitoCredentialsProvider alloc] initWithRegionType:CognitoRegionType
                                                                                                    identityPoolId:CognitoIdentityPoolId];
    AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc] initWithRegion:DefaultServiceRegionType
                                                                         credentialsProvider:credentialsProvider];
    AWSServiceManager.defaultServiceManager.defaultServiceConfiguration = configuration;
    
        

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.viewController = [[ViewController alloc] initWithNibName:@"ViewController" bundle:nil];
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    return YES;
    
       return YES;
    
    
    
    
    
//    AWSCognitoCredentialsProvider *credentialsProvider = [[AWSCognitoCredentialsProvider alloc]initWithRegionType:AWSRegionUSEast1 identityPoolId:@"us-east-1:d3c691ce-2581-4f39-8345-ea97ad7c8e21"];
//    
//    AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionUSEast1 credentialsProvider:credentialsProvider];
//    
//    AWSServiceManager.defaultServiceManager.defaultServiceConfiguration = configuration;
//    
//    //our entry point to the high-level S3 API.
//    AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
//    
//    // Construct the NSURL for the download location.
//    NSString *downloadingFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"downloaded-myImage.jpg"];
//    NSURL *downloadingFileURL = [NSURL fileURLWithPath:downloadingFilePath];
//    
//    // Construct the download request.
//    AWSS3TransferManagerDownloadRequest *downloadRequest = [AWSS3TransferManagerDownloadRequest new];
//    
//    downloadRequest.bucket = @"canmerandcloud";
//    downloadRequest.key = @"destroyer.gif";
//    downloadRequest.downloadingFileURL = downloadingFileURL;
//    
//    
//    // Download the file.
//    [[transferManager download:downloadRequest] continueWithExecutor:[AWSExecutor mainThreadExecutor]
//        withBlock:^id(AWSTask *task) {
//        if (task.error){
//        if ([task.error.domain isEqualToString:AWSS3TransferManagerErrorDomain]) {
//            switch (task.error.code) {
//            case AWSS3TransferManagerErrorCancelled:
//            case AWSS3TransferManagerErrorPaused:
//            break;
//            default:
//            NSLog(@"Error: %@", task.error);
//            break;}}
//            else {
//            // Unknown error.
//            NSLog(@"Error: %@", task.error);}}
//        if (task.result) {
//            AWSS3TransferManagerDownloadOutput *downloadOutput = task.result;
//            //File downloaded successfully.
//            NSLog(@" The download was successful");
//            }return nil;}];
//    self.imageView.image = [UIImage imageWithContentsOfFile:downloadingFilePath];
//
//    
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
