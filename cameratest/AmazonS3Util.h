//
//  AmazonS3Util.h
//  CameraTest
//
//  Created by Aditya on 08/11/13.
//  Copyright (c) 2013 Aditya. All rights reserved.
//

#import <AWSS3/AWSS3.h>

//implimenting a protocol
@protocol AmazonS3Delegate <NSObject>

//adding a delegate method.
-(void)updateWithData:(NSMutableArray*)data;
-(void)updatePicture: (NSString *)filePath andFileName:(NSString *)fileName;

@end
@interface AmazonS3Util : NSObject

@property (strong, nonatomic)NSString *downloadingFilePath;
@property (strong, nonatomic)AWSS3TransferManagerDownloadRequest *downloadRequest;
@property (strong, nonatomic)AWSS3TransferManager *transferManager;
@property (strong, nonatomic)AWSS3Object *s3Object;
@property (nonatomic, retain) id delegate;




//public mehtods
// (id<AmazonS3Delegate>) setting the type of id. You have to pass in this kind of id
- (void)loadData:(id<AmazonS3Delegate>)sender;

-(void)uploadPicture:(id <AmazonS3Delegate>)sender With:(UIImage*)image andDate:(NSString *)fileDate andName:(NSString*) name;
-(void)deletePicture: (NSString *)fileKey;



@end
