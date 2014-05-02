/**
 ContentProvider is the protocol for custom reader for epub file.
 @author SkyTree
*/
@protocol ContentProvider
/**  path will be provided by engine. */
-(void)setContentPath:(NSString*)path;
/**  the length of content(file) should be returned. */
-(long long)lengthOfContent;
/**  you should return the offset of content */
-(long long)offsetOfContent;
/**  offset will be provided by skyepub engine. */
-(void)setOffsetOfContent:(long long)offset;
/**  the NSData for the content with the size of given length should be returned. */
-(NSData*)dataForContent:(long long)length;
/**  you should return whether reading content is finished or not. */
-(BOOL)isFinished;
@end