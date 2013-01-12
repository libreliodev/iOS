
#import "WAModuleProtocol.h"
#import "WAParserProtocol.h"


@interface WATableView : UITableView<WAModuleProtocol,UITableViewDelegate,UITableViewDataSource>
{
    NSString *urlString;
	UIViewController* currentViewController;
    NSObject <WAParserProtocol> *parser;
    
    NSDictionary * currentQueryDic;
    
    
}

@property (nonatomic, retain) NSString *urlString;
@property (nonatomic, assign) UIViewController* currentViewController;
@property (nonatomic, retain) NSObject <WAParserProtocol> *parser;
@property (nonatomic, retain) NSDictionary * currentQueryDic;


- (void) initParser;
- (void) followDetailLink:(NSString *) detailLink;
- (void) didSucceedResourceDownloadWithNotification:(NSNotification *) notification;


@end
