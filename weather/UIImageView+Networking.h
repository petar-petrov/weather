//
//  UIImageView+Networking.h
//
//  Created by Petar Petrov on 04/05/2014.
//  Copyright (c) 2014 Petar Petrov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (Networking)

- (void)setImageWithURLString:(NSString * _Nullable)urlString placeholder:(UIImage * _Nullable)placeholderImage;

@end
