//
//  KMAccordionTableViewController.m
//  KMAccordionTableView
//
//  Created by Klevison Matias on 5/1/14.
//
//

#import "KMAccordionTableViewController.h"

@interface KMAccordionTableViewController () <KMSectionHeaderViewDelegate>

@property(nonatomic) NSInteger openSectionIndex;

@end

@implementation KMAccordionTableViewController

static NSString *SectionHeaderViewIdentifier = @"SectionHeaderViewIdentifier";

- (void)viewDidLoad {
    [super viewDidLoad];
    self.openSectionIndex = NSNotFound;
    [self setupTableView];
}

#pragma mark - Class Methods

- (void)setupTableView {
    UINib *sectionHeaderNib = [UINib nibWithNibName:NSStringFromClass([KMSectionHeaderView class]) bundle:nil];
    [self.tableView registerNib:sectionHeaderNib forHeaderFooterViewReuseIdentifier:SectionHeaderViewIdentifier];
    [self.tableView setBounces:NO];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.dataSource numberOfSectionsInAccordionTableViewController:self];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    KMSection *currentSection = (self.sections)[section];
    return currentSection.open ? 1 : 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat heightForRowAtIndexPath = [self.dataSource accordionTableView:self heightForSectionAtIndex:indexPath.section];
    return heightForRowAtIndexPath;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *CellIdentifier = [NSString stringWithFormat:@"CellIdentifier%d", indexPath.section];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        KMSection *section = self.sections[indexPath.section];
        [cell.contentView addSubview:section.view];
        [cell.contentView setAutoresizesSubviews:NO];
        [cell.contentView setFrame:section.view.frame];
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return self.headerHeight;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    KMSectionHeaderView *sectionHeaderView = (KMSectionHeaderView*)[self.tableView dequeueReusableHeaderFooterViewWithIdentifier:SectionHeaderViewIdentifier];
    
    KMSection *currentSection = [self.dataSource accordionTableView:self sectionForRowAtIndex:section];
    currentSection.sectionIndex = section;
    
    currentSection.headerView = sectionHeaderView;
    
    sectionHeaderView.titleLabel.text = currentSection.title;
    [sectionHeaderView setSection:section];
    [sectionHeaderView setDelegate:self];
    [sectionHeaderView setHeaderArrowImageOpened:self.headerArrowImageOpened];
    [sectionHeaderView setHeaderArrowImageClosed:self.headerArrowImageClosed];
    [sectionHeaderView setHeaderFont:self.headerFont];
    [sectionHeaderView setHeaderTitleColor:self.headerTitleColor];
    [sectionHeaderView setHeaderSeparatorColor:self.headerSeparatorColor];
    [sectionHeaderView setHeaderColor:self.headerColor];
    if (currentSection.overHeaderView) {
        [sectionHeaderView addOverHeaderSubView:currentSection.overHeaderView];
    }
    
    return sectionHeaderView;
}

#pragma mark - SectionHeaderViewDelegate

- (void)sectionHeaderView:(KMSectionHeaderView *)sectionHeaderView sectionOpened:(NSInteger)sectionOpened {
    
    KMSection *section = (self.sections)[sectionOpened];
    
    section.open = YES;
    
    NSMutableArray *indexPathsToInsert = [[NSMutableArray alloc] init];
    [indexPathsToInsert addObject:[NSIndexPath indexPathForRow:0 inSection:sectionOpened]];
    
    NSMutableArray *indexPathsToDelete = [[NSMutableArray alloc] init];
    
    NSInteger previousOpenSectionIndex = self.openSectionIndex;
    
    if (previousOpenSectionIndex != NSNotFound) {
        KMSection *previousOpenSection = (self.sections)[previousOpenSectionIndex];
        previousOpenSection.open = NO;
        [previousOpenSection.headerView toggleOpenWithUserAction:NO];
        [indexPathsToDelete addObject:[NSIndexPath indexPathForRow:0 inSection:previousOpenSectionIndex]];
    }
    
    [self.tableView beginUpdates];
    [self.tableView insertRowsAtIndexPaths:indexPathsToInsert withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView deleteRowsAtIndexPaths:indexPathsToDelete withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
    
    CGRect sectionRect = [self.tableView rectForSection:sectionOpened];
    [self.tableView scrollRectToVisible:sectionRect animated:YES];
    
    self.openSectionIndex = sectionOpened;
    
}

- (void)sectionHeaderView:(KMSectionHeaderView *)sectionHeaderView sectionClosed:(NSInteger)sectionClosed {
    
    KMSection *currentSection = (self.sections)[sectionClosed];
    
    currentSection.open = NO;
    NSInteger countOfRowsToDelete = [self.tableView numberOfRowsInSection:sectionClosed];
    
    if (countOfRowsToDelete > 0) {
        NSMutableArray *indexPathsToDelete = [[NSMutableArray alloc] init];
        [indexPathsToDelete addObject:[NSIndexPath indexPathForRow:0 inSection:sectionClosed]];
        [self.tableView deleteRowsAtIndexPaths:indexPathsToDelete withRowAnimation:UITableViewRowAnimationFade];
    }
    self.openSectionIndex = NSNotFound;
    
}

@end
