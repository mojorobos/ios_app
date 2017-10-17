//
//  PopoverUtil.h
//  mojosmart
//
//  Created by Luiz Peres on 2017-10-16.
//  Copyright © 2017 Luiz Peres. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PopoverUtil : NSObject

+ (void) showPopover:(NSString *)storyboardId forViewController:(UIViewController<UIPopoverPresentationControllerDelegate> *)vc nextToView:(UIView *) view;

@end
