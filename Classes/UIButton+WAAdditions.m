#import "UIButton+WAAdditions.h"
#import "NSString+WAURLString.h"
#import "NSBundle+WAAdditions.h"
#import "WAUtilities.h"


@implementation UIButton (WAAdditions)

-(void)setWaLink:(NSString*)link
{
     [self setTitle:link forState:UIControlStateApplication];//Store the link here
    
}


- (NSString*) waLink
{
    return      [self titleForState:UIControlStateApplication];
}

-(void)setWaTitle:(NSString*)title
{
    
    //If xib title contains %@, do not override it
    NSString * xibTitle= [self titleForState:UIControlStateNormal];
    NSString *  xibAttTitle = [[self attributedTitleForState:UIControlStateNormal] string];
    NSRange rangeTitle = [xibTitle rangeOfString:@"%@"];
    if ((xibTitle) && (rangeTitle.location != NSNotFound)) {
        title= [NSString stringWithFormat:xibTitle,title];
        NSLog(@"New title %@",title);
    }
    NSRange rangeAttTitle = [xibAttTitle rangeOfString:@"%@"];
    if ((xibAttTitle) && (rangeAttTitle.location != NSNotFound)) {
        NSLog(@"xibAttTitle %@ location %i",xibAttTitle,rangeAttTitle.location);
        title= [NSString stringWithFormat:xibAttTitle,title];
        NSLog(@"New title %@",title);
    }
  

    //If title contains \, consider it's an rtf, and use attributed string
    NSRange range = [title rangeOfString:@"\\"];
    if (range.location == NSNotFound) {
        [self setTitle:title forState:UIControlStateNormal];
    } else {
        NSError *error = nil;
        //NSString * rtf = [@"test \n\\b \\i marche" stringWithRTFHeaderAndFooter];
        NSString * rtf = [[title stringFormattedRTF] stringWithRTFHeaderAndFooter];
        NSLog(@"rtf: %@",rtf);
        NSData * data = [rtf dataUsingEncoding:NSASCIIStringEncoding];
        NSAttributedString *attString = [[NSAttributedString alloc] initWithData:data options:@{NSDocumentTypeDocumentAttribute:NSRTFTextDocumentType} documentAttributes:nil error:&error];
        NSLog(@"Error initWithData:%@",error);
        
 
        //NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:title];
         //[attString addAttribute:NSFontAttributeName value:self.titleLabel.font range:range];
         
         [self setAttributedTitle:attString forState:UIControlStateNormal];
        [attString release];
        
    }

 /*
    
}


- (NSString*) waTitle
{
    return @"";//Will be done later if needed
    
}




@end;