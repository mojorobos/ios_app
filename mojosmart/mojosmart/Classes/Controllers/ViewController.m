//
//  ViewController.m
//  mojosmart
//
//  Created by Luiz Peres on 2017-10-16.
//  Copyright © 2017 Luiz Peres. All rights reserved.
//

#import "ViewController.h"
#import "Wand.h"
#import "Session.h"

@interface ViewController () <UIImagePickerControllerDelegate,
                              UINavigationControllerDelegate,
                              UIPopoverPresentationControllerDelegate>

@property (nonatomic, weak) IBOutlet UIImageView *imageView;

@property (nonatomic, strong) UIImage *originalImage;

@property (nonatomic, strong) UIView  *deleteLater;
@property (nonatomic, strong) UILabel *deleteLabel;
@property (nonatomic, strong) NSTimer *timer;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addTapCancel];
    
    [self launchCameraAnimated:NO];
}

// -------------------------------------------------
- (void) addTapCancel
{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    [self.view addGestureRecognizer:tap];
}

// -------------------------------------------------
- (void) tap:(UIGestureRecognizer *)tap
{
    if (self.deleteLater) {
        [self.timer invalidate];
        [self.deleteLabel removeFromSuperview];
        [self.deleteLater removeFromSuperview];
        self.deleteLater = nil;
    }
}

#pragma mark Screen Events

// -------------------------------------------------
- (IBAction)wandPressed:(id)sender {
    __weak ViewController *weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        ViewController *strongSelf = weakSelf;
        UIImage *new_image = [Wand applyGrayScaleOnImage:strongSelf.originalImage];
        new_image = [Wand applyGaussianOnImage:new_image];
        SobelObject *sobelObj = [Wand applySobelOnImage:new_image];
        
        Session *session = [Session sharedInstance];
        if (session.usingCanny) {
            NSInteger max = session.cannyMaxTrashold;
            NSInteger min = session.cannyMinTrashold;
            new_image = [Wand applyCannyOnSobelObj:sobelObj withMax:max andMinTrashold:min];
            [strongSelf setImageWithOrientationRight:new_image];
        } else {
            [strongSelf setImageWithOrientationRight:sobelObj.image];
        }
        
        [sobelObj done];
    });
}

// -------------------------------------------------
- (IBAction)sketchPressed:(id)sender {
    [self tap:nil];
    self.deleteLater = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width * 0.6, self.view.frame.size.height * 0.2)];
    self.deleteLater.center = self.view.center;
    [self.deleteLater setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:0.8]];
    
    self.deleteLabel = [[UILabel alloc] init];
    [self.deleteLater addSubview:self.deleteLabel];
    
    [self.view addSubview:self.deleteLater];
    
    __weak ViewController *weakSelf = self;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.3 repeats:YES block:^(NSTimer * _Nonnull timer) {
        static int counter = 0;
        if ((++counter)%10 != 0) {
            ViewController *strongSelf = weakSelf;
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *loading = @"Drawing";
                loading = [loading stringByPaddingToLength:loading.length+(counter%10) withString:@"." startingAtIndex:0];
                [strongSelf.deleteLabel setText:loading];
                [strongSelf.deleteLabel sizeToFit];
                strongSelf.deleteLabel.center = CGPointMake(strongSelf.deleteLater.frame.size.width/2, strongSelf.deleteLater.frame.size.height/2);
            });
        }
    }];
}

// -------------------------------------------------
- (IBAction)cameraPressed:(id)sender {
    [self launchCameraAnimated:YES];
}

#pragma mark Camera Related

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
    [self setImageWithOrientationRight:self.originalImage];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void) setImageWithOrientationRight:(UIImage *)image
{
    UIImage *newImage = [UIImage imageWithCGImage:[image CGImage]
                                            scale:[image scale]
                                      orientation: UIImageOrientationRight];
    self.imageView.image = newImage;
}

// -------------------------------------------------
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
