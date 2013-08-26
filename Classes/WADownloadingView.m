//  Copyright 2011 WidgetAvenue - Librelio. All rights reserved.


#import "WADownloadingView.h"
#import "WAUtilities.h"
#import "WAModuleViewController.h"
#import "WADocumentDownloadsManager.h"
#import "WADocumentDownloader.h"
#import "WANewsstandIssueDownloader.h"
#import "WAMissingResourcesDownloader.h"
#import "WAPDFParser.h"
#import "NSString+WAURLString.h"
#import "NSBundle+WAAdditions.h"
#import "NSDate+WAAdditions.h"

#import "GAI.h"


@implementation WADownloadingView

@synthesize currentViewController,progressView,messageLabel,imageView,timer,downloadOnlyMissingResources ;




- (NSString *) urlString
{
    return urlString;
}

- (void) setUrlString: (NSString *) theString
{
	
	urlString = [[NSString alloc]initWithString: theString];
    
    //Add observers
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFailIssueDownloadWithNotification:) name:@"didFailIssueDownload" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSucceedIssueDownloadWithNotification:) name:@"didSucceedIssueDownload" object:nil];

	
	self.backgroundColor = [UIColor blackColor];
	
	CGFloat fWidth = self.frame.size.width;
	CGFloat fHeight = self.frame.size.height;


	//Add image view
	imageView = [[UIImageView alloc]init];
	NSString *noUnderscoreUrlString = [urlString urlByRemovingFinalUnderscoreInUrlString];//Remove the final underscore
	NSString * pngPath = [[NSBundle mainBundle] pathOfFileWithUrl:[WAUtilities urlByChangingExtensionOfUrlString:noUnderscoreUrlString toSuffix:@".png"]];
	if (pngPath) imageView.image  = [UIImage imageWithContentsOfFile:pngPath];
	else imageView.image = [UIImage imageNamed:@"Default-Portrait.png"];
	imageView.contentMode = UIViewContentModeScaleAspectFit;
	CGFloat imWidth = MIN(200,0.6*fWidth);
	CGFloat imHeight = MIN(300,0.6*fHeight);
	imageView.frame = CGRectMake((fWidth-imWidth)/2, (0.8*fHeight-imHeight)/2, imWidth, imHeight);
	imageView.autoresizingMask = (UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleTopMargin);
	[self addSubview:imageView];
	
	//Show progress view
	progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
	progressView.autoresizingMask = (UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleTopMargin);
	progressView.frame =CGRectMake(fWidth*0.2, 0.88*fHeight, 0.6*fWidth, 0.1*fHeight);
	//SLog(@"frame:%f;%f,%f,%f",fWidth*0.1, 0.8*fHeight, 0.8*fWidth, 0.1*fHeight);
	[self addSubview:progressView];
	
	//Add the message label
	messageLabel = [[UILabel alloc] init];
	messageLabel.backgroundColor = [UIColor clearColor];
	messageLabel.textColor = [UIColor whiteColor];
	messageLabel.font = [UIFont systemFontOfSize:16];
	messageLabel.textAlignment = UITextAlignmentCenter;
	messageLabel.frame = CGRectMake(fWidth*0.1, 0.8*fHeight, 0.8*fWidth, 0.1*fHeight);
	messageLabel.autoresizingMask = (UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleTopMargin);
	[self addSubview:messageLabel];
	
	UITapGestureRecognizer *singleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
	singleTapGestureRecognizer.numberOfTapsRequired = 1;
	singleTapGestureRecognizer.delegate = self;
	[self addGestureRecognizer:singleTapGestureRecognizer];
	
	
	
    
    if ([urlString shouldUseNewsstandForUrlString]) {
        //SLog(@"Use Newsstand");
        [self startDownloadWithNewsstand];
    }
    else {
        //SLog(@"No Newsstand");
        [self startDownloadWithoutNewsstand];
             
    }
          

    //Add the timer
    timer = [[NSTimer scheduledTimerWithTimeInterval: 0.5 target:self selector:@selector(updateDisplay) userInfo:nil repeats:YES]retain];

	
    //Register screen view only if visible; this could not be the case, because download occurs in the background if it is an update
    if (!self.hidden){
        NSString * viewString = [urlString gaScreenForModuleWithName:@"Downloading" withPage:nil];
        
        [[[GAI sharedInstance] defaultTracker]sendView:viewString];

    }
	
	
	
	
	
}
- (void)willMoveToSuperview:(UIView *)newSuperview{
	if (!newSuperview){//In this case, the view is being removed from superview
		[timer invalidate];//This is important to avoid memory leaks
	}
	
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];

	[imageView release];
	[progressView release];
	[messageLabel release];
	[urlString release];
    [super dealloc];
}


#pragma mark Start download

- (void) startDownloadWithoutNewsstand{
    if (![[WADocumentDownloadsManager sharedManager]isAlreadyInQueueIssueWithUrlString:urlString]){
        //SLog(@"Starting without newssstand");
        if (!downloadOnlyMissingResources){
            WADocumentDownloader * issue = [[WADocumentDownloader alloc]init];
            issue.urlString = urlString;
            [[[WADocumentDownloadsManager sharedManager] issuesQueue]addObject:issue];
            [issue release];
        }
        else {
            WAMissingResourcesDownloader * issue = [[WAMissingResourcesDownloader alloc]init];
            issue.urlString = urlString;
            [[[WADocumentDownloadsManager sharedManager] issuesQueue]addObject:issue];
            [issue release];
            [self removeFromSuperview];//Remove the downloading view, we will not need it


      }
    }
   
}
- (void) startDownloadWithNewsstand{
    
    
    //In Newsstand, we assume that there can't be missing resources
    if (downloadOnlyMissingResources)        [self removeFromSuperview];//Remove the downloading view
    else{
        
        //Add to issues if required
        NKLibrary *nkLib = [NKLibrary sharedLibrary];
        NSDate * issueDate = [NSDate date];
        NSString * argDateString = [urlString valueOfParameterInUrlStringforKey:@"wadate"];
        if (argDateString){
            NSDateFormatter *df = [[[NSDateFormatter alloc] init]autorelease];  
            df.dateFormat = @"dd-MM-yyyy";  
            issueDate = [df dateFromString:argDateString]; 
            
        }
        
        NKIssue *nkIssue = [nkLib issueWithName:[urlString rootDirectoryNameOfUrlString]];
        if(!nkIssue) {
            nkIssue = [nkLib addIssueWithName:[urlString rootDirectoryNameOfUrlString] date:issueDate];
            //SLog(@"Added issue: %@",nkIssue);
            
        }
        
        
        //Initiate download
        if (![[WADocumentDownloadsManager sharedManager]isAlreadyInQueueIssueWithUrlString:urlString]){
            
            WANewsstandIssueDownloader * issue = [[WANewsstandIssueDownloader alloc]init];
            issue.urlString = urlString  ;
            [[[WADocumentDownloadsManager sharedManager] issuesQueue]addObject:issue];
            [issue release];
        }

        
    }
     
}


#pragma mark Notification handling methods

- (void) didFailIssueDownloadWithNotification:(NSNotification *) notification{
    NSDictionary *notificatedDic = notification.object;
    NSString *notificatedUrl = [notificatedDic objectForKey:@"urlString"];
    if ([notificatedUrl isEqualToString:self.urlString  ]){
        //SLog(@"Download failed for url:%@",self.urlString );
      	//If this view is visible, and only in this case, display error message
        if (self.hidden ==NO){
            NSString * httpStatus = [notificatedDic objectForKey:@"httpStatus"];
            NSString * theMessage = NSLocalizedString(@"Download failed, please check your connection",@"");
            if ([httpStatus isEqualToString:@"401"]) theMessage = NSLocalizedString(@"Invalid Code",@"");
            if ([httpStatus isEqualToString:@"462"]) theMessage = NSLocalizedString(@"You don't own this issue",@"");
            if ([httpStatus isEqualToString:@"461"]) theMessage = NSLocalizedString(@"Invalid Username Or Password",@"");
            if ([httpStatus isEqualToString:@"463"]) theMessage = NSLocalizedString(@"Too Many Devices",@"");
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil
                                                           message:theMessage
                                                          delegate:self 
                                                 cancelButtonTitle:@"OK"
                                                 otherButtonTitles:nil];
            [alert show];
            [alert release];
        }
    }
}			  

- (void) didSucceedIssueDownloadWithNotification:(NSNotification *) notification{
        
    NSString *notificatedUrl = notification.object;
    if ([notificatedUrl isEqualToString:self.urlString  ]){
         //Create a fresh module
        WAModuleViewController * moduleViewController = [[WAModuleViewController alloc]init];
        moduleViewController.moduleUrlString= urlString;
        moduleViewController.initialViewController= currentViewController;
        moduleViewController.containingView= self.superview.superview;
        moduleViewController.containingRect= self.superview.frame;
        //SLog(@"Will load module view and check update");
        [moduleViewController loadModuleViewAndCheckUpdate];
        if ([self.superview isEqual:currentViewController.moduleView]){
            //In this case, the module is the main one under the viewcontroller => we need to let the view controller know
            currentViewController.moduleView = moduleViewController.moduleView;
        }
        [moduleViewController release];
        
        //Register event with Google Analytics
        NSString * action = @"Download succeeded";
        NSString * label = [NSString stringWithFormat:@"%@/%@",[[[NSBundle mainBundle] infoDictionary]objectForKey:@"CFBundleIdentifier"],[urlString stringByReplacingOccurrencesOfString:@"http://localhost/" withString:@""]];
        [[[GAI sharedInstance] defaultTracker] sendEventWithCategory:@"Downloader" withAction:action withLabel:label withValue:[NSNumber numberWithInt:1]];


        
        
        [self.superview removeFromSuperview];//Remove the downloading view
        
         
        
    }
    
    

}
#pragma mark -
#pragma mark Timer action
- (void)updateDisplay {
    WADocumentDownloader * issue = [[WADocumentDownloadsManager sharedManager] issueWithUrlString:urlString];
    if (issue){
        //SLog(@"Current progress:%f",issue.currentProgress);
        messageLabel.text = issue.currentMessage;
        progressView.progress = issue.currentProgress;
    }
    
}


#pragma mark -
#pragma mark GestureRecognizer delegate
- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer {
	[currentViewController.navigationController setNavigationBarHidden:NO animated:YES];//This will avoid having no way to get back
}
		

#pragma mark -
#pragma mark UIActionSheetDelegate methods



- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	switch (buttonIndex) {
		case 0:
		{
			[self.currentViewController.navigationController popViewControllerAnimated:YES];
			break;
		}
		case 1:
		{
            WADocumentDownloader * issue = [[WADocumentDownloader alloc]init];
            [[[WADocumentDownloadsManager sharedManager] issuesQueue]addObject:issue];
            [issue release];
			break;
		}
		default:
			[self.currentViewController.navigationController popViewControllerAnimated:YES];
			break;
    }
}

#

@end
