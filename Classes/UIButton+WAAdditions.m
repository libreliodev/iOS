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
    
    //If xib title contains %@, do not override it, replace %@ with title
    NSString * xibTitle= [self titleForState:UIControlStateNormal];
    NSRange rangeTitle = [xibTitle rangeOfString:@"%@"];
    if ((xibTitle) && (rangeTitle.location != NSNotFound)) {
        title= [xibTitle stringByReplacingOccurrencesOfString:@"%@" withString:title];
    }
    [self setTitle:title forState:UIControlStateNormal];


    NSString *  xibAttTitle = [[self attributedTitleForState:UIControlStateNormal]string];
    NSRange rangeAttTitle = [xibAttTitle rangeOfString:@"%@"];
    if ((xibAttTitle) && (rangeAttTitle.location != NSNotFound)) {
        NSMutableAttributedString * newAttString = [[NSMutableAttributedString alloc]initWithAttributedString:[self attributedTitleForState:UIControlStateNormal]];
        [[newAttString mutableString] replaceOccurrencesOfString:@"%@" withString:title options:NSCaseInsensitiveSearch range:NSMakeRange(0, newAttString.string.length)];
        [self setAttributedTitle:newAttString forState:UIControlStateNormal];
        [newAttString release];
    }
    else{
        //This should never happen, use attributed strings only with %@
    }
  

    //No longer useed, kept for future reference
    /*    NSError *error = nil;
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
        
    }*/

    
}


- (NSString*) waTitle
{
    return @"";//Will be done later if needed
    
}




@end;