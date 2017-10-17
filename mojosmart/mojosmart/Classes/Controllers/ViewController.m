//
//  ViewController.m
//  mojosmart
//
//  Created by Luiz Peres on 2017-10-16.
//  Copyright © 2017 Luiz Peres. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <UIImagePickerControllerDelegate,
                              UINavigationControllerDelegate,
                              UIPopoverPresentationControllerDelegate>

@property (nonatomic, weak) IBOutlet UIImageView *imageView;

@property (nonatomic, strong) UIImage *originalImage;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self launchCameraAnimated:NO];
}

// -------------------------------------------------
- (IBAction)wandPressed:(id)sender {
}

// -------------------------------------------------
- (IBAction)sketchPressed:(id)sender {
}

// -------------------------------------------------
- (IBAction)settingsPressed:(id)sender {
}

// -------------------------------------------------
- (IBAction)cameraPressed:(id)sender {
    [self launchCameraAnimated:YES];
}

// -------------------------------------------------
- (void) launchCameraAnimated:(BOOL)animated
{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.sourceType =  UIImagePickerControllerSourceTypeCamera;
    imagePicker.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    imagePicker.allowsEditing = NO;
    [self presentViewController:imagePicker animated:animated completion:nil];
}


// -------------------------------------------------
- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    self.originalImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    UIImage *newImage = [UIImage imageWithCGImage:[self.originalImage CGImage]
                        scale:[self.originalImage scale]
                  orientation: UIImageOrientationRight];
    self.imageView.image = newImage;
    [picker dismissViewControllerAnimated:YES completion:nil];
}

// -------------------------------------------------
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end

//Icons
//Gregor Cresnar
//Smashicons
//Freepik




