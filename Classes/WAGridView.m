//  Copyright 2011 WidgetAvenue - Librelio. All rights reserved.

#import "WAGridView.h"
#import "WAUtilities.h"
#import "WAModuleViewController.h"
#import "UIView+WAModuleView.m"
#import "NSString+WAURLString.h"
#import "NSBundle+WAAdditions.h"

#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"

#define kHorizontalMargin 8
#define kVerticalMargin 2


@implementation WAGridView

@synthesize parser,currentViewController,refreshControl,currentCollectionView;

- (id)init {
    //SLog(@"Will init covers");
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(moduleViewDidAppear) name:UIApplicationDidBecomeActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSucceedResourceDownloadWithNotification:) name:@"didSucceedResourceDownload" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSuccedIssueDownloadWithNotification:) name:@"didSuccedIssueDownload" object:nil];
        
        
        
    }
    return self;
}


- (NSString *) urlString
{
    return urlString;
}

- (void) setUrlString: (NSString *) theString
{
    //SLog(@"Will set urlString in GridView for %@ -",theString);
    if (urlString) [urlString release];//Reinstantiate, to take new orientation into account
        
        urlString = [[NSString alloc]initWithString: theString];
    //Initial setup is needed
    
    self.separatorStyle = UITableViewCellSeparatorStyleNone;//We use a tableview because we want to have a refresh control, but we don't want it to be visible
    
    
    UIInterfaceOrientation * currentOrientation = self.frame.size.height<self.frame.size.width?UIInterfaceOrientationLandscapeLeft:UIInterfaceOrientationPortrait;//This is needed for xibs
    NSString * cellNibTestName = [[urlString nameOfFileWithoutExtensionOfUrlString]stringByAppendingString:@"_cell"];
    NSString * cellNibName = [UIView getNibName:cellNibTestName defaultNib:@"WAGridCell" forOrientation:currentOrientation];
    UIView * cellNibView = [UIView getNibView:cellNibTestName defaultNib:@"WAGridCell" forOrientation:currentOrientation];
    cellNibSize = cellNibView.frame.size;
    //SLog(@"cellNibSize:%f,%f",cellNibView.frame.size.width,cellNibView.frame.size.height);
    
    //Set header view
    NSString * headerNibTestName = [[urlString nameOfFileWithoutExtensionOfUrlString]stringByAppendingString:@"_header"];
    NSString * headerNibName = [UIView getNibName:headerNibTestName defaultNib:@"WAGridHeader" forOrientation:currentOrientation];
    UIView * headerNibView = [UIView getNibView:headerNibTestName defaultNib:@"WAGridHeader" forOrientation:currentOrientation];
    headerNibSize = headerNibView.frame.size;
    if ([headerNibView viewWithTag:3]||[headerNibView viewWithTag:20]) rowInHeaderView=1; //If there is a cover in header nib, it means that header should contain first row
    else rowInHeaderView=0;
    
    //Set collection view
    UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc] init];
    layout.sectionInset =  UIEdgeInsetsMake(30, 30, 30, 30);
    currentCollectionView=[[UICollectionView alloc] initWithFrame:self.frame collectionViewLayout:layout];
    currentCollectionView.autoresizingMask = (UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleTopMargin);
    
    [currentCollectionView setDataSource:self];
    [currentCollectionView setDelegate:self];
    
    [currentCollectionView registerNib:[UINib nibWithNibName:cellNibName bundle:nil] forCellWithReuseIdentifier:@"cellIdentifier"];
    [currentCollectionView registerNib:[UINib nibWithNibName:headerNibName bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"headerIdentifier"];
    
    //[currentCollectionView setBackgroundColor:[UIColor redColor]];
    
    
    [self addSubview:currentCollectionView];
    
    
    
    //Test if a background image was provided
    NSString *bgUrlString = [[urlString nameOfFileWithoutExtensionOfUrlString] stringByAppendingString:@"_background.png"];
    //SLog(@"bgUrlString:%@",bgUrlString);
    NSString *bgPath = [[NSBundle mainBundle] pathOfFileWithUrl:bgUrlString];
    if (bgPath){
        UIImageView * background = [[UIImageView alloc] initWithFrame: self.bounds];
        background.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        background.contentMode = UIViewContentModeScaleAspectFill;
        background.image = [UIImage imageWithContentsOfFile:bgPath];
        currentCollectionView.backgroundView = background;
        [background release];
    }
    
    
    
    //Tracking
    NSString * viewString = [urlString gaScreenForModuleWithName:@"Library" withPage:nil];
    // May return nil if a tracker has not already been initialized with a
    // property ID.
    id tracker = [[GAI sharedInstance] defaultTracker];
    
    // This screen name value will remain set on the tracker and sent with
    // hits until it is set to a new value or to nil.
    [tracker set:kGAIScreenName
           value:viewString];
    
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
    //Refresh
    //Add refresh view if waupdate parameter was present
    NSString * mnString = [urlString valueOfParameterInUrlStringforKey:@"waupdate"];
    if (mnString){
        
        refreshControl = [[UIRefreshControl alloc] init];
        refreshControl.backgroundColor = [UIColor whiteColor];
        [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:refreshControl];
    }
    
    
    
    
    
     [self initParser];
 
    
    
    
}

- (void) initParser{
    NSString * className = [urlString classNameOfParserOfUrlString];
    Class theClass = NSClassFromString(className);
    parser =  (NSObject <WAParserProtocol> *)[[theClass alloc] init];
    parser.urlString = urlString;
    //SLog(@"Did init parser %@ with count %i",parser,[parser countData]);
    
}




- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    //SLog(@"number of items %i",MAX(parser.countData-rowInHeaderView,0));
    return MAX(parser.countData-rowInHeaderView,0);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"cellIdentifier" forIndexPath:indexPath];
    if (self.currentCollectionView.dragging == NO && self.currentCollectionView.decelerating == NO)
    {
        [cell populateNibWithParser:parser withButtonDelegate:self withController:currentViewController   displayingImages:YES forRow:(int)indexPath.row+1+rowInHeaderView];
    }
    else {
        [cell populateNibWithParser:parser withButtonDelegate:self withController:currentViewController   displayingImages:NO forRow:(int)indexPath.row+1+rowInHeaderView];
    }

    
    //SLog(@"handling cell %i",indexPath.row+1+rowInHeaderView);

    return cell;
}


- (UICollectionReusableView *)collectionView: (UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:
                                         UICollectionElementKindSectionHeader withReuseIdentifier:@"headerIdentifier" forIndexPath:indexPath];
    //SLog(@"indexPath for header %@",indexPath);
    headerView.tag = 998; //convention
    [headerView populateNibWithParser:parser withButtonDelegate:self withController:currentViewController displayingImages:YES forRow:rowInHeaderView];
    return headerView;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return cellNibSize;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return headerNibSize;
}


- (void) dealloc
{
    //SLog(@"Will start dealloc gridview %@ count %i",self, [parser countData]);
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    [urlString release];
    [parser release];
    [refreshControl release];
    [currentCollectionView release];
    [super dealloc];

}

#pragma mark -
#pragma mark Button Actions

- (void)buttonAction:(id)sender{
    UIButton *button = (UIButton *)sender;
    NSString * newUrlString = [button titleForState:UIControlStateApplication];
    NSString * absoluteUrlString = [WAUtilities absoluteUrlOfRelativeUrl:newUrlString relativeToUrl:urlString];
    NSURL * url = [NSURL URLWithString:absoluteUrlString];
    if ([url.scheme isEqualToString:@"detail"]){
        int detailRow = [url.host intValue];
        [self openDetailView:detailRow];
        

    }
    else if ([url.scheme isEqualToString:@"dismiss"]){
        [self dismissDetailView];
    }
    
    
    else {
        [self openModule:newUrlString inView:button.superview inRect:button.frame];
    }

   //
    
}


- (void) openModule:(NSString*)theUrlString inView:(UIView*)pageView inRect:(CGRect)rect{
    WAModuleViewController * moduleViewController = [[WAModuleViewController alloc]init];
    moduleViewController.moduleUrlString= theUrlString;
    moduleViewController.initialViewController= self.currentViewController;
    moduleViewController.containingView= pageView;
    moduleViewController.containingRect= rect;
    [moduleViewController pushViewControllerIfNeededAndLoadModuleView];
    [moduleViewController release];
}
                                         
- (void) openDetailView:(int)detailRow{
    //SLog(@"detailRow %i",detailRow);
 
    UIInterfaceOrientation * currentOrientation = self.frame.size.height<self.frame.size.width?UIInterfaceOrientationLandscapeLeft:UIInterfaceOrientationPortrait;//This is needed for xibs
 
    
    NSString * modalNibTestName = [[urlString nameOfFileWithoutExtensionOfUrlString]stringByAppendingString:@"_modal"];
    UIView * modalNibView = [UIView getNibView:modalNibTestName defaultNib:@"WAGridModal" forOrientation:currentOrientation];
    //SLog(@"modalNibView %@",modalNibView);
    
    modalNibView.frame = self.frame;
    modalNibView.tag = 789;//This is conventional
    modalNibView.autoresizingMask = (UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleTopMargin);
    //SLog(@"Will add subview %@",modalNibView);
    [self addSubview:modalNibView];
    [modalNibView populateNibWithParser:parser withButtonDelegate:self withController:currentViewController   displayingImages:YES forRow:detailRow];


    
    
   
    
}

- (void) dismissDetailView{
    UIView * modalView = [self viewWithTag:789];
    [modalView removeFromSuperview];
}



#pragma mark -
#pragma mark ModuleView protocol

- (void)moduleViewWillAppear:(BOOL)animated{
    
    //SLog(@"moduleView will appear %@ with parser count %i",self,[parser countData]);
    //Reset toolbar
    WAModuleViewController *vc = (WAModuleViewController *)[self firstAvailableUIViewController];
    //Reset toolbar
    [vc.rightToolBar setItems:nil];
    
    
    
    //Add subscribe button if relevant
    NSString * subscribeString = [WAUtilities subscribeString];
    if (subscribeString){
		//NSString * subscriptionAndSpaces = [NSString stringWithFormat:@"%@   ",subscribeString];
		//[vc addButtonWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace orImageNamed:@"" orString:subscriptionAndSpaces andLink:@"buy://localhost/wanodownload.pdf"];
		[vc addMenuButtonWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace];
		
    }
}

- (void) moduleViewDidAppear{
    //SLog(@"grid moduleview did appear, should check update");
    //Check wether an update of the source data is needed
    WAModuleViewController * moduleViewController = (WAModuleViewController *) [self traverseResponderChainForUIViewController];
    [moduleViewController checkUpdateIfNeeded];
    
    self.urlString = urlString;
    

    
    
}

- (void) moduleViewWillDisappear:(BOOL)animated{
}



- (void) moduleWillRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
}

- (void) moduleWillAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    //Update the table
    self.urlString = urlString;
    
}

- (void) jumpToRow:(int)row{
    
}

#pragma mark Notification handling methods

- (void) didSucceedIssueDownloadWithNotification:(NSNotification *) notification{
    
    NSString *notificatedUrl = notification.object;
    //SLog(@"notification.object:%@",notification.object);
    if ([notificatedUrl respondsToSelector:@selector(noArgsPartOfUrlString)]){
        if ([[notificatedUrl noArgsPartOfUrlString]isEqualToString:[urlString noArgsPartOfUrlString]])
            //SLog(@"Will reload dta");
            [currentCollectionView reloadData];
    }
    
    [refreshControl endRefreshing];
    
}

- (void) didSucceedResourceDownloadWithNotification:(NSNotification *) notification {
    NSString *notificatedUrl = notification.object;
    //SLog(@"notification.object:%@",notification.object);
    if ([notificatedUrl respondsToSelector:@selector(noArgsPartOfUrlString)]){
        
        NSArray * visibleCells = [self.currentCollectionView visibleCells];
        
        //Refresh header if needed
        if (rowInHeaderView){
            NSString * imagePath1 = [parser getDataAtRow:rowInHeaderView forDataCol:DataColImage];
            NSString * imagePath2 = [parser getDataAtRow:rowInHeaderView forDataCol:DataColNewsstandCover];
            BOOL test1 = [imagePath1 isEqualToString:[[NSBundle mainBundle]pathOfFileWithUrl:notificatedUrl]];
            BOOL test2 = [imagePath2 isEqualToString:[[NSBundle mainBundle]pathOfFileWithUrl:notificatedUrl]];
            
            if ((imagePath1||imagePath2)&& (test1||test2)){
                //SLog(@"viewWithTag:%@",[self viewWithTag:998]);
                [[self viewWithTag:998] populateNibWithParser:parser withButtonDelegate:self withController:currentViewController displayingImages:YES forRow:rowInHeaderView];
                
            }
           
        }
        
        //Refresh cells if needed
        for (UICollectionViewCell* cell in visibleCells){
            NSIndexPath * index = [self.currentCollectionView indexPathForCell:cell];
            NSString * imagePath = [parser getDataAtRow:(int)index.row+1+rowInHeaderView forDataCol:DataColImage];
            //SLog(@"image url: %@ relative to urlString %@",[parser getDataAtRow:(int)index.row+1 forDataCol:DataColImage],urlString);
            //SLog(@"will compare: %@ & %@",imagePath,[[NSBundle mainBundle]pathOfFileWithUrl:notificatedUrl]);
            if (imagePath&& [imagePath isEqualToString:[[NSBundle mainBundle]pathOfFileWithUrl:notificatedUrl]])
            {
                //SLog(@"Matches!");
                [cell populateNibWithParser:parser withButtonDelegate:self withController:currentViewController   displayingImages:YES forRow:(int)index.row+1+rowInHeaderView];
                [self.currentCollectionView reloadItemsAtIndexPaths:@[index]];
                
                
            }
            
            
        }
    }
    
}


#pragma mark Helper methods
- (void)refresh:(UIRefreshControl *)refreshControl {
    //[refreshControl endRefreshing];
    //SLog(@"Will update in %@",self);
    WAModuleViewController *vc = (WAModuleViewController *)[self firstAvailableUIViewController];
    [vc checkUpdate:YES];
    
    
}

- (void)loadImagesForOnscreenRows
{
    NSArray * visibleCells = [self.currentCollectionView visibleCells];
    
    
    //Refresh cells if needed
    for (UICollectionViewCell* cell in visibleCells){
        NSIndexPath * index = [self.currentCollectionView indexPathForCell:cell];
            [cell populateNibWithParser:parser withButtonDelegate:self withController:currentViewController   displayingImages:YES forRow:(int)index.row+1+rowInHeaderView];
            [self.currentCollectionView reloadItemsAtIndexPaths:@[index]];
            
        
        
    }

}


#pragma mark - UIScrollViewDelegate

// -------------------------------------------------------------------------------
//	scrollViewDidEndDragging:willDecelerate:
//  Load images for all onscreen rows when scrolling is finished.
// -------------------------------------------------------------------------------
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate)
    {
        //SLog(@"did en dragging");
        [self loadImagesForOnscreenRows];
    }
}

// -------------------------------------------------------------------------------
//	scrollViewDidEndDecelerating:scrollView
//  When scrolling stops, proceed to load the app icons that are on screen.
// -------------------------------------------------------------------------------
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    //SLog(@"did en decelerating");
    [self loadImagesForOnscreenRows];

}



@end
