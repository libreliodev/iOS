//  Copyright 2011 WidgetAvenue - Librelio. All rights reserved.

#import "WAGridView.h"
#import "WAUtilities.h"
#import "WAModuleViewController.h"
#import "UIView+WAModuleView.m"
#import "NSString+WAURLString.h"
#import "NSBundle+WAAdditions.h"
#import "GAI.h"

#define kHorizontalMargin 8
#define kVerticalMargin 2


@implementation WAGridView

@synthesize parser,currentViewController,refreshControl;

- (id)init {
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


        UIView * nibView = [UIView getNibView:[urlString nameOfFileWithoutExtensionOfUrlString] defaultNib:@"WAGridCell" forOrientation:999];
		cellNibSize = nibView.frame.size;
        //SLog(@"cellNibSize:%f,%f",nibView.frame.size.width,nibView.frame.size.height);
        
        self.delegate = self;//UITableView delegate
        self.dataSource = self;//UITableViewDataSource delegate
        self.rowHeight = cellNibSize.height+2*kVerticalMargin;
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
        

		
		
		//Test if a background image was provided
		NSString *bgUrlString = [WAUtilities urlByChangingExtensionOfUrlString:urlString toSuffix:@"_background.png"];
		NSString *bgPath = [[NSBundle mainBundle] pathOfFileWithUrl:bgUrlString];
		if (bgPath){
			UIImageView * background = [[UIImageView alloc] initWithFrame: self.bounds];
			background.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
			background.contentMode = UIViewContentModeScaleAspectFill;
			background.image = [UIImage imageWithContentsOfFile:bgPath];
			self.backgroundView = background;
			[background release];
		}
		
		
        //Tracking
        NSString * viewString = [urlString gaScreenForModuleWithName:@"Library" withPage:nil];
        [[[GAI sharedInstance] defaultTracker]sendView:viewString];
        
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



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //SLog(@"Number of sections: %i",[[layoutDic objectForKey:@"SectionViews" ]count]);
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int nbCols = [self numberofColumns];
    int ret = floor(([parser countData]-1)/nbCols)+1;
    //SLog(@"nbCol:%i,count:%i,ret:%i",nbCols,[parser countData],ret);
    return (ret);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSString *CellIdentifier = [NSString stringWithFormat:@"Cell%f",self.frame.size.width];//This prevents the same cells to be used in portrait and landscape mode, which poses problems.
    
 
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    int nbCols = [self numberofColumns];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
       
        //Calculate left margin
        CGFloat leftMargin = (self.frame.size.width-nbCols*(cellNibSize.width+2*kHorizontalMargin))/2;
        
        //Add subviews
        for (int i = 1; i <=nbCols; i++){
            UIView * nibView = [UIView getNibView:[urlString nameOfFileWithoutExtensionOfUrlString] defaultNib:@"WAGridCell" forOrientation:999];
            nibView.autoresizingMask = UIViewAutoresizingNone;
            nibView.frame = CGRectMake(leftMargin+kHorizontalMargin+(i-1)*(cellNibSize.width+2*kHorizontalMargin), kVerticalMargin,nibView.frame.size.width,nibView.frame.size.height);
            [cell.contentView addSubview:nibView];
            nibView.tag = 1000+i;
            
            
        }

        
	}
    
	cell.textLabel.hidden = YES;//Hide the standard textLabel view, otherwise our custom subviews get hiddeen
    
    for (int i = 1; i <=nbCols; i++){
        UIView * nibView = [cell.contentView viewWithTag:1000+i];//Get  our Nib View
        //SLog(@"Frame:%f,%f,%f,%f",nibView.frame.origin.x, nibView.frame.origin.y,nibView.frame.size.width,nibView.frame.size.height);
        if ((indexPath.row*nbCols)+i<=[parser countData]){
            [nibView populateNibWithParser:parser withButtonDelegate:self   forRow:(indexPath.row*nbCols)+i];
            [nibView setHidden:NO];
         }
        else{
            [nibView setHidden:YES];
        }
        
        
    }
	
	
    return cell;
    
}






- (void) dealloc
{
	[[NSNotificationCenter defaultCenter]removeObserver:self];
	[urlString release];
	[parser release];
    [refreshControl release];
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
        NSString * codeService = [[NSDictionary dictionaryWithContentsOfFile:credentials]objectForKey:@"CodeService"];
        NSString * userService = [[NSDictionary dictionaryWithContentsOfFile:credentials]objectForKey:@"UserService"];
        //If the app offers subscriptions, either sharedSecret or codeService or userService should be set
        if (sharedSecret||codeService||userService){
            //Now check if subscriptions are already active
            NSString * nodownloadUrlString = @"http://localhost/wanodownload.pdf";
            NSString * receipt = [nodownloadUrlString receiptForUrlString];
            if (receipt){
                //SLog(@"receipt found:%@",receipt);
                //Subscriptions are already active, don't show button
            }
            else{
                 //Add button
                NSString * subscriptionAndSpaces = [NSString stringWithFormat:@"%@   ",NSLocalizedString(@"Subscription",@"" )];
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
    [self reloadData];
    
 

}

- (void) moduleViewWillDisappear:(BOOL)animated{
 }



- (void) moduleWillRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
}

- (void) moduleWillAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    //Update the table
    [self initParser];
    [self reloadData];

}

- (void) jumpToRow:(int)row{
    
}

#pragma mark Notification handling methods

- (void) didFinishDownloadWithNotification:(NSNotification *) notification{
    
    NSString *notificatedUrl = notification.object;
    //SLog(@"notification.object:%@",notification.object);
    if ([notificatedUrl respondsToSelector:@selector(noArgsPartOfUrlString)]){
        if ([[notificatedUrl noArgsPartOfUrlString]isEqualToString:[urlString noArgsPartOfUrlString]])     [self reloadData];
    }

    [refreshControl endRefreshing];

}

#pragma mark Helper methods
- (int) numberofColumns{
    int ret = floor(self.frame.size.width/(cellNibSize.width+2*kHorizontalMargin));
    return ret;
    
    
}
- (void)refresh:(UIRefreshControl *)refreshControl {
    //[refreshControl endRefreshing];
    WAModuleViewController *vc = (WAModuleViewController *)[self firstAvailableUIViewController];
    [vc checkUpdate:YES];

}


@end
