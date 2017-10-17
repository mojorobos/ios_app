//
//  SettingsTableViewController.m
//  mojosmart
//
//  Created by Luiz Peres on 2017-10-17.
//  Copyright © 2017 Luiz Peres. All rights reserved.
//

#import "SettingsTableViewController.h"
#import "Session.h"

@interface SettingsTableViewController ()

@property (weak, nonatomic) IBOutlet UISlider *minTrasholdSlider;
@property (weak, nonatomic) IBOutlet UITextView *minTrasholdLabel;
@property (weak, nonatomic) IBOutlet UITextView *maxTrasholdLabel;
@property (weak, nonatomic) IBOutlet UISlider *maxTrasholdSlider;
@property (weak, nonatomic) IBOutlet UISwitch *cannySwitch;

@property (strong, nonatomic) Session *session;

@end

@implementation SettingsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.session = [Session sharedInstance];
    [self setupViews];
}

- (void) setupViews
{
    [self.cannySwitch setOn:self.session.usingCanny];
    [self.maxTrasholdLabel setText:[NSString stringWithFormat:@"Min Trashold: %ld", self.session.cannyMaxTrashold]];
    [self.minTrasholdLabel setText:[NSString stringWithFormat:@"Min Trashold: %ld", self.session.cannyMinTrashold]];
    [self.maxTrasholdSlider setValue:self.session.cannyMaxTrashold];
    [self.minTrasholdSlider setValue:self.session.cannyMinTrashold];
    [self cannyEnabled:self.session.usingCanny];
}

- (void) cannyEnabled:(BOOL)enabled
{
    [self.maxTrasholdSlider setEnabled:enabled];
    [self.minTrasholdSlider setEnabled:enabled];
}

- (IBAction)switchChanged:(UISwitch *)sender {
    [self cannyEnabled:sender.isOn];
    [self.session setUsingCanny:sender.isOn];
}

- (IBAction)maxTrasholdChanged:(UISlider *)sender {
     [self.maxTrasholdLabel setText:[NSString stringWithFormat:@"Max Trashold: %ld",(long) self.maxTrasholdSlider.value]];
    [self.session setCannyMaxTrashold:(long)self.maxTrasholdSlider.value];
}

- (IBAction)minTrasholdChanged:(UISlider *)sender {
    [self.minTrasholdLabel setText:[NSString stringWithFormat:@"Min Trashold: %ld",(long) self.minTrasholdSlider.value]];
    [self.session setCannyMinTrashold:(long)self.minTrasholdSlider.value];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
