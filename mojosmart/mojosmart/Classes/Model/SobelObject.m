//
//  SobelObject.m
//  mojosmart
//
//  Created by Luiz Peres on 2017-10-17.
//  Copyright © 2017 Luiz Peres. All rights reserved.
//

#import "SobelObject.h"

@implementation SobelObject

- (void) done
{
    free(self.info);
    self.image = nil;
}

@end
