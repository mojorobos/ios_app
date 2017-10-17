//
//  PopoverUtil.m
//  mojosmart
//
//  Created by Luiz Peres on 2017-10-16.
//  Copyright © 2017 Luiz Peres. All rights reserved.
//

#import "PopoverUtil.h"

@implementation PopoverUtil

+ (void) showPopover:(NSString *)storyboardId forViewController:(UIViewController<UIPopoverPresentationControllerDelegate> *)vc nextToView:(UIView *) view
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *controller = [storyboard instantiateViewControllerWithIdentifier:storyboardId];
    
    controller.modalPresentationStyle = UIModalPresentationPopover;
    [vc presentViewController:controller animated:YES completion:nil];
    
    UIPopoverPresentationController *popController = [controller popoverPresentationController];
    popController.permittedArrowDirections = UIPopoverArrowDirectionUp;
    popController.delegate = vc;
    
    popController.sourceView = view;
    popController.sourceRect = CGRectMake(30, 50, 10, 10);
}

@end
