//
//  UIImageView+Networking.m
//
//  Created by Petar Petrov on 04/05/2014.
//  Copyright (c) 2014 Petar Petrov. All rights reserved.
//

#import "UIImageView+Networking.h"

@implementation UIImageView (Networking)

- (void)setImageWithURLString:(NSString *)urlString placeholder:(UIImage *)placeholderImage
{
    self.image = placeholderImage;
    
    if (urlString) {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        configuration.requestCachePolicy = NSURLRequestReturnCacheDataElseLoad;
        
        NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
        
        NSURL *imageUrl = [NSURL URLWithString:urlString];
        
        [[session dataTaskWithURL:imageUrl
                completionHandler:^(NSData *data,
                                    NSURLResponse *response,
                                    NSError *error) {
                    UIImage *image = [UIImage imageWithData:data];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (image)
                            self.image = image;
                    });
                }] resume];
    }
}

@end
