//  Copyright 2011 WidgetAvenue - Librelio. All rights reserved.

#import "WAGridView.h"
#import "AQGridView.h"
#import "WAGridCell.h"
#import "WAUtilities.h"
#import "WAPDFParser.h"
#import "WAModuleViewController.h"
#import "WAPListParser.h"
#import "WALocalParser.h"
#import "UIView+WAModuleView.m"
#import "NSString+WAURLString.h"
#import "NSBundle+WAAdditions.h"
#import "GANTracker.h"



@implementation WAGridView

@synthesize parser,currentViewController;

- (id)init {
	if (self = [super init]) {
		[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(moduleViewDidAppear) name:UIApplicationDidBecomeActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSucceedResourceDownloadWithNotification:) name:@"didSucceedResourceDownload" object:nil];

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
		_emptyCellIndex = NSNotFound;
		
		self.autoresizesSubviews = YES;
		self.backgroundColor = [UIColor blackColor];
		
		
		
		
		// background goes in first
		//Test if a background image was provided
		NSString *bgUrlString = [WAUtilities urlByChangingExtensionOfUrlString:urlString toSuffix:@"_background.png"];
		NSString *bgPath = [[NSBundle mainBundle] pathOfFileWithUrl:bgUrlString];
		if (bgPath){
			UIImageView * background = [[UIImageView alloc] initWithFrame: self.bounds];
			background.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
			background.contentMode = UIViewContentModeScaleAspectFill;
			background.image = [UIImage imageWithContentsOfFile:bgPath];
			[self addSubview: background];
			[background release];
		}
		
		// grid view sits on top of the background image
		_gridView = [[AQGridView alloc] initWithFrame: self.bounds];
		_gridView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
		_gridView.backgroundColor = [UIColor clearColor];
		_gridView.opaque = NO;
		_gridView.dataSource = self;
		_gridView.delegate = self;
		_gridView.scrollEnabled = YES;
		
		
		if ( UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]) )
		{
			_gridView.leftContentInset = [self getHorizontalInsets].left;
			_gridView.rightContentInset = [self getHorizontalInsets].right;
		}
		
		[self addSubview: _gridView];
		
		//Add background to the grid view
		NSString *tileUrlString = [WAUtilities urlByChangingExtensionOfUrlString:urlString toSuffix:@"_tile.png"];
		NSString *tilePath = [[NSBundle mainBundle] pathOfFileWithUrl:tileUrlString];
		if (tilePath){
			UIImage * patternTile = [UIImage imageWithContentsOfFile:tilePath];
			UIView * backgroundView = [[UIView alloc] init];
			backgroundView.backgroundColor = [UIColor colorWithPatternImage: patternTile];
			_gridView.backgroundView = backgroundView;
			[backgroundView release];
		}
		
		/*Does not work, kept for future usage
		 // add our gesture recognizer to the grid view
		 UILongPressGestureRecognizer * gr = [[UILongPressGestureRecognizer alloc] initWithTarget: self action: @selector(moveActionGestureRecognizerStateChanged:)];
		 gr.minimumPressDuration = 0.5;
		 gr.delegate = self;
		 [_gridView addGestureRecognizer: gr];
		 [gr release];
		 */
		
        //Tracking
        NSString * pageString = [urlString gaVirtualUrlForModuleWithName:@"libraries" withPage:nil];
        
        NSError *error;
        if (![[GANTracker sharedTracker] trackPageview:pageString
                                             withError:&error]) {
            NSLog(@"error in trackPageview");
        }

		
		
		
	}
	else {
		urlString = [[NSString alloc]initWithString: theString];

	}
	[self initParser];
    [_gridView reloadData];

	
	
}

- (void) initParser{
    NSString * extension = [[urlString noArgsPartOfUrlString] pathExtension];
    if ([extension isEqualToString:@"plist"]) parser = [[WAPListParser alloc]init];
    else parser = [[WALocalParser alloc]init];//We will need to implement more cases in the future
    parser.urlString = urlString;
    
}




#pragma mark -
#pragma mark Librelio Sizing
- (CGSize) getCellInnerSize {
    CGSize ret= CGSizeMake(214.0, 367.0);//This is the default size	on the iPad
    //if (![LibrelioUtilities isBigScreen]) ret= CGSizeMake(160.0, 275.0);//This is the default size on the iPhone

	return ret;
	
}

- (CGSize) getCellOuterSize {
	CGSize ret = CGSizeZero;
	NSString *tileUrlString = [WAUtilities urlByChangingExtensionOfUrlString:urlString toSuffix:@"_tile.png"];
	NSString *tilePath = [[NSBundle mainBundle] pathOfFileWithUrl:tileUrlString];
	if (tilePath){
		//If we have a tile, we only use the default size
		ret= CGSizeMake(256.0, 384.0);//This is the default size on the iPad
		if (![WAUtilities isBigScreen]) ret= CGSizeMake(160.0, 184.0);
	}
	else {
		switch ([parser countData])
		{
			case 1:
				ret= CGSizeMake(768.0, 768.0);//This is the default size on the iPad
				if (![WAUtilities isBigScreen]) ret= CGSizeMake(320.0, 370.0);
				break;
			case 2:
				ret= CGSizeMake(384.0, 768.0);//This is the default size on the iPad
				if (![WAUtilities isBigScreen]) ret= CGSizeMake(230.0,370.0);
				break;
			case 3:
			case 4:
				ret= CGSizeMake(384.0, 384.0);//This is the default size on the iPad
				if (![WAUtilities isBigScreen]) ret= CGSizeMake(230.0,370.0);
				break;
			default:
				ret= CGSizeMake(256.0, 384.0);//This is the default size on the iPad
				if (![WAUtilities isBigScreen]) ret= CGSizeMake(230.0,370.0);//This is the default size on the iPhone
				break;
		}
		
	}
	
	return ret;
	
}

- (UIEdgeInsets) getHorizontalInsets{
	UIEdgeInsets ret = UIEdgeInsetsZero;
	switch ([parser countData])
	{
		case 1:
			break;
		default:
			ret = UIEdgeInsetsMake(0,0,0,0);;//This is the default insets on the iPad
			if (![WAUtilities isBigScreen]) ret = UIEdgeInsetsMake(0,0,0,0);//iPhone
			break;
	}
	
	return ret;
	
}



#pragma mark -
#pragma mark GridView Data Source

- (NSUInteger) numberOfItemsInGridView: (AQGridView *) gridView
{
    //SLog(@"Number of items:%i",[parser countData]);
    return ( [parser countData] );
}

- (AQGridViewCell *) gridView: (AQGridView *) gridView cellForItemAtIndex: (NSUInteger) index
{
    static NSString * EmptyIdentifier = @"EmptyIdentifier";
    static NSString * CellIdentifier = @"CellIdentifier";
    
    if ( index == _emptyCellIndex )
    {
        AQGridViewCell * hiddenCell = [gridView dequeueReusableCellWithIdentifier: EmptyIdentifier];
        if ( hiddenCell == nil )
        {
            // must be the SAME SIZE AS THE OTHERS
            // Yes, this is probably a bug. Sigh. Look at -[AQGridView fixCellsFromAnimation] to fix
			CGSize tempSize = [self getCellInnerSize];
            hiddenCell = [[[AQGridViewCell alloc] initWithFrame: CGRectMake(0.0, 0.0, tempSize.width, tempSize.height)
                                                reuseIdentifier: EmptyIdentifier] autorelease];
        }
        
        hiddenCell.hidden = YES;
        return ( hiddenCell );
    }
    
    WAGridCell * cell = (WAGridCell *)[gridView dequeueReusableCellWithIdentifier: CellIdentifier];
    if ( cell == nil )
    {
        CGSize tempSize = [self getCellInnerSize];
        NSString * nibName = [urlString nameOfFileWithoutExtensionOfUrlString];
        UIView * nibView = [UIView getNibView:nibName defaultNib:@"WAGridCell" forOrientation:999];

		cell = [[[WAGridCell alloc] initWithFrame: CGRectMake(0.0, 0.0, tempSize.width, tempSize.height) andNibView:nibView reuseIdentifier: CellIdentifier] autorelease];
    }
    
	//Get the dictionary at the current index
    int row = index+1;
    UIView * nibView = [[cell.contentView subviews]objectAtIndex:0];//Get  our Nib View
    [nibView populateNibWithParser:parser withButtonDelegate:self   forRow:row];
    return ( cell );
}

- (void) gridView: (AQGridView *) gridView didSelectItemAtIndex: (NSUInteger) index
{
	int row = index+1;
	NSString * newUrlString = [parser getDataAtRow:row forDataCol:DataColDetailLink];
	[self openModule:newUrlString inView:self inRect:self.frame];
	//[self deselectRowAtIndexPath:indexPath animated:NO];
	
}


- (CGSize) portraitGridCellSizeForGridView: (AQGridView *) gridView
{
	return [self getCellOuterSize];
}




- (void) dealloc
{
	[[NSNotificationCenter defaultCenter]removeObserver:self];
	[urlString release];
	[parser release];
    [_gridView release];
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
    
    //Deselect selected cover if any
    [_gridView deselectItemAtIndex:[_gridView indexOfSelectedItem] animated:NO];
    
    //Add subscribe button if relevant
    //First, check if the app offers subscriptions
    NSString * credentials = [[NSBundle mainBundle] pathOfFileWithUrl:@"Application_.plist"];
	if (credentials){
        NSString * sharedSecret = [[NSDictionary dictionaryWithContentsOfFile:credentials]objectForKey:@"SharedSecret"];
        NSString * codeHash = [[NSDictionary dictionaryWithContentsOfFile:credentials]objectForKey:@"CodeHash"];
        //If the app offers subscriptions, either sharedSecret or CodeHash should be set
        if (sharedSecret||codeHash){
            //Now check if subscriptions are already active
            NSString * nodownloadUrlString = @"http://localhost/wanodownload.pdf";
            NSString * receipt = [nodownloadUrlString receiptForUrlString];
            if (receipt){
                NSLog(@"receipt found:%@",receipt);
                //Subscriptions are already active, don't show button
            }
            else{
                WAModuleViewController *vc = (WAModuleViewController *)[self firstAvailableUIViewController];
                [vc addButtonWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace orImageNamed:@"" orString:NSLocalizedString(@"Subscription",@"" ) andLink:@"buy://localhost/wanodownload.pdf"];
            }
            
            
        }

 
    }
    
    

}

- (void) moduleViewDidAppear{
    //SLog(@"grid moduleview did appear");
    //Check wether an update of the source data is needed 
    WAModuleViewController * moduleViewController = (WAModuleViewController *) [self traverseResponderChainForUIViewController];
    [moduleViewController checkUpdate];
    
    //Update the table
    [self initParser];
    [_gridView reloadData];
    
    //Remove previously added modules
    NSArray * subViewsArray =[self subviews];
    for (UIView * subView in subViewsArray){
        if ([subView conformsToProtocol:@protocol(WAModuleProtocol)]) [subView removeFromSuperview];
    }
    if (![parser countData]){
        //If there is no data, display an html message
        
        //Conventionally, the message html file has the same name as the main file, with the html extension; find the corresponding url;
        NSString * htmlMessageUrl = [[urlString noArgsPartOfUrlString] urlByChangingSchemeOfUrlStringToScheme:@"http"];
        htmlMessageUrl = [WAUtilities urlByChangingExtensionOfUrlString:htmlMessageUrl toSuffix:@".html?warect=self"];
        //Check if html file exists locally
        if ([[NSBundle mainBundle] pathOfFileWithUrl:htmlMessageUrl]){
            WAModuleViewController * moduleViewController = [[WAModuleViewController alloc]init];
            
            //Load the html module
            moduleViewController.moduleUrlString= htmlMessageUrl ;
            moduleViewController.initialViewController= currentViewController;
            moduleViewController.containingView= self;
            moduleViewController.containingRect= self.frame;
            [moduleViewController pushViewControllerIfNeededAndLoadModuleView];
            [moduleViewController release];
            
        }
        
        
    }


}

- (void) moduleViewWillDisappear:(BOOL)animated{
 }



- (void) moduleWillRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
	 if ( UIInterfaceOrientationIsPortrait(toInterfaceOrientation) )
	 {
	 //Back to 0 insets
	 _gridView.leftContentInset = 0.0;
	 _gridView.rightContentInset = 0.0;
	 }
	 else
	 {
	 _gridView.leftContentInset = [self getHorizontalInsets].left;
	 _gridView.rightContentInset = [self getHorizontalInsets].right;
	 
	 }
}

- (void) moduleWillAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
}

- (void) jumpToRow:(int)row{
    
}

#pragma mark Notification handling methods

- (void) didSucceedResourceDownloadWithNotification:(NSNotification *) notification{
    
    NSString *notificatedUrl = notification.object;
    if ([[notificatedUrl noArgsPartOfUrlString]isEqualToString:[urlString noArgsPartOfUrlString]])     [_gridView reloadData];

}

@end
