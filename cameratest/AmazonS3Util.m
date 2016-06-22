//
//  AmazonS3Util.m
//  CameraTest
//
//  Created by Aditya on 08/11/13.
//  Copyright (c) 2013 Aditya. All rights reserved.
//

#import "AmazonS3Util.h"
#import <AWSCore/AWSCore.h>
#import <AWSCognito/AWSCognito.h>
#import "Constants.h"


@implementation AmazonS3Util


-(id)init {
    self = [super init];
    
    self.transferManager = [AWSS3TransferManager defaultS3TransferManager];
    
    return self;
}

- (void)loadData:(id<AmazonS3Delegate>)sender {
    
    //creaeting s3 object
    AWSS3 *s3 = [AWSS3 defaultS3];
    
    //creating list object request
    AWSS3ListObjectsRequest *listObjectsRequest = [AWSS3ListObjectsRequest new];
    
    //make sure access the correct bucket
    listObjectsRequest.bucket = S3BucketName;
    
    [[s3 listObjects:listObjectsRequest] continueWithBlock:^id(AWSTask *task) {
        if (task.error) {
            NSLog(@"listObjects failed: [%@]\n", task.error);
        } else {
            AWSS3ListObjectsOutput *listObjectsOutput = task.result;
            
            NSMutableArray *pictureData = [[NSMutableArray alloc]init];
            
            //itierating through the output returned from the list object request
            for (_s3Object in listObjectsOutput.contents) {
                
                // path creates a file path that links to the documents directory
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                self.downloadingFilePath = [paths objectAtIndex:0];
                
                //append the filename (s3Object.key) to the end of the file name
                self.downloadingFilePath = [self.downloadingFilePath stringByAppendingPathComponent:_s3Object.key];
                
                //adding the photos to the mutable array to send to the table
                [pictureData addObject:_s3Object.key];
                
                //Create a url that the file can download to
                NSURL *downloadingFileURL = [NSURL fileURLWithPath:self.downloadingFilePath];
                
                if ([[NSFileManager defaultManager] fileExistsAtPath:self.downloadingFilePath]) {
                    NSLog(@"%@ EXISTS!\n", _s3Object.key);
                } else {
                    NSLog(@"%@ DOES NOT EXIST!\n", _s3Object.key);
                    self.downloadRequest = [AWSS3TransferManagerDownloadRequest new];
                    self.downloadRequest.bucket = S3BucketName;
                    self.downloadRequest.key = _s3Object.key;
                    self.downloadRequest.downloadingFileURL = downloadingFileURL;
                    [self downloadData];
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
            [sender updateWithData:pictureData];
                
            });
        }
        return nil;
    }];
}

-(void)downloadData
{
// Download the file.
    [[self.transferManager download:self.downloadRequest] continueWithExecutor:[AWSExecutor mainThreadExecutor]
        withBlock:^id(AWSTask *task) {
        if (task.error){
            if ([task.error.domain isEqualToString:AWSS3TransferManagerErrorDomain]) {
                switch (task.error.code){
                    case AWSS3TransferManagerErrorCancelled:
                    case AWSS3TransferManagerErrorPaused:
                        
                break;
                default:
                NSLog(@"Error: %@\n", task.error);
                break;
                                        }
                } else {
                // Unknown error.
                NSLog(@"Error: %@\n", task.error);
                        }
                                    }
        if (task.result) {
    AWSS3TransferManagerDownloadOutput *downloadOutput = task.result;
//           NSLog(@"The picture was downloaded\n");
        //File downloaded successfully.
        }
        return nil; }];
  
}

-(void)uploadPicture:(id <AmazonS3Delegate>)sender With:(UIImage*)image andDate:(NSString *)fileDate andName:(NSString*) name;{
    
    //image you want to upload
    UIImage* imageToUpload = image;
    
    
    //Accces just the documents directory
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
   NSString *filePath = [paths objectAtIndex:0];
    
    //Access the row selected by passing it the fileName
    filePath = [filePath stringByAppendingPathComponent:name];

    
    [UIImagePNGRepresentation(imageToUpload) writeToFile:filePath atomically:YES];
    
    NSURL* fileUrl = [NSURL fileURLWithPath:filePath];
    
    //upload the image
    AWSS3TransferManagerUploadRequest *uploadRequest = [AWSS3TransferManagerUploadRequest new];
    uploadRequest.body = fileUrl;
    uploadRequest.bucket = S3BucketName;
    
    uploadRequest.key = name;
    uploadRequest.contentType = @"image/png";
    //
    //Upload the file
    [[self.transferManager upload:uploadRequest] continueWithExecutor:[AWSExecutor mainThreadExecutor]
        withBlock:^id(AWSTask *task) {
            if (task.error) {
                if ([task.error.domain isEqualToString:AWSS3TransferManagerErrorDomain]) {
                    switch (task.error.code) {
                        case AWSS3TransferManagerErrorCancelled:
                        case AWSS3TransferManagerErrorPaused:
                        break;
                        default:
                        NSLog(@"Error: %@\n", task.error);break;}
                        } else {
                        // Unknown error.
                        NSLog(@"Error: %@\n", task.error);}
                                }
                if (task.result) {
                    //AWSS3TransferManagerUploadOutput *uploadOutput = task.result;
                    NSLog(@"The upload was succesful\n");
                    // The file uploaded successfully.
                                    }
            //sends the delegate method necessary filename and file path.
            [sender updatePicture:filePath andFileName:uploadRequest.key];

        return nil;}];
       //sends the delegate method necessary filename
    
}

-(void)deletePicture: (NSString *)fileKey{
    AWSS3 *s3 = [AWSS3 defaultS3];
    
    //Delete Object
    AWSS3DeleteObjectRequest *deleteObjectRequest = [AWSS3DeleteObjectRequest new];
    deleteObjectRequest.bucket = S3BucketName;
    deleteObjectRequest.key = fileKey;
    
    [[s3 deleteObject:deleteObjectRequest] continueWithBlock:^id(AWSTask *task) {
        if(task.error)
        {
            NSLog (@"The request failed. error: [%@]\n", task.error);
        }else {
        NSLog(@"The file was deleted");
            
        }
        
        return task;
        
    }];
    
}
@end
