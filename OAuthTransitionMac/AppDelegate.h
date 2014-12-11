//
//  AppDelegate.h
//  OAuthTransitionMac
//
//  Created by Lukhnos D. Liu on 10/9/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ObjectiveFlickr/ObjectiveFlickr.h"
#import <WebKit/WebKit.h>

@interface AppDelegate : NSObject <NSApplicationDelegate, OFFlickrAPIRequestDelegate>
{
    OFFlickrAPIContext *_flickrContext;
    OFFlickrAPIRequest *_flickrRequest;
    OFFlickrAPIRequest *_flickrAddToSetRequest;
    OFFlickrAPIRequest *_flickrCreateSetRequest;
    OFFlickrAPIRequest *_flickrGetSet;
    OFFlickrAPIRequest *_flickrGetPublicPhoto;
    
    NSString *_frob;
}
@property (assign) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSView *mainView;
@property (weak) IBOutlet NSView *uploadView;
@property (weak) IBOutlet NSView *loginView;
@property (weak) IBOutlet NSTextField *uploadprogress;

@property (assign) IBOutlet NSButton *oauthAuthButton;
@property (assign) IBOutlet NSButton *oldStyleAuthButton;
@property (assign) IBOutlet NSButton *testLoginButton;
@property (assign) IBOutlet NSButton *upgradeTokenButton;
@property (assign) IBOutlet NSTextField *progressLabel;
@property (assign) IBOutlet NSProgressIndicator *progressIndicator;
@property NSString * photosetid;
@property NSString * photoid;
@property NSString * foldername;
@property int totoalphtcnt;
@property (weak) IBOutlet WebView *webview;
@property (unsafe_unretained) IBOutlet NSTextView *textview;

- (IBAction)nextPhotoAction:(id)sender;

@property (weak) IBOutlet NSTextField *filepath;
- (IBAction)SelectFolder:(id)sender;

- (IBAction)oldStyleAuthentication:(id)sender;
- (IBAction)oauthAuthenticationAction:(id)sender;
- (IBAction)testLoginAction:(id)sender;
- (IBAction)upgradeTokenAction:(id)sender;
- (IBAction)uploadPhoto:(id)sender;

-(void)MyUpload:(NSMutableArray *)arr withindex:(int)i;
-(void)CreateSet:(NSString *)Cphotoid;
-(void)AddPhotoToSet:(NSString *)uphotosetid withphotoid:(NSString *)uphotoid;

@end
