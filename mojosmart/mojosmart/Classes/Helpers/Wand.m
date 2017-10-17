//
//  Wand.m
//  mojosmart
//
//  Created by Luiz Peres on 2017-10-17.
//  Copyright © 2017 Luiz Peres. All rights reserved.
//

#import "Wand.h"

#define COLOR_WHITE 255
#define COLOR_BLACK 0

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
        for(int row = 0; row < height; row++) {
            for(int col = 0; col < width; col++) {
                NSInteger index = row * width + col;
                ColorUnion rgbPixel = (ColorUnion)rgbImage[index];
                UInt8 gray = 0.299 * rgbPixel.red +
                             0.587 * rgbPixel.blue +
                             0.114 * rgbPixel.blue;
                data[index] = gray;
            }
        }
    } forImage:sampleImage];
    
    return newImage;
}

+ (UIImage *) applyGaussianOnImage:(UIImage *)sampleImage
{
    UIImage *newImage = [Wand executeBlock:^(UInt8 *data, UInt32 *rgbImage, size_t width, size_t height) {
        for(int row = 1; row < height - 1; row++) {
            for(int col = 1; col < width - 1; col++) {
                ColorUnion m11 = (ColorUnion)rgbImage[((row - 1) * width) + (col - 1)];
                ColorUnion m12 = (ColorUnion)rgbImage[((row - 1) * width) + (col)];
                ColorUnion m13 = (ColorUnion)rgbImage[((row - 1) * width) + (col + 1)];
                ColorUnion m21 = (ColorUnion)rgbImage[(row * width) + (col - 1)];
                ColorUnion m22 = (ColorUnion)rgbImage[(row * width) + col];
                ColorUnion m23 = (ColorUnion)rgbImage[(row * width) + (col + 1)];
                ColorUnion m31 = (ColorUnion)rgbImage[((row + 1) * width) + (col - 1)];
                ColorUnion m32 = (ColorUnion)rgbImage[((row + 1) * width) + col];
                ColorUnion m33 = (ColorUnion)rgbImage[((row + 1) * width) + (col + 1)];
                
                int sum = 0;
                sum += m11.red + m13.red + m31.red + m33.red;
                sum += m12.red * 2 + m32.red * 2 + m21.red * 2 + m23.red * 2;
                sum += m22.red * 4;
                
                data[row * width + col] = sum/16;
            }
        }
    } forImage:sampleImage];
    
    return newImage;
}

+ (SobelObject *) applySobelOnImage:(UIImage *)sampleImage
{
    __block SobelInfo *info;
    UIImage *newImage = [Wand executeBlock:^(UInt8 *data, UInt32 *rgbImage, size_t width, size_t height) {
        info = (SobelInfo*) malloc(sizeof(SobelInfo) * width * height);
        for(int row = 1; row < height - 1; row++) {
            for(int col = 1; col < width - 1; col++) {
                ColorUnion m11 = (ColorUnion)rgbImage[((row - 1) * width) + (col - 1)];
                ColorUnion m12 = (ColorUnion)rgbImage[((row - 1) * width) + (col)];
                ColorUnion m13 = (ColorUnion)rgbImage[((row - 1) * width) + (col + 1)];
                ColorUnion m21 = (ColorUnion)rgbImage[(row * width) + (col - 1)];
                //ColorUnion m22 = (ColorUnion)rgbImage[(row * width) + col];
                ColorUnion m23 = (ColorUnion)rgbImage[(row * width) + (col + 1)];
                ColorUnion m31 = (ColorUnion)rgbImage[((row + 1) * width) + (col - 1)];
                ColorUnion m32 = (ColorUnion)rgbImage[((row + 1) * width) + col];
                ColorUnion m33 = (ColorUnion)rgbImage[((row + 1) * width) + (col + 1)];
                
                int sumGY = 0;
                int sumGX = 0;
                
                sumGX += m11.red * -1;
                sumGX += m21.red * -2;
                sumGX += m31.red * -1;
                
                sumGX += m13.red;
                sumGX += m23.red * 2;
                sumGX += m33.red;
                
                sumGY += m11.red * -1;
                sumGY += m12.red * -2;
                sumGY += m13.red * -1;
                
                sumGY += m31.red;
                sumGY += m32.red * 2;
                sumGY += m33.red;
                
                NSInteger cur_rc = (row * width) + col;
                double gradient = sqrt(pow(sumGX, 2) + pow(sumGY, 2));
                data[cur_rc] = gradient;

                double atanGYGX = sumGX ? atan(sumGY/sumGX) : atan(sumGY);
                atanGYGX = atanGYGX * 180.0 / M_PI;
                info[cur_rc].gradient  = gradient;
                info[cur_rc].direction = [Wand discretizeAngle:atanGYGX];
                info[cur_rc].is_using  = true;
                info[cur_rc].color     = 0;
            }
        }
    } forImage:sampleImage];
    
    SobelObject *sobelObj = [[SobelObject alloc] init];
    sobelObj.image = newImage;
    sobelObj.info = info;
    return sobelObj;
}

+ (int) discretizeAngle:(double) angle
{
    int newAngle;
    if (angle >= -22.5 && angle < 22.5) { // [-pi/8,pi/8]
        newAngle = 0;
    } else if (angle >= 22.5 && angle < 67.5) { // [pi/8, 3pi/8]
        newAngle = 45;
    } else if (angle >= -67.5 && angle < -22.5) { // [-3pi/8,-pi/8]
        newAngle = 135;
    } else {
        newAngle = 90;
    }
    
    return newAngle;
}

+ (UIImage *) applyCannyOnSobelObj:(SobelObject *)sobelObj withMax:(NSInteger)max andMinTrashold:(NSInteger)min
{
    UIImage *newImage = [Wand executeBlock:^(UInt8 *data, UInt32 *rgbImage, size_t width, size_t height) {
        for(int row = 1; row < height - 1; row++) {
            for(int col = 1; col < width - 1; col++) {
                NSInteger m11 = ((row - 1) * width) + (col - 1);
                NSInteger m12 = ((row - 1) * width) + col;
                NSInteger m13 = ((row - 1) * width) + (col + 1);
                NSInteger m21 = (row * width) + (col - 1);
                NSInteger m22 = (row * width) + col;
                NSInteger m23 = (row * width) + (col + 1);
                NSInteger m31 = ((row + 1) * width) + (col - 1);
                NSInteger m32 = ((row + 1) * width) + col;
                NSInteger m33 = ((row + 1) * width) + (col + 1);

                UInt8 naughtValue = COLOR_BLACK;
                UInt8 strongValue = COLOR_WHITE;
                if (sobelObj.info[m22].direction == 0) { // [-pi/8,pi/8]
                    if (sobelObj.info[m22].gradient <= sobelObj.info[m12].gradient || sobelObj.info[m22].gradient <= sobelObj.info[m32].gradient) {
                        sobelObj.info[m22].color = naughtValue;
                    }
                } else if (sobelObj.info[m22].direction == 45) { // [pi/8, 3pi/8]
                    if (sobelObj.info[m22].gradient <= sobelObj.info[m13].gradient || sobelObj.info[m22].gradient <= sobelObj.info[m31].gradient) {
                        sobelObj.info[m22].color = naughtValue;
                    }
                } else if (sobelObj.info[m22].direction == 135) { // [-3pi/8,-pi/8]
                    if (sobelObj.info[m22].gradient <= sobelObj.info[m11].gradient || sobelObj.info[m22].gradient <= sobelObj.info[m33].gradient) {
                        sobelObj.info[m22].color = naughtValue;
                    }
                } else {
                    if (sobelObj.info[m22].gradient <= sobelObj.info[m23].gradient || sobelObj.info[m22].gradient <= sobelObj.info[m21].gradient) {
                        sobelObj.info[m22].color = naughtValue;
                    }
                }
                
                // Double Threshold
                if (sobelObj.info[m22].gradient > max) {
                    sobelObj.info[m22].color = strongValue;
                } else if (sobelObj.info[m22].gradient > min &&
                           (sobelObj.info[m21].color == strongValue ||
                            sobelObj.info[m12].color == strongValue ||
                            sobelObj.info[m11].color == strongValue)) {
                               sobelObj.info[m22].color = strongValue;
                } else {
                    sobelObj.info[m22].color = naughtValue;
                }
                
                char new_color = sobelObj.info[m22].color;
                data[row * width + col] = new_color;
            }
        }
    } forImage:sobelObj.image];
    
    return newImage;
}

@end
