//
//  MEVHorizontalContactsModel.m
//  People Tracker
//
//  https://github.com/manuelescrig/MEVHorizontalContacts
//
//  Created by Manuel Escrig Ventura on 24/02/16.
//  Copyright (c) 2016 Manuel Escrig Ventura. All rights reserved.
//  Licence: MIT-Licence
//

#import "MEVHorizontalContacts.h"

static float const kMEVHorizontalContactsDefaultLabelHeight = 30.0f;
static float const kMEVHorizontalContactsDefaultSpacing = 5.0f;

static NSString *const kMEVHorizontalContactsContactCell = @"contactCell";
static NSString *const kMEVHorizontalContactsOptionCell = @"optionCell";

@interface MEVHorizontalContacts()  <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, MEVHorizontalContactsCellDelegate, MEVHorizontalContactsCellDataSource, MEVHorizontalContactsLayoutDataSource>

@property (nonatomic, strong) UICollectionView *horizontalContactListView;
@property (nonatomic, strong) MEVHorizontalContactsLayout *layout;
@property (nonatomic, assign) NSInteger selectedIndex;

@end

@implementation MEVHorizontalContacts


#pragma mark - View Life Cycle (private)

- (id)init
{
    self = [super init];
    if (self) {
        [self setupView];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
        [self setupView];
    }
    return self;
}

- (void)setupView
{
    [self setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self setOpaque:YES];
    
    _selectedIndex = -1;
    
    // Contact List
    _layout = [[MEVHorizontalContactsLayout alloc] init];
    _layout.dataSource = self;
    _horizontalContactListView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame)) collectionViewLayout:_layout];
    [_horizontalContactListView registerClass:[MEVHorizontalContactsCell class] forCellWithReuseIdentifier:kMEVHorizontalContactsContactCell];
    [_horizontalContactListView registerClass:[MEVHorizontalContactsCell class] forCellWithReuseIdentifier:kMEVHorizontalContactsOptionCell];
    [_horizontalContactListView setDataSource:self];
    [_horizontalContactListView setDelegate:self];
    [_horizontalContactListView setOpaque:YES];
    [_horizontalContactListView setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
    [_horizontalContactListView setAlwaysBounceHorizontal:YES];
    [_horizontalContactListView setShowsVerticalScrollIndicator:NO];
    [_horizontalContactListView setShowsHorizontalScrollIndicator:NO];
    [_horizontalContactListView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self addSubview:_horizontalContactListView];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[horizontalContactsView]|" options:NSLayoutFormatAlignAllCenterX metrics:nil views:@{@"horizontalContactsView" : _horizontalContactListView}]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[horizontalContactsView]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:@{@"horizontalContactsView" : _horizontalContactListView}]];
}


#pragma mark - Layout (private)

- (void)layoutSubviews
{    
    if ([_dataSource respondsToSelector:@selector(horizontalContactsSpacing)]) {
        _layout.itemSpacing =  [_dataSource horizontalContactsSpacing];
    } else {
        _layout.itemSpacing = kMEVHorizontalContactsDefaultSpacing;
    }
    
    UIEdgeInsets insets;
    if ([_dataSource respondsToSelector:@selector(horizontalContactsInsets)]) {
        insets =  [_dataSource horizontalContactsInsets];
    }
    
    _layout.insets = insets;
    _layout.itemHeight = CGRectGetHeight(self.frame) - insets.top - insets.bottom;
    _layout.labelHeight = kMEVHorizontalContactsDefaultLabelHeight;
}


#pragma mark - UICollectionView Datasource (private)

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if ([_dataSource respondsToSelector:@selector(numberOfContacts)]) {
        return [_dataSource numberOfContacts];
    }
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([_dataSource respondsToSelector:@selector(contactAtIndex:)]) {
        MEVHorizontalContactsCell *cell = [_dataSource contactAtIndex:indexPath.row];
        cell.labelHeight = kMEVHorizontalContactsDefaultLabelHeight;
        cell.indexPath = indexPath;
        cell.delegate = self;
        cell.dataSource = self;
        
        if ([_dataSource respondsToSelector:@selector(horizontalContactsSpacing)]) {
            cell.itemSpacing =  [_dataSource horizontalContactsSpacing];
        } else {
            cell.itemSpacing = kMEVHorizontalContactsDefaultSpacing;
        }
        
        if (indexPath.row == _selectedIndex) {
            cell.selected = YES;
            [cell showMenuOptionsAnimated:NO];
        } else {
            cell.selected = NO;
            [cell hideMenuOptionsAnimated:NO];
        }
    
        return cell;
    } else {
        MEVHorizontalContactsCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellIdentifier" forIndexPath:indexPath];
        return cell;
    }
}

#pragma mark - ReusableCells Methods (public)

- (MEVHorizontalContactsCell *)dequeueReusableContactCellForIndex:(NSInteger)index
{
   return [_horizontalContactListView dequeueReusableCellWithReuseIdentifier:kMEVHorizontalContactsContactCell forIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
}

- (MEVHorizontalContactsCell *)dequeueReusableOptionCellForIndex:(NSInteger)index
{
    return [_horizontalContactListView dequeueReusableCellWithReuseIdentifier:kMEVHorizontalContactsOptionCell forIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
}


#pragma mark – MEVHorizontalContactsLayoutDataSource
#pragma mark – MEVHorizontalContactsCellDataSource 

- (NSInteger)numberOfOptionsInCellIndexPath:(NSIndexPath *)indexPath
{
    if ([_dataSource respondsToSelector:@selector(numberOfOptionsAtContactIndex:)]) {
        return [_dataSource numberOfOptionsAtContactIndex:indexPath.row];
    }
    return 0;
}


#pragma mark – MEVHorizontalContactsCellDataSource

- (MEVHorizontalContactsCell *)option:(NSInteger)option atContactIndex:(NSInteger)index
{
    if ([_dataSource respondsToSelector:@selector(option:atContactIndex:)]) {
        return [_dataSource option:option atContactIndex:index];
    }
}


#pragma mark – MEVHorizontalContactListCellDelegate

- (void)cellSelectedAtIndexPath:(NSIndexPath *)indexPath
{
    // Deselect old cell
    if (_selectedIndex >= 0 && _selectedIndex != indexPath.row) {
        
        // Deselect old cell
        MEVHorizontalContactsCell *cell = [_horizontalContactListView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:_selectedIndex inSection:0]];
        cell.selected = NO;
        [cell hideMenuOptionsAnimated:YES];
        
    }
    
    // Select new cell, in case of deselecting then set -1 as default value
    _selectedIndex = _selectedIndex == indexPath.row ? -1 : indexPath.row;

    [_horizontalContactListView setContentOffset:CGPointMake(indexPath.row  * (_layout.itemHeight -_layout.labelHeight  + _layout.itemSpacing), 0) animated:YES];
    [_horizontalContactListView performBatchUpdates:^{ } completion:^(BOOL finished) { }];
    [_horizontalContactListView invalidateIntrinsicContentSize];
    
    if ([_delegate respondsToSelector:@selector(contactSelectedAtIndex:)]) {
        return [_delegate contactSelectedAtIndex:indexPath.row];
    }
}

- (void)menuOptionSelected:(NSInteger)option atCellIndexPath:(NSIndexPath *)indexPath
{
    if ([_delegate respondsToSelector:@selector(option:selectedAtContactIndex:)]) {
        return [_delegate option:option selectedAtContactIndex:indexPath.row];
    }
}

@end
