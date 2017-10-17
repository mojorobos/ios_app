//
//  SobelObject.h
//  mojosmart
//
//  Created by Luiz Peres on 2017-10-17.
//  Copyright © 2017 Luiz Peres. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef struct
{
    int    direction;
    bool   is_using;
    double gradient;
    UInt8  color;
} SobelInfo;

@interface SobelObject : NSObject

- (void) done;

@property (nonatomic, strong) UIImage   *image;
@property (nonatomic, assign) SobelInfo *info;

@end
