//
//  ListItem.m
//  POHorizontalList
//
//  Created by Polat Olu on 15/02/2013.
//  Copyright (c) 2013 Polat Olu. All rights reserved.
//

#import "ListItem.h"

@implementation ListItem

- (id)initWithFrame:(CGRect)frame image:(UIImage *)image text:(NSString *)imageTitle
               text:(NSString *)Product_id
{
    self = [super initWithFrame:frame];
    
    if (self) {
        [self setUserInteractionEnabled:YES];
        
        self.imageTitle = imageTitle;
        self.image = image;
        self.Product_id = Product_id;
        // UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        
                
        UILabel *title = [[UILabel alloc] init];
        [title setBackgroundColor:[UIColor whiteColor]];
        [title setFont:[UIFont boldSystemFontOfSize:12.0]];
        [title setOpaque: NO];
        [title setText:imageTitle];
        
        imageRect = CGRectMake(0.0, 0.0, 72.0, 72.0);
        textRect = CGRectMake(0.0, imageRect.origin.y + imageRect.size.height + 10.0, 80.0, 20.0);
        
        
        UIImageView *imageView = [[UIImageView alloc] init];
        [imageView setFrame:imageRect];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        UIImage *image1 = self.image;
        const float colorMasking[6] = {255, 255, 255, 255, 255, 255};
        imageView.image = [UIImage imageWithCGImage: CGImageCreateWithMaskingColors(image1.CGImage, colorMasking)];
        
        CALayer *roundCorner = [imageView layer];
        [roundCorner setMasksToBounds:YES];
        [roundCorner setCornerRadius:8.0];
        [roundCorner setBorderColor:[UIColor whiteColor].CGColor];
        [roundCorner setBorderWidth:1.0];

        
        [title setFrame:textRect];
        
        
        [self addSubview:title];
        [self addSubview:imageView];
    }
    
    return self;
}

@end
