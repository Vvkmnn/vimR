/**
 * Tae Won Ha — @hataewon
 *
 * http://taewon.de
 * http://qvacua.com
 *
 * See LICENSE
 */

#import "VRFileBrowserView.h"
#import "VRUtils.h"
#import "VRFileItem.h"
#import "VRFileItemManager.h"


#define CONSTRAIN(fmt, ...) [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat: fmt, ##__VA_ARGS__] options:0 metrics:nil views:views]];


@implementation VRFileBrowserView {
  NSOutlineView *_fileOutlineView;
  NSScrollView *_scrollView;
}

#pragma mark Public
- (instancetype)initWithRootUrl:(NSURL *)rootUrl {
  self = [super initWithFrame:CGRectZero];
  RETURN_NIL_WHEN_NOT_SELF

  _rootUrl = rootUrl;
  [self addViews];

  return self;
}

#pragma mark NSOutlineViewDataSource
- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(VRFileItem *)item {
  if (!item) {
    NSArray *children = [_fileItemManager childrenOfRootUrl:_rootUrl];
    return children.count;
  }

  NSArray *children = [_fileItemManager childrenOfItem:item];
  return children.count;
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(VRFileItem *)item {
  if (!item) {
    NSArray *children = [_fileItemManager childrenOfRootUrl:_rootUrl];
    return children[(NSUInteger) index];
  }

  return [[_fileItemManager childrenOfItem:item] objectAtIndex:(NSUInteger) index];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(VRFileItem *)item {
  return item.dir;
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn
           byItem:(VRFileItem *)item {

  return item.url.lastPathComponent;
}

#pragma mark NSOutlineViewDelegate


#pragma mark NSView
- (BOOL)mouseDownCanMoveWindow {
  // I dunno why, but if we don't override this, then the window title has the inactive appearance and the drag in the
  // VRWorkspaceView in combination with the vim view does not work correctly. To override -isOpaque does not suffice.
  return NO;
}

#pragma mark Private
- (void)addViews {
  NSTableColumn *tableColumn = [[NSTableColumn alloc] initWithIdentifier:@"name"];
  tableColumn.dataCell = [[NSTextFieldCell alloc] initTextCell:@""];
  [tableColumn.dataCell setLineBreakMode:NSLineBreakByTruncatingTail];

  _fileOutlineView = [[NSOutlineView alloc] initWithFrame:CGRectZero];
  [_fileOutlineView addTableColumn:tableColumn];
  _fileOutlineView.outlineTableColumn = tableColumn;
  [_fileOutlineView sizeLastColumnToFit];
  _fileOutlineView.allowsEmptySelection = YES;
  _fileOutlineView.allowsMultipleSelection = NO;
  _fileOutlineView.headerView = nil;
  _fileOutlineView.focusRingType = NSFocusRingTypeNone;
  _fileOutlineView.dataSource = self;
  _fileOutlineView.delegate = self;

  _scrollView = [[NSScrollView alloc] initWithFrame:NSZeroRect];
  _scrollView.translatesAutoresizingMaskIntoConstraints = NO;
  _scrollView.hasVerticalScroller = YES;
  _scrollView.hasHorizontalScroller = NO;
  _scrollView.borderType = NSNoBorder;
  _scrollView.autohidesScrollers = YES;
  _scrollView.documentView = _fileOutlineView;
  [self addSubview:_scrollView];

  NSDictionary *views = @{
      @"outline" : _scrollView,
  };

  CONSTRAIN(@"H:|[outline(>=50)]|");
  CONSTRAIN(@"V:|[outline(>=50)]|");
}

- (void)setUp {
  [_fileOutlineView reloadData];
}

@end
