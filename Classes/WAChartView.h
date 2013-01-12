//  Copyright 2011 WidgetAvenue - Librelio. All rights reserved.

#import <Foundation/Foundation.h>
#import "CorePlot-CocoaTouch.h"
#import "WAModuleProtocol.h"


@interface WAChartView : CPTGraphHostingView <CPTPlotDataSource, CPTPieChartDataSource, CPTBarPlotDelegate,WAModuleProtocol,UIGestureRecognizerDelegate>
{
	NSString *urlString;
	UIViewController* currentViewController;

	
    
    CPTXYGraph *graph, *barChart, *pieGraph;
    CPTPieChart *piePlot;
    BOOL piePlotIsRotating;
    
	NSMutableArray *dataForChart, *dataForPlot;
    CPTPlotSpaceAnnotation *symbolTextAnnotation;

}

@property(readwrite, retain, nonatomic) NSMutableArray *dataForChart, *dataForPlot;

// Plot construction methods
-(void)constructScatterPlot;
-(void)constructBarChart;
-(void)constructPieChart;

- (void)handleDoubleTap:(UITapGestureRecognizer *)recognizer;


@end
