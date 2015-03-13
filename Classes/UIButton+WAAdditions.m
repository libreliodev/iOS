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
    
    NSRange range = [title rangeOfString:@"Test"];
    if (range.location == NSNotFound) {
        [self setTitle:title forState:UIControlStateNormal];
    } else {
        NSLog(@"string contains needle!");
        NSError *error = nil;
        
        //NSString * rtf = [title stringWithRTFHeader];
        NSString * rtf = [@"test \n\\b \\i marche" stringWithRTFHeaderAndFooter];
        NSLog(@"rtf: %@",rtf);
        NSData * data = [rtf dataUsingEncoding:NSASCIIStringEncoding];
        NSAttributedString *attString = [[NSAttributedString alloc] initWithData:data options:@{NSDocumentTypeDocumentAttribute:NSRTFTextDocumentType} documentAttributes:nil error:&error];
        NSLog(@"Error initWithData:%@",error);
        
 
        //NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:title];
         //[attString addAttribute:NSFontAttributeName value:self.titleLabel.font range:range];
         
         [self setAttributedTitle:attString forState:UIControlStateNormal];
        [attString release];
        
         //[[self.resolveButton titleLabel] setNumberOfLines:0];
         //[[self.resolveButton titleLabel] setLineBreakMode:NSLineBreakByWordWrapping];*/

    }
    
    
}


- (NSString*) waTitle
{
    return @"";//Will be done later if needed
    
}




@end;