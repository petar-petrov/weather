//
//  MMCollectionViewFlowLayout.m
//  weather
//
//  Created by Petar Petrov on 09/02/2016.
//  Copyright © 2016 Petar Petrov. All rights reserved.
//

#import "MMCollectionViewFlowLayout.h"

@interface MMCollectionViewFlowLayout ()

@property (assign, nonatomic) NSInteger cellCount;

@end

@implementation MMCollectionViewFlowLayout

- (instancetype)init {
    self = [super init];
    
    if (self) {
//        self.itemSize = CGSizeMake(100.0f, self.collectionView.bounds.size.height);
//        self.sectionInset = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
//        self.minimumInteritemSpacing = 10.0f;
//        self.minimumLineSpacing = 0.0f;
    }
    
    return self;
}

- (void)prepareLayout {
    [super prepareLayout];
    
    self.cellCount = [self.collectionView numberOfItemsInSection:0];
    
    
}

- (CGSize)collectionViewContentSize {
    CGFloat width = self.cellCount * self.itemSize.width + (self.cellCount * self.minimumInteritemSpacing - self.minimumInteritemSpacing);
    
    return CGSizeMake(width, self.collectionView.bounds.size.height);
}



- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    
    attributes.size = self.itemSize;
    
    attributes.center = CGPointMake((indexPath.row * self.itemSize.width) + self.itemSize.width / 2.0f + (indexPath.row * self.minimumInteritemSpacing),self.collectionView.bounds.size.height / 2.0f);
    
    return attributes;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    
    NSMutableArray *attributes = [NSMutableArray array];
    
    for (NSInteger i = 0; i < self.cellCount; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
        [attributes addObject:[self layoutAttributesForItemAtIndexPath:indexPath]];
    }
    
    return attributes;
}

@end
