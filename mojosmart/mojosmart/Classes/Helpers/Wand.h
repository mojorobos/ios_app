//
//  Wand.h
//  mojosmart
//
//  Created by Luiz Peres on 2017-10-17.
//  Copyright © 2017 Luiz Peres. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SobelObject.h"

@interface Wand : NSObject

+ (UIImage *) applyGrayScaleOnImage:(UIImage *)image;
+ (UIImage *) applyGaussianOnImage:(UIImage *)image;
+ (SobelObject *) applySobelOnImage:(UIImage *)image;
+ (UIImage *) applyCannyOnSobelObj:(SobelObject *)sobelObj withMax:(NSInteger)max andMinTrashold:(NSInteger)min;

@end
