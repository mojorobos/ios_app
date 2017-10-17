//
//  Wand.m
//  mojosmart
//
//  Created by Luiz Peres on 2017-10-17.
//  Copyright © 2017 Luiz Peres. All rights reserved.
//

#import "Wand.h"

typedef void (^WandBlock)(UInt8 *data, UInt32 *rgbImage, size_t width, size_t height);

typedef union _ColorUnion {
    UInt32 color;
    struct {
        UInt8 alpha;
        UInt8 red;
        UInt8 green;
        UInt8 blue;
    };
} ColorUnion;

@implementation Wand

+ executeBlock:(WandBlock)block forImage:(UIImage*)sampleImage
{
    int m_width = sampleImage.size.width;
    int m_height = sampleImage.size.height;
    
    uint32_t *rgbImage = (uint32_t *) malloc(m_width * m_height * sizeof(uint32_t));
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(rgbImage, m_width, m_height, 8, m_width * 4, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipLast);
    CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
    CGContextSetShouldAntialias(context, NO);
    CGContextDrawImage(context, CGRectMake(0, 0, m_width, m_height), [sampleImage CGImage]);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    // now convert to grayscale
    uint8_t *m_imageData = (uint8_t *) malloc(m_width * m_height);
    
    block(m_imageData, rgbImage, m_width, m_height);
    
    free(rgbImage);
    
    // convert from a gray scale image back into a UIImage
    uint8_t *result = (uint8_t *) calloc(m_width * m_height *sizeof(uint32_t), 1);
    
    // process the image back to rgb
    for(int i = 0; i < m_height * m_width; i++) {
        result[i*4]=0;
        int val=m_imageData[i];
        result[i*4+1]=val;
        result[i*4+2]=val;
        result[i*4+3]=val;
    }
    
    // create a UIImage
    colorSpace = CGColorSpaceCreateDeviceRGB();
    context = CGBitmapContextCreate(result, m_width, m_height, 8, m_width * sizeof(uint32_t), colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipLast);
    CGImageRef image = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    UIImage *resultUIImage = [UIImage imageWithCGImage:image];
    CGImageRelease(image);
    
    free(m_imageData);
    
    // make sure the data will be released by giving it to an autoreleased NSData
    [NSData dataWithBytesNoCopy:result length:m_width * m_height];
    
    return resultUIImage;
}

+ (UIImage *) applyGrayScaleOnImage:(UIImage *)sampleImage
{
    UIImage *newImage = [Wand executeBlock:^(UInt8 *data, UInt32 *rgbImage, size_t width, size_t height) {
        for(int y = 0; y < height; y++) {
            for(int x = 0; x < width; x++) {
                NSInteger index = y*width+x;
                ColorUnion rgbPixel;
                rgbPixel.color = rgbImage[index];
                UInt8 gray = 0.299 * rgbPixel.red +
                             0.587 * rgbPixel.blue +
                             0.114 * rgbPixel.blue;
                data[index] = gray;
            }
        }
    } forImage:sampleImage];
    
    return newImage;
}

@end
