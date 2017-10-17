//
//  Session.m
//  mojosmart
//
//  Created by Luiz Peres on 2017-10-17.
//  Copyright © 2017 Luiz Peres. All rights reserved.
//

#import "Session.h"

@interface Session ()

@property (nonatomic, assign) BOOL      usingSobel;
@property (nonatomic, assign) BOOL      usingCanny;
@property (nonatomic, assign) NSInteger cannyMaxTrashold;
@property (nonatomic, assign) NSInteger cannyMinTrashold;

@end

@implementation Session

+ (instancetype)sharedInstance
{
    static Session *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[Session alloc] init];
    });
    
    return sharedInstance;
}

- (instancetype) init
{
    self = [super init];
    if (self) {
        self.cannyMaxTrashold = 200;
        self.cannyMinTrashold = 200;
        self.usingSobel = YES;
        self.usingCanny = YES;
    }
    
    return self;
}

@end
