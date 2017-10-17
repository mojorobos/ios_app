//
//  Session.h
//  mojosmart
//
//  Created by Luiz Peres on 2017-10-17.
//  Copyright © 2017 Luiz Peres. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Session : NSObject

+ (instancetype) sharedInstance;

@property (nonatomic, assign) BOOL      usingSobel;
@property (nonatomic, assign) BOOL      usingCanny;
@property (nonatomic, assign) NSInteger cannyMaxTrashold;
@property (nonatomic, assign) NSInteger cannyMinTrashold;

@end
