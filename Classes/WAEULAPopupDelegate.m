//
//  WAEULAPopupDelegate.m
//  Librelio
//
//  Created by Odin on 29/05/2017.
//  Copyright © 2017 WidgetAvenue - Librelio. All rights reserved.
//

#import "WAEULAPopupDelegate.h"


@implementation WAEULAPopupDelegate 


- (void)actionSheet:(UIActionSheet *)popup clickedButtonAtIndex:(NSInteger)buttonIndex {
	switch (buttonIndex) {
		case 0:
			[[SHKActivityIndicator currentIndicator] maintain];
			break;
		case 1:
			if ([popup numberOfButtons] > buttonIndex + 1) {
				NSLog(@"%@",@"EULAUrl");
				NSString* EULAUrl = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"EULAUrl"];
				/*NSString* EULAUrl = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"EULAUrla"];
				 if (EULAUrl == nil) {
					UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"erreur"
				 message:@"L'article dépasse la taille autorisée, il est impossible de l'envoyer" delegate:self cancelButtonTitle:@"OK"
				 otherButtonTitles:nil, nil];
					[alert show];
				 } else {
					[self performMenuButtonActionsFromURL:EULAUrl];
				 }*/
				[self performMenuButtonActionsFromURL:EULAUrl];
			}
		default:
			break;
	}
}

@end
