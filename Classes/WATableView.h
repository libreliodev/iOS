
#import "WAModuleProtocol.h"
#import "WAParserProtocol.h"


@interface WATableView : UITableView<WAModuleProtocol,UITableViewDelegate,UITableViewDataSource>
{
    NSString *urlString;
	UIViewController* currentViewController;
    NSObject <WAParserProtocol> *parser;
    UIRefreshControl *refreshControl;
    
    NSDictionary * currentQueryDic;
    
    
}

@property (nonatomic, retain) NSString *urlString;
@property (nonatomic, assign) UIViewController* currentViewController;
@property (nonatomic, retain) NSObject <WAParserProtocol> *parser;
@property (nonatomic, retain) NSDictionary * currentQueryDic;
@property (nonatomic, retain) UIRefreshControl *refreshControl;


- (void) initParser;
- (void) followDetailLink:(NSString *) detailLink;
- (void) didFinishDownloadWithNotification:(NSNotification *) notification;


@end
