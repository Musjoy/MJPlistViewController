//
//  MJPlistViewController.m
//  Common
//
//  Created by 黄磊 on 16/4/6.
//  Copyright © 2016年 Musjoy. All rights reserved.
//

#import "MJPlistViewController.h"

#ifdef MODULE_FILE_SOURCE
#import "FileSource.h"
#endif

#ifdef MODULE_CONTROLLER_MANAGER
#import "MJNavigationController.h"
#import "MJControllerManager.h"
#endif


#define DEFAULT_SECTION_HEADER_HEIGHT 30
#define DEFAULT_SECTION_FOOTER_HEIGHT 0
#define DEFAULT_LINE_LEFT_PADDING 15

#pragma mark - Addition

// 以下是在未导入MJUtils模块时的兼容方法

#ifndef MODULE_UTILS

@interface UITableViewCell (PlistVC_Utils)
/** 通用cell初始化方法 */
+ (nonnull instancetype)cellWithStyle:(UITableViewCellStyle)style reuseIdentifier:(nullable NSString *)reuseIdentifier;
- (void)configWithData:(nullable id)data andAttach:(nullable id)attachData;
- (void)configWithData:(nullable id)data;
@end

@implementation UITableViewCell (PlistVC_Utils)

+ (__kindof UITableViewCell *)cellWithStyle:(UITableViewCellStyle)style reuseIdentifier:(nullable NSString *)reuseIdentifier
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:NSStringFromClass([self class]) ofType:@"nib"];
    UITableViewCell *cell = nil;
    if (filePath.length > 0) {
        cell = [self viewFromNib];
        if (cell == nil) {
            cell = [[self alloc] init];
        }
    } else {
        cell = [[super alloc] initWithStyle:style reuseIdentifier:reuseIdentifier];
    }
#ifdef MODULE_THEME_MANAGER
    [cell reloadTheme];
#endif
    return cell;
}

- (void)configWithData:(id)data
{
    // need be overwrite
}

- (void)configWithData:(id)data andAttach:(id)attachData
{
    [self configWithData:data];
}

@end

@interface UIViewController (PlistVC_Utils)
- (void)configWithData:(id)data;
@end

@implementation UIViewController (PlistVC_Utils)
- (void)configWithData:(id)data
{
    
}
@end

#endif

#pragma mark -

#ifdef MODULE_UTILS
#import "Utils.h"
@interface MJPlistViewController ()<TableViewCellDelegate>
#else
@interface MJPlistViewController ()
#endif

@property (nonatomic, strong) NSMutableArray *arrViewHeaders;

@end

@implementation MJPlistViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
        
    if (self.navTitle.length > 0) {
        self.navigationItem.title = self.navTitle;
    }
    
    [self _viewConfig];
    [self _dataConfig];
}

- (void)_viewConfig
{
    // 初始化tableview
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        [_tableView setBackgroundColor:[UIColor clearColor]];
        [_tableView setDataSource:self];
        [_tableView setDelegate:self];
//        [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        [self.view addSubview:_tableView];
#ifdef MODULE_THEME_MANAGER
        [_tableView setSeparatorColor:[MJThemeManager colorFor:kThemeCellLineColor]];
#endif
        if (self.view.subviews.count > 1) {
            if (__CUR_IOS_VERSION >= __IPHONE_7_0) {
                // 界面调整
                CGFloat top = 0;
                CGFloat bottom = 0;
                if (!self.navigationController.navigationBarHidden) {
                    top += 44;
                }
                if (![[UIApplication sharedApplication] isStatusBarHidden]) {
                    top += 20;
                }
                
                if (!self.hidesBottomBarWhenPushed) {
                    bottom += 49;
                }
                
                CGRect frame = _tableView.frame;
                frame.origin.y = top;
                frame.size.height -= top + bottom;
                [_tableView setFrame:frame];
            }

        }
        [_tableView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    }
    _tableView.tableFooterView = [[UIView alloc] init];
    if (_lineLeftPadding == 0) {
        _lineLeftPadding = DEFAULT_LINE_LEFT_PADDING;
    }
    [_tableView setSeparatorInset:UIEdgeInsetsMake(0, _lineLeftPadding, 0, 0)];
}

- (void)_dataConfig
{
    _dicAttachments = [[NSMutableDictionary alloc] init];
    _arrViewHeaders = [[NSMutableArray alloc] init];
    
    if (_fileName.length == 0) {
        LogError(@"Can not init this view controller, while fileName is nil");
        _arrItems = [[NSMutableArray alloc] init];
        return;
    }
    
    NSArray *arr = getFileData(_fileName);
    self.arrItems = [arr mutableCopy];

//    [_tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Public

- (void)deleteGroup:(NSString *)groupKey
{
    if (_arrItems.count == 0) {
        return;
    }
    if (!groupKey && groupKey.length == 0) {
        return;
    }
    for (NSInteger i=0, len=_arrItems.count; i<len; i++) {
        NSDictionary *aDic = _arrItems[i];
        NSString *aGroupKey = aDic[@"groupKey"];
        if (aGroupKey && aGroupKey.length > 0 && [aGroupKey isEqualToString:groupKey]) {
            [_arrItems removeObject:aDic];
            if (_arrViewHeaders.count > i) {
                [_arrViewHeaders removeObjectAtIndex:i];
            }
            break;
        }
    }
}

- (void)deleteCell:(NSString *)cellKey Group:(NSString *)groupKey
{
    if (_arrItems.count == 0) {
        return;
    }
    if (!groupKey && groupKey.length == 0) {
        return;
    }
    if (!cellKey && cellKey.length == 0) {
        return;
    }
    for (NSInteger i=0, len=_arrItems.count; i<len; i++) {
        NSDictionary *aDic = _arrItems[i];
        NSString *aGroupKey = aDic[@"groupKey"];
        if (aGroupKey && aGroupKey.length > 0 && [aGroupKey isEqualToString:groupKey]) {
            NSMutableArray *arrItems = aDic[@"itemList"];
            for (NSInteger j=0, len1=arrItems.count; j<len1; j++) {
                NSDictionary *aDicCell = arrItems[j];
                NSString *aKeyForCell = aDicCell[@"keyForCell"];
                if (aKeyForCell && aKeyForCell.length > 0 && [aKeyForCell isEqualToString:cellKey]) {
                    [arrItems removeObject:aDicCell];
                    if (arrItems.count == 0) {
                        [_arrItems removeObject:aDic];
                        [_arrViewHeaders removeObjectAtIndex:j];
                    }
                    break;
                }
            }
            break;
        }
    }
}


- (NSIndexPath *)indexPathForCellKey:(NSString *)cellKey
{
    for (NSInteger i=0, len=_arrItems.count; i<len; i++) {
        NSDictionary *aDic = _arrItems[i];
        NSMutableArray *arrItems = aDic[@"itemList"];
        for (NSInteger j=0, len1=arrItems.count; j<len1; j++) {
            NSDictionary *aDicCell = arrItems[j];
            NSString *aKeyForCell = aDicCell[@"keyForCell"];
            if (aKeyForCell && aKeyForCell.length > 0 && [aKeyForCell isEqualToString:cellKey]) {
                NSIndexPath *aIndexPath = [NSIndexPath indexPathForRow:j inSection:i];
                return aIndexPath;
            }
        }
    }
    return nil;
}


#pragma mark - Private

- (NSString *)filePathWithFileName:(NSString *)aFileName
{
    NSString *fileDir = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Plists"];
    NSString *fullName = [aFileName stringByAppendingString:@".plist"];
    NSString *filePath = [fileDir stringByAppendingPathComponent:fullName];
    return filePath;
}

- (void)storeHeaderView:(UIView *)aHeaderView inSection:(NSInteger)section
{
    if (_arrViewHeaders.count > section) {
//        [_arrViewHeaders replaceObjectAtIndex:section withObject:aHeaderView];
    } else if (_arrViewHeaders.count == section) {
        [_arrViewHeaders addObject:aHeaderView];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Need Overwrite

/** 重写改方法来实现对section高度的自定义 */
- (CGFloat)heightForHeaderInSection:(NSInteger)section
{
    return 0;
}

/** 重写改方法来实现对section view的自定义 */
- (UIView *)viewForHeaderInSection:(NSInteger)section
{
    if (_arrViewHeaders.count > section) {
        return _arrViewHeaders[section];
    }
    return nil;
}

/** 重写改方法来实现对section footer高度的自定义 */
- (CGFloat)heightForFooterInSection:(NSInteger)section
{
    return 0;
}

/** 重写改方法来实现对section footerView的自定义 */
- (UIView *)viewForFooterInSection:(NSInteger)section
{
    return nil;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [_arrItems count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [[[_arrItems objectAtIndex:section] objectForKey:@"itemList"] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    CGFloat headerHeight = [self heightForHeaderInSection:section];
    
    NSDictionary *aDic = [_arrItems objectAtIndex:section];
    NSNumber *aHeight = [aDic objectForKey:@"headerHeight"];
    
    if (aHeight) {
        headerHeight = [aHeight floatValue];
    }
    
    if (headerHeight < 1) {
        headerHeight = DEFAULT_SECTION_HEADER_HEIGHT;
    }

    return headerHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *aViewHeader = [self viewForHeaderInSection:section];
    if (aViewHeader) {
        [self storeHeaderView:aViewHeader inSection:section];
        return aViewHeader;
    }
    
    NSDictionary *aDic = [_arrItems objectAtIndex:section];
    NSString *sectionTitle = [aDic objectForKey:@"groupTitle"];
    float aHeight = [self tableView:_tableView heightForHeaderInSection:section];
    
    if (sectionTitle.length == 0) {
        return nil;
    }
    
    CGRect rect = CGRectMake(0, 0, tableView.frame.size.width, aHeight);
    UIView *viewHeader = [[UIView alloc] initWithFrame:rect];
    viewHeader.backgroundColor = _headerBgColor?:[UIColor whiteColor];
    if (sectionTitle && aHeight) {
        // Create label with section title
        UILabel *label = [[UILabel alloc] init];
        UIFont *font = [UIFont boldSystemFontOfSize:18];
        rect.origin.x = 12;
        rect.size.width -= 2*12;
        label.frame = rect;
        label.backgroundColor = [UIColor clearColor];
        label.textColor = _headerTextColor?:[UIColor blackColor];
        label.font = font;
        label.numberOfLines = 0;
        label.text = sectionTitle;
        
        [viewHeader addSubview:label];
    }
    [self storeHeaderView:viewHeader inSection:section];
    return viewHeader;
}


- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    CGFloat headerHeight = [self heightForFooterInSection:section];
    if (headerHeight < 1) {
        headerHeight = DEFAULT_SECTION_FOOTER_HEIGHT;
    }
    
    NSDictionary *aDic = [_arrItems objectAtIndex:section];
    NSString *groupFooter = [aDic objectForKey:@"groupFooter"];
    
    if (groupFooter) {
        UIFont *font = [UIFont boldSystemFontOfSize:14];
        CGSize aSize = multilineTextSize(groupFooter, font, CGSizeMake(kScreenWidth-2*_lineLeftPadding, 1000));
        headerHeight = aSize.height + 10;
    }
    
    return headerHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *aViewFooter = [self viewForFooterInSection:section];
    if (aViewFooter) {
        return aViewFooter;
    }
    
    NSDictionary *aDic = [_arrItems objectAtIndex:section];
    NSString *groupFooter = [aDic objectForKey:@"groupFooter"];
    float aHeight = 10;
    
    CGRect rect = CGRectMake(0, 0, tableView.frame.size.width, aHeight);
    UIView *viewHeader = [[UIView alloc] initWithFrame:rect];
    viewHeader.backgroundColor = _footerBgColor?:[UIColor clearColor];
    if (groupFooter && aHeight) {
        // Create label with section title
        UILabel *label = [[UILabel alloc] init];
        UIFont *font = [UIFont systemFontOfSize:14];
        rect.origin.x = _lineLeftPadding;
        rect.size.width = kScreenWidth-2*_lineLeftPadding;
        label.frame = rect;
        label.backgroundColor = [UIColor clearColor];
        label.textColor = _footerTextColor?:[UIColor lightGrayColor];
        label.font = font;
        label.numberOfLines = 0;
        label.text = groupFooter;
        [viewHeader addSubview:label];
        
        [label setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    } else {
        viewHeader = nil;
    }
    return viewHeader;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dic = [[[_arrItems objectAtIndex:indexPath.section] objectForKey:@"itemList"] objectAtIndex:indexPath.row];
    CGFloat aHeight = [[dic objectForKey:@"cellHeight"] floatValue];
    return aHeight;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *aDic = [self dicForIndexPath:indexPath];   //  当前cell对应的内容dic
    NSString *identifier = [aDic objectForKey:@"cellIdentifier"];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        NSString *cellClass = [aDic objectForKey:@"cellClass"];
        cell = [NSClassFromString(cellClass) cellWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
#ifndef MODULE_THEME_MANAGER
        if (_cellColor) {
            [cell setBackgroundColor:_cellColor];
        }
        if (_cellTintColor) {
            [cell setTintColor:_cellTintColor];
            [cell.textLabel setTextColor:_cellTintColor];
        }
        if (_cellSelectBgColor) {
            UIView *viewBg = [[UIView alloc] initWithFrame:cell.bounds];
            [viewBg setBackgroundColor:_cellSelectBgColor];
            [cell setSelectedBackgroundView:viewBg];
        }
#endif
        if ([cell respondsToSelector:@selector(setDelegate:)]) {
#ifdef MODULE_UTILS
            [cell setDelegate:self];
#endif
        }
    }
    // Configure the cell...
    
    NSMutableDictionary *dicForCell = [aDic mutableCopy];  // 内容
    
    NSString *keyForCell = [aDic objectForKey:@"keyForCell"];
    
    id attachData = nil;
    if (keyForCell.length > 0) {
        attachData = _dicAttachments[keyForCell];
    }
    
//    if (attachData) {
        [cell configWithData:dicForCell andAttach:attachData];
//    } else {
//        [cell configWithData:dicForCell];
//    }
    
    return cell;
}


#pragma mark -Subjoin

- (NSDictionary *)dicForIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dic = [[[_arrItems objectAtIndex:indexPath.section] objectForKey:@"itemList"] objectAtIndex:indexPath.row];
    return dic;
}


#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Create the next view controller.
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *aDic = [self dicForIndexPath:indexPath];
    NSString *pushClass = [aDic objectForKey:@"pushClass"];
    NSString *strAction = [aDic objectForKey:@"action"];

    if (pushClass.length > 0 && NSClassFromString(pushClass)) {
#ifdef MODULE_CONTROLLER_MANAGER
        UIViewController *pushVC = [MJControllerManager getViewControllerWithName:pushClass];
#else
        UIViewController *pushVC = [self getViewControllerWithName:pushClass];
#endif
        if (pushVC) {
            id data = [aDic objectForKey:@"pushData"];
            if (data) {
                [pushVC configWithData:data];
            }
            NSNumber *usePresent = aDic[@"usePresent"];
            if (usePresent && [usePresent boolValue]) {
#ifdef MODULE_CONTROLLER_MANAGER
                MJNavigationController *aNavVC = [[MJNavigationController alloc] initWithRootViewController:pushVC];
#else
                UINavigationController *aNavVC = [[UINavigationController alloc] initWithRootViewController:pushVC];
#endif
                [self presentViewController:aNavVC animated:YES completion:NULL];
            } else {
                UINavigationController *theNavVC = (UINavigationController *)self.navigationController;
                // Push the view controller.
                [theNavVC pushViewController:pushVC animated:YES];
            }
            return;
        }
    }
    if (strAction.length > 0) {
        SEL action = NSSelectorFromString(strAction);
        if ([self respondsToSelector:action]) {
            if ([strAction hasSuffix:@":"]) {
                IMP imp = [self methodForSelector:action];
                void (*func)(id, SEL, id) = (void *)imp;
                func(self, action, aDic);
            } else {
                IMP imp = [self methodForSelector:action];
                void (*func)(id, SEL) = (void *)imp;
                func(self, action);
            }
        }
        
    }
}



#pragma mark -Subjoin

#ifndef MODULE_CONTROLLER_MANAGER

- (UIViewController *)getViewControllerWithName:(NSString *)aVCName
{
    if (aVCName.length == 0) {
        return nil;
    }
    Class classVC = NSClassFromString(aVCName);
    if (classVC) {
        // 存在该类
        NSString *filePath = [[NSBundle mainBundle] pathForResource:aVCName ofType:@"nib"];
        UIViewController *aVC = nil;
        if (filePath.length > 0) {
            aVC = [[classVC alloc] initWithNibName:aVCName bundle:nil];
        } else {
            aVC = [[classVC alloc] init];
        }
    }
    
    return nil;
}
#endif

@end



