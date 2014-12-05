//
//  UITableView+Autolayout.m
//
//
//  Created by Ilya Puchka on 19.08.14.
//  Copyright (c) 2014 Ilya Puchka. All rights reserved.
//

#import "UITableView+Autolayout.h"
#import <objc/runtime.h>

@implementation UITableView (Autolayout)

static const void *COOLCachedHeightsKey = &COOLCachedHeightsKey;
static const void *COOLPrototypesKey = &COOLPrototypesKey;

static NSMutableDictionary *prototypes = nil;

- (UITableViewCell *)_prototypeCellForWithReuseIdentifier:(NSString *)reuseId
{
    UITableViewCell *cell = [self _prototypes][reuseId];
    return cell;
}

- (UITableViewCell *)_registerPrototypeForCellWithReuseIdentifier:(NSString *)reuseId
{
    UITableViewCell *prototypeCell = [self dequeueReusableCellWithIdentifier:reuseId];
    if (prototypeCell) {
        [self _prototypes][reuseId] = prototypeCell;
    }
    return prototypeCell;
}

- (NSMutableDictionary *)_prototypes
{
    NSMutableDictionary *_prototypes = objc_getAssociatedObject(self, @selector(_prototypes));
    if (!_prototypes) {
        _prototypes = [@{} mutableCopy];
        objc_setAssociatedObject(self, @selector(_prototypes), _prototypes, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return _prototypes;
}

- (void)cool_invalidateHeightsForCellsAtIndexPaths:(NSArray *)indexPaths
{
    [indexPaths enumerateObjectsUsingBlock:^(NSIndexPath *indexPath, NSUInteger idx, BOOL *stop) {
        [[self _cachedHeights] removeObjectForKey:indexPath];
    }];
}

- (void)cool_invalidateHeights
{
    [[self _cachedHeights] removeAllObjects];
}

- (void)_setHeight:(CGFloat)height forIndexPath:(NSIndexPath *)indexPath
{
    NSMutableDictionary *cachedHeight = [self _cachedHeights];
    cachedHeight[indexPath] = @(height);
}

- (id)_heightForIndexPath:(NSIndexPath *)indexPath
{
    return [self _cachedHeights][indexPath];
}

- (NSMutableDictionary *)_cachedHeights
{
    NSMutableDictionary *_cachedHeights = objc_getAssociatedObject(self, @selector(_cachedHeights));
    if (!_cachedHeights) {
        _cachedHeights = [@{} mutableCopy];
        objc_setAssociatedObject(self, @selector(_cachedHeights), _cachedHeights, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return _cachedHeights;
}

- (CGFloat)cool_heightForCellWithReuseIdentifier:(NSString *)reuseId indexPath:(NSIndexPath *)indexPath withConfigurationBlock:(void (^)(id, NSIndexPath *))block
{
    if ([[[UIDevice currentDevice] systemVersion] compare:@"8" options:NSNumericSearch] != NSOrderedAscending) {
        return UITableViewAutomaticDimension;
    }

    NSIndexPath *_indexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section];
    
    NSNumber *height = [self _heightForIndexPath:_indexPath];
    if (height != nil) {
        return [height floatValue];
    }
    
    UITableViewCell *prototypeCell = [self _prototypeCellForWithReuseIdentifier:reuseId];
    if (!prototypeCell) {
        prototypeCell = [self _registerPrototypeForCellWithReuseIdentifier:reuseId];
    }

    if (block) block(prototypeCell, _indexPath);
    
    [prototypeCell setNeedsUpdateConstraints];
    [prototypeCell updateConstraintsIfNeeded];

    prototypeCell.bounds = CGRectMake(0, 0, CGRectGetWidth(self.bounds), CGRectGetHeight(prototypeCell.bounds));
    [prototypeCell setNeedsLayout];
    [prototypeCell layoutIfNeeded];
    
    CGFloat _height = [prototypeCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    _height = ceilf(_height) + 1;
    [self _setHeight:_height forIndexPath:_indexPath];
    return _height;
}

@end
