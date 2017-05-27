//
//  PlistViewController.h
//  Common
//
//  Created by 黄磊 on 16/4/6.
//  Copyright © 2016年 Musjoy. All rights reserved.
//

#import HEADER_BASE_VIEW_CONTROLLER

@interface MJPlistViewController : THEBaseViewController<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) IBOutlet UITableView *tableView;

// ========= 必填项 =========
@property (nonatomic, strong) NSString *fileName;                   ///< plist 文件名，必填

// ========= 可选配置 =========
@property (nonatomic, strong) NSString *navTitle;                   ///< 导航栏标题

@property (nonatomic, strong) UIColor *headerBgColor;               ///< headerView背景色，默认[UIColor whiteColor]
@property (nonatomic, strong) UIColor *headerTextColor;             ///< headerView字体颜色，默认[UIColor blackColor]
@property (nonatomic, strong) UIColor *footerBgColor;               ///< footerView背景色，默认[UIColor clearColor]
@property (nonatomic, strong) UIColor *footerTextColor;             ///< footerView字体颜色，默认[UIColor lightGrayColor]

@property (nonatomic, strong) UIColor *cellColor;                   ///< cell的默认颜色
@property (nonatomic, strong) UIColor *cellTintColor;               ///< cell的主色调
@property (nonatomic, strong) UIColor *cellSelectBgColor;           ///< cell选中之后的背景色

@property (nonatomic, assign) CGFloat lineLeftPadding;              ///< 分割线左边边距, 未知原因无效

// ========= 数据 =========
@property (nonatomic, strong) NSMutableArray *arrItems;             ///< 所有数据

@property (nonatomic, strong) NSMutableDictionary *dicAttachments;  ///< 该列表数据的附加数据，如cell的未读个数

#pragma mark - Public

- (void)deleteGroup:(NSString *)groupKey;

- (void)deleteCell:(NSString *)cellKey inGroup:(NSString *)groupKey;

- (NSIndexPath *)indexPathForCellKey:(NSString *)cellKey;

#pragma mark -

/** 重写改方法来实现对section高度的自定义 */
- (CGFloat)heightForHeaderInSection:(NSInteger)section;
/** 重写改方法来实现对section view的自定义 */
- (UIView *)viewForHeaderInSection:(NSInteger)section;

/** 重写改方法来实现对section footer高度的自定义 */
- (CGFloat)heightForFooterInSection:(NSInteger)section;
/** 重写改方法来实现对section footerView的自定义 */
- (UIView *)viewForFooterInSection:(NSInteger)section;


- (NSDictionary *)dicForIndexPath:(NSIndexPath *)indexPath;

@end
