//
//  UITableView+Autolayout.h
//
//
//  Created by Ilya Puchka on 19.08.14.
//  Copyright (c) 2014 Ilya Puchka. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITableView (Autolayout)

- (CGFloat)cool_heightForCellWithReuseIdentifier:(NSString *)reuseId
                                  indexPath:(NSIndexPath *)indexPath
         withConfigurationBlock:(void(^)(id cell, NSIndexPath *indexPath))block;


//cleared cached heights
- (void)cool_invalidateHeightsForCellsAtIndexPaths:(NSArray *)indexPaths;
- (void)cool_invalidateHeights;

@end
