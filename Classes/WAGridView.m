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
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishDownloadWithNotification:) name:@"didSucceedResourceDownload" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishDownloadWithNotification:) name:@"didFailIssueDownload" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishDownloadWithNotification:) name:@"didSuccedIssueDownload" object:nil];
        
        
        
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
    if (!urlString){
        urlString = [[NSString alloc]initWithString: theString];
        //Initial setup is needed
        
        self.separatorStyle = UITableViewCellSeparatorStyleNone;//We use a tableview because we want to have a refresh control, but we don't want it to be visible

        NSString * cellNibTestName = [[urlString nameOfFileWithoutExtensionOfUrlString]stringByAppendingString:@"_cell"];
        NSString * cellNibName = [UIView getNibName:cellNibTestName defaultNib:@"WAGridCell" forOrientation:999];
        UIView * cellNibView = [UIView getNibView:cellNibTestName defaultNib:@"WAGridCell" forOrientation:999];
        cellNibSize = cellNibView.frame.size;
        //SLog(@"cellNibSize:%f,%f",nibView.frame.size.width,nibView.frame.size.height);
        
        //Set header view
        NSString * headerNibTestName = [[urlString nameOfFileWithoutExtensionOfUrlString]stringByAppendingString:@"_header"];
        NSString * headerNibName = [UIView getNibName:headerNibTestName defaultNib:@"WAGridHeader" forOrientation:999];
        UIView * headerNibView = [UIView getNibView:headerNibTestName defaultNib:@"WAGridHeader" forOrientation:999];
        headerNibSize = headerNibView.frame.size;
        //SLog(@"cellNibSize:%f,%f",nibView.frame.size.width,nibView.frame.size.height);
 
        
        UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc] init];
        [layout setHeaderReferenceSize:CGSizeMake(320, 50)];
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
        
        
        
        
        
    }
    else {
        urlString = [[NSString alloc]initWithString: theString];
        
    }
    [self initParser];
    
    
    
}

- (void) initParser{
    NSString * className = [urlString classNameOfParserOfUrlString];
    Class theClass = NSClassFromString(className);
    parser =  (NSObject <WAParserProtocol> *)[[theClass alloc] init];
    parser.urlString = urlString;
    
}



- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return parser.countData;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"cellIdentifier" forIndexPath:indexPath];
    
    [cell populateNibWithParser:parser withButtonDelegate:self withController:currentViewController   forRow:(int)indexPath.row+1];


    return cell;
}


- (UICollectionReusableView *)collectionView: (UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:
                                         UICollectionElementKindSectionHeader withReuseIdentifier:@"headerIdentifier" forIndexPath:indexPath];
    [headerView populateNibWithParser:parser withButtonDelegate:self withController:currentViewController forRow:0];
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
    [self openModule:newUrlString inView:button.superview inRect:button.frame];
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



#pragma mark -
#pragma mark ModuleView protocol

- (void)moduleViewWillAppear:(BOOL)animated{
    
    
    //Reset toolbar
    WAModuleViewController *vc = (WAModuleViewController *)[self firstAvailableUIViewController];
    //Reset toolbar
    [vc.rightToolBar setItems:nil];
    
    
    
    //Add subscribe button if relevant
    //First, check if the app offers subscriptions
    NSString * credentials = [[NSBundle mainBundle] pathOfFileWithUrl:@"Application_.plist"];
    if (credentials){
        NSString * sharedSecret = [[NSDictionary dictionaryWithContentsOfFile:credentials]objectForKey:@"SharedSecret"];
        NSString * userService = [[NSDictionary dictionaryWithContentsOfFile:credentials]objectForKey:@"UserService"];
        //If the app offers subscriptions, either sharedSecret or userService should be set
        if (sharedSecret||userService){
            //Now check if subscriptions are already active
            NSString * nodownloadUrlString = @"http://localhost/wanodownload.pdf";
            NSString * receipt = [nodownloadUrlString receiptForUrlString];
            if (receipt){
                //SLog(@"receipt found:%@",receipt);
                //Subscriptions are already active, don't show button
            }
            else{
                //Add button
                NSString * subscriptionAndSpaces = [NSString stringWithFormat:@"%@   ",[[NSBundle mainBundle]stringForKey:@"Subscription"]];
                [vc addButtonWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace orImageNamed:@"" orString:subscriptionAndSpaces andLink:@"buy://localhost/wanodownload.pdf"];
            }
            
            
            
            
        }
        
        
        
    }
    
    
    
}

- (void) moduleViewDidAppear{
    //SLog(@"grid moduleview did appear, should check update");
    //Check wether an update of the source data is needed
    WAModuleViewController * moduleViewController = (WAModuleViewController *) [self traverseResponderChainForUIViewController];
    [moduleViewController checkUpdateIfNeeded];
    
    //Update the table
    [self initParser];
    [currentCollectionView reloadData];
    
    
    
}

- (void) moduleViewWillDisappear:(BOOL)animated{
}



- (void) moduleWillRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
}

- (void) moduleWillAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    //Update the table
    [self initParser];
    [currentCollectionView reloadData];
    
}

- (void) jumpToRow:(int)row{
    
}

#pragma mark Notification handling methods

- (void) didFinishDownloadWithNotification:(NSNotification *) notification{
    
    NSString *notificatedUrl = notification.object;
    //SLog(@"notification.object:%@",notification.object);
    if ([notificatedUrl respondsToSelector:@selector(noArgsPartOfUrlString)]){
        if ([[notificatedUrl noArgsPartOfUrlString]isEqualToString:[urlString noArgsPartOfUrlString]])     [currentCollectionView reloadData];
    }
    
    [refreshControl endRefreshing];
    
}

#pragma mark Helper methods
- (void)refresh:(UIRefreshControl *)refreshControl {
    //[refreshControl endRefreshing];
    WAModuleViewController *vc = (WAModuleViewController *)[self firstAvailableUIViewController];
    [vc checkUpdate:YES];
    
    
}


@end
