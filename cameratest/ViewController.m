//
//  ViewController.m
//  CameraTest
//
//  Created by Aditya on 02/10/13.
//  Copyright (c) 2013 Aditya. All rights reserved.
//

#import "ViewController.h"
#import "Constants.h"
#import <AWSS3/AWSS3.h>


@interface ViewController ()
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //initializing array to put contents of download into
    self.tableData = [[NSMutableArray alloc]init];
    
    self.s3Util = [[AmazonS3Util alloc]init];

    //lists all of objects stored on AWS
  [self listObjects:self];
  
    
}
//delegate method that gets called because of the protocol. Will populate tableview when data is done loading in the background
-(void)updateWithData:(NSMutableArray *)data{
    self.tableData = data;
    [self.tableView reloadData];
}

- (void)listObjects:(id)sender {
    
    [self.s3Util loadData:self];
    
    }

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)edit:(id)sender{
    if([self.tableView isEditing]){
        [sender setTitle:@"Edit"];
    }else{
        [sender setTitle:@"Done"];
    }
    [self.tableView setEditing:![self.tableView isEditing]];
}

- (IBAction)takePicture:(id)sender{
    
    if([self.popController isPopoverVisible]){
        [self.popController dismissPopoverAnimated:YES];
        self.popController = nil;
        return;
    }
    
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    
    if( [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] ){
      
        [imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
    }else
    {
        [imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
 
    }
    
    [imagePicker setAllowsEditing:TRUE];

    [imagePicker setDelegate:self];
    
    self.popController = [[UIPopoverController alloc]initWithContentViewController:imagePicker];
    
    [self.popController setDelegate:self];
    
    [self.popController presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    
    
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    //getting the image from phone
    self.imageFromLib = [info objectForKey:UIImagePickerControllerEditedImage];
    [self.imageView setImage:self.imageFromLib];
    
    //adding the date to the file
    self.fileDate = [[NSString alloc] initWithFormat:@"%f.png", [[NSDate date] timeIntervalSince1970 ] ];


   [self.popController dismissPopoverAnimated:YES];
    
    //Calls the  method because popController does have delegate method
    [self popoverControllerDidDismissPopover:self.popController];
}

-(void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
    
    //specifies what happens when ok action is clicked. Notice that upload includes the unique name and unique file date
    self.okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", "OK") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self.s3Util uploadPicture:self With:self.imageFromLib andDate:self.fileDate andName:self.nameOfKey];
        
    }];
    //okAction disabled
    self.okAction.enabled = NO;
    
    //creates the uialret
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"Name"
        message:@"Enter your name"
    preferredStyle:UIAlertControllerStyleAlert];
    
    [controller addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.delegate = self;
        
    }];
    [controller addAction:self.okAction];
    
    [self presentViewController:controller animated:YES completion:nil];
    
   }

//delegate method for uploading pictures as declared in Amazon s3Util
-(void)updatePicture: (NSString *)filePath andFileName: (NSString *)fileName{
    
    //Set it equal to the the file path sent by the upload piciture method in the DAO
    self.imageView.image = [UIImage imageWithContentsOfFile:filePath];
    
    //adding object to the array to populate the taebleview
    [self.tableData addObject:fileName];
    
    //relaoad table
    [self.tableView reloadData];
    
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    
    NSString *finalString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (finalString.length>= 5) {
    };
    
    //once the user has typed a name that is bigger or equal to 5 characters the okaction will be enabled and the upload will begin.
    [self.okAction setEnabled:(finalString.length >= 5)];
    self.nameOfKey =textField.text;
    
    return YES;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"Table Data Count: %lu\n", (unsigned long)[self.tableData count]);
    return [self.tableData count];
}


-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    
    if(!cell){
        cell =
        [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCell"];
    }
    NSString *fileName = [[NSString alloc] initWithFormat:@"%@",
                         [self.tableData objectAtIndex: indexPath.row ]];
    
    [[cell textLabel] setText: fileName];
    return cell;
}
- (void)tableView: (UITableView *)tableView didSelectRowAtIndexPath: (NSIndexPath *)indexPath
{

    NSString *fileName = [NSString stringWithFormat:@"%@",
                          [self.tableData objectAtIndex: indexPath.row ]];
    
    [self showSelectedPicture:fileName];
}

-(void)showSelectedPicture:(NSString*)fileName{

    //Accces just the documents directory
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    self.downloadingFilePath = [paths objectAtIndex:0];
    
    //Access the row selected by passing it the fileName
    self.downloadingFilePath = [self.downloadingFilePath stringByAppendingPathComponent:fileName];
    
    //Set it equal to the image view
    self.imageView.image = [UIImage imageWithContentsOfFile:self.downloadingFilePath];

}

- (void) tableView: (UITableView *)tableView  commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSString *fileName = [NSString stringWithFormat:@"%@",
                          [self.tableData objectAtIndex: indexPath.row]];
    //remove from AWS
    [self.s3Util deletePicture:fileName];
    
    //create the ok action
    self.okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", "OK") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
    }];
    
    //create the alert
    UIAlertController *controllerDelete = [UIAlertController alertControllerWithTitle:@"Delete"
    message:@"The picture has been deleted."preferredStyle:UIAlertControllerStyleAlert];
    
    //ad the okaction
    [controllerDelete addAction:self.okAction];
    
    //present the alert
    [self presentViewController:controllerDelete animated:YES completion:nil];
    
    //remoe from talbedata
    [self.tableData removeObjectAtIndex:indexPath.row];
    

    [self.tableView reloadData];

 }

@end
