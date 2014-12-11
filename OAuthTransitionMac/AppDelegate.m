//
//  AppDelegate.m
//  OAuthTransitionMac
//
//  Created by Lukhnos D. Liu on 10/9/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "SampleAPIKey1.h"


static NSString *kCallbackURLBaseString = @"oatransdemo://callback";
static NSString *kOAuthAuth = @"OAuth";
static NSString *kFrobRequest = @"Frob";
static NSString *kTryObtainAuthToken = @"TryAuth";
static NSString *kTestLogin = @"TestLogin";
static NSString *kUpgradeToken = @"UpgradeToken";
static NSString *kUploadPhoto=@"UploadPhoto";
static NSString *kCreatePhotoSet=@"CreateSet";
static NSString *kAddToPhotoSet=@"AddToSet";
static NSString *kGotPhotoSet=@"GotSetsFromUser";
static NSString *kGetPublicPhoto=@"GetPublicPhoto";

static NSMutableArray * uplist;
static int uploadcount=0;
const NSTimeInterval kTryObtainAuthTokenInterval = 3.0;


@implementation AppDelegate
@synthesize oldStyleAuthButton = _oldStyleAuthButton;
@synthesize oauthAuthButton = _oauthAuthButton;
@synthesize testLoginButton = _testLoginButton;
@synthesize upgradeTokenButton = _upgradeTokenButton;
@synthesize progressLabel = _progressLabel;
@synthesize progressIndicator = _progressIndicator;
@synthesize window = _window;
@synthesize photosetid,photoid,foldername;
@synthesize webview;
@synthesize textview;
@synthesize filepath;
@synthesize mainView,loginView,uploadView;
@synthesize totoalphtcnt;
@synthesize uploadprogress;

-(BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    return YES;
}


-(void)awakeFromNib
{
    uplist =[[NSMutableArray alloc]init];
    [uploadView setHidden:true];
    [mainView addSubview:loginView];
    
}


- (void)handleIncomingURL:(NSAppleEventDescriptor *)event withReplyEvent:(NSAppleEventDescriptor *)replyEvent
{
    NSURL *callbackURL = [NSURL URLWithString:[[event paramDescriptorForKeyword:keyDirectObject] stringValue]];
    NSLog(@"Callback URL: %@", [callbackURL absoluteString]);
    
    NSString *requestToken= nil;
    NSString *verifier = nil;
    
    BOOL result = OFExtractOAuthCallback(callbackURL, [NSURL URLWithString:kCallbackURLBaseString], &requestToken, &verifier);
    if (!result) {
        NSLog(@"Invalid callback URL");
    }
              
    [_flickrRequest fetchOAuthAccessTokenWithRequestToken:requestToken verifier:verifier];
}
              


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	[[NSAppleEventManager sharedAppleEventManager] setEventHandler:self andSelector:@selector(handleIncomingURL:withReplyEvent:) forEventClass:kInternetEventClass andEventID:kAEGetURL];    
    
    //Flickr context created
    _flickrContext = [[OFFlickrAPIContext alloc] initWithAPIKey:OBJECTIVE_FLICKR_SAMPLE_API_KEY sharedSecret:OBJECTIVE_FLICKR_SAMPLE_API_SHARED_SECRET];
    
    //Flickr request created
    _flickrRequest = [[OFFlickrAPIRequest alloc] initWithAPIContext:_flickrContext];
    _flickrRequest.delegate = self;
    _flickrRequest.requestTimeoutInterval = 120.0;
    
    //Flickr AddtoSet request created
    _flickrAddToSetRequest = [[OFFlickrAPIRequest alloc] initWithAPIContext:_flickrContext];
    _flickrAddToSetRequest.delegate = self;
    _flickrAddToSetRequest.requestTimeoutInterval = 120.0;
    
    
    //Flickr CreateSet request created
    _flickrCreateSetRequest = [[OFFlickrAPIRequest alloc] initWithAPIContext:_flickrContext];
    _flickrCreateSetRequest.delegate = self;
    _flickrCreateSetRequest.requestTimeoutInterval = 120.0;
    
    //Flickr GetSet request created
    _flickrGetSet = [[OFFlickrAPIRequest alloc] initWithAPIContext:_flickrContext];
    _flickrGetSet.delegate = self;
    _flickrGetSet.requestTimeoutInterval = 120.0;
    
    //Flickr Get Public Photo request created.
  /*  _flickrGetPublicPhoto.sessionInfo=kGetPublicPhoto;
   _flickrGetPublicPhoto= [[OFFlickrAPIRequest alloc] initWithAPIContext:_flickrContext];
	[_flickrGetPublicPhoto setDelegate:self];
	[self nextPhotoAction:self];
	[[NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(nextPhotoAction:) userInfo:nil repeats:YES] fire];
	
    [webview setDrawsBackground:NO];
	*/
	[[self window] center];



}

//Working Perfect
- (IBAction)SelectFolder:(id)sender
{
    
    uploadcount=0;
    
    NSOpenPanel* openPanel = [NSOpenPanel openPanel];
    
    openPanel.title = @"Choose a file";
    openPanel.showsResizeIndicator = YES;
    openPanel.showsHiddenFiles = NO;
    openPanel.canChooseDirectories = YES;
    openPanel.canCreateDirectories = YES;
    openPanel.allowsMultipleSelection = NO;
    //openPanel.allowedFileTypes = @[@"txt"];
    [openPanel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result)
    {
        
        if (result==NSOKButton) {
            
            NSURL *selection = openPanel.URLs[0];
            NSString* path = [selection.path stringByResolvingSymlinksInPath];
            NSLog(@"%@",path);
            NSFileManager *fileManager = [[NSFileManager alloc] init];
            NSURL *directoryURL = selection;// URL pointing to the directory you want to browse
            NSArray *keys = [NSArray arrayWithObject:NSURLIsDirectoryKey];
            NSLog(@"DirectoryNAme==>%@",directoryURL);
            //filepath.v=[directoryURL absoluteString];
            [filepath setStringValue:[directoryURL absoluteString]];
            NSString *directory = [directoryURL  lastPathComponent];
            foldername=directory;

            
            NSDirectoryEnumerator *enumerator = [fileManager
                                                 enumeratorAtURL:directoryURL
                                                 includingPropertiesForKeys:keys
                                                 options:0
                                                 errorHandler:^(NSURL *url, NSError *error) {
                                                     // Handle the error.
                                                     // Return YES if the enumeration should continue after the error.
                                                     return YES;
                                                 }];
            
            for (NSURL *url in enumerator) {
                NSError *error;
                NSNumber *isDirectory = nil;
                if (! [url getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:&error]) {
                    // handle error
                }
                else if (! [isDirectory boolValue])
                {
                    // No error and it’s not a directory; do something with the file
                    NSLog(@"File Path==>%@",url.path);
                    
                    NSString * fn= url.path;
                    NSLog(@"Path extension==>%@",[fn pathExtension]);

                    if ([[fn pathExtension] isEqualToString:@"jpg"]||[[fn pathExtension] isEqualToString:@"png"]||[[fn pathExtension] isEqualToString:@"JPG"]||[[fn pathExtension] isEqualToString:@"mpeg"])
                        {
                         [uplist addObject:fn];
                            
                        }
                
                
                    
                 
                    
                }
            }
            totoalphtcnt=[uplist count];
            
            NSLog(@"Upload Queue Count==>%lu",[uplist count]);
            
            
            
        }
        
    }];
    
    
    
}

- (IBAction)oldStyleAuthentication:(id)sender
{
    [_progressIndicator startAnimation:self];
    [_progressLabel setStringValue:@"Starting old-style authentication..."];
    
    _flickrRequest.sessionInfo = kFrobRequest;
    [_flickrRequest callAPIMethodWithGET:@"flickr.auth.getFrob" arguments:nil];
    [_oauthAuthButton setEnabled:NO];
    [_oldStyleAuthButton setEnabled:NO];
}

- (IBAction)oauthAuthenticationAction:(id)sender
{
    [_progressIndicator startAnimation:self];
    [_progressLabel setStringValue:@"Starting OAuth authentication..."];

    _flickrRequest.sessionInfo = kOAuthAuth;
    [_flickrRequest fetchOAuthRequestTokenWithCallbackURL:[NSURL URLWithString:kCallbackURLBaseString]];
    [_oldStyleAuthButton setEnabled:NO];
    [_oauthAuthButton setEnabled:NO];
}

- (IBAction)testLoginAction:(id)sender
{
    if (_flickrContext.OAuthToken || _flickrContext.authToken) {
        _flickrRequest.sessionInfo = kTestLogin;
        [_flickrRequest callAPIMethodWithGET:@"flickr.test.login" arguments:nil];
        [_progressLabel setStringValue:@"Calling flickr.test.login..."];

        
        // this tests flickr.photos.getInfo
        /*
         NSString *somePhotoID = @"42";        
         [_flickrRequest callAPIMethodWithGET:@"flickr.photos.getInfo" arguments:[NSDictionary dictionaryWithObjectsAndKeys:somePhotoID, @"photo_id", nil]];
         [_progressLabel setStringValue:@"Calling flickr.photos.getInfo..."];

         */
        
        
        // this tests flickr.photos.setMeta, a method that requires POST
        /*
         NSString *somePhotoID = @"42";
         NSString *someTitle = @"Lorem iprum!";
         NSString *someDesc = @"^^ :)";
         NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                                somePhotoID, @"photo_id", 
                                someTitle, @"title",
                                someDesc, @"description",
                                nil];
         [_flickrRequest callAPIMethodWithPOST:@"flickr.photos.setMeta" arguments:params];
         [_progressLabel setStringValue:@"Calling flickr.photos.setMeta..."];

         */
        
         
        // test photo uploading
        
        // NSString *somePath = @"/tmp/test.png";
       /*  NSLog(@"Upload Started");
         NSString *somePath = @"/Users/betteradmin/Pictures/photos/images.jpeg";
         NSString *someFilename = @"Foo.jpeg";
         NSString *someTitle = @"Lorem iprum!";
         NSString *someDesc = @"^^ :)";
         NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                                someTitle, @"title",
                                someDesc, @"description",
                                nil];        
         [_flickrRequest uploadImageStream:[NSInputStream inputStreamWithFileAtPath:somePath] suggestedFilename:someFilename MIMEType:@"image/png" arguments:params];
         [_progressLabel setStringValue:@"Uploading photos..."];
        
        
        [_progressIndicator startAnimation:self];
        [_progressLabel setStringValue:@"Calling flickr.test.login..."];
        [_testLoginButton setEnabled:NO];
        */
    }
    else {
        NSRunAlertPanel(@"No Auth Token", @"Please authenticate first", @"Dismiss", nil, nil);
    }
}



-(void)CreateSet:(NSString *)Cphotoid
{
    NSString *somePhotoID = Cphotoid;
    NSString *someTitle = foldername;
    NSString *someDesc = @"";
    NSString * apikey=OBJECTIVE_FLICKR_SAMPLE_API_KEY;

    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            apikey,@"api_key",
                            someTitle, @"title",
                            someDesc, @"description",
                            somePhotoID,@"primary_photo_id",
                            nil];
    if([_flickrCreateSetRequest isRunning])
    {
        //Do nothing
        NSLog(@"Request is running");
    }
    else
    {
     NSLog(@"CreateSet function called");
    _flickrCreateSetRequest.sessionInfo=kCreatePhotoSet;
    [_flickrCreateSetRequest callAPIMethodWithPOST:@"flickr.photosets.create" arguments:params];
    }
}


-(void)AddPhotoToSet:(NSString *)uphotosetid withphotoid:(NSString *)uphotoid
{
    NSString *PhotoSetID=uphotosetid;
    NSString *PhotoID = uphotoid;
    NSString * apikey=OBJECTIVE_FLICKR_SAMPLE_API_KEY;
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            apikey,@"api_key",
                            PhotoSetID,@"photoset_id",
                            PhotoID,@"photo_id",
                            nil];
   // _flickrRequest.sessionInfo=kCreatePhotoSet;
    if([_flickrAddToSetRequest isRunning])
    {
        //Do nothing
        NSLog(@"Request is running");
    }
    else
    {
     NSLog(@"AddPhotoToSet function called");
    _flickrAddToSetRequest.sessionInfo=kAddToPhotoSet;
    [_flickrAddToSetRequest callAPIMethodWithPOST:@"flickr.photosets.addPhoto" arguments:params];
    }
    

    
}

- (IBAction)upgradeTokenAction:(id)sender
{
    if (_flickrContext.OAuthToken) {
        NSRunAlertPanel(@"Already Using OAuth", @"There's no need to upgrade to token", @"Dismiss", nil, nil);
    }
    else {
        _flickrRequest.sessionInfo = kUpgradeToken;
        [_flickrRequest callAPIMethodWithGET:@"flickr.auth.oauth.getAccessToken" arguments:nil];
        [_upgradeTokenButton setEnabled:NO];
    }
}


- (IBAction)uploadPhoto:(id)sender
{
   
   // NSString *dir = @"/Users/betteradmin/Pictures/photos";
    
  //  NSArray *children = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:dir error:nil];
    //for (NSString *filename in children)
    //{
     //NSLog(@"File from folder--> %@", filename);
    
   // NSString *somePath = @"/Users/betteradmin/Pictures/photos/3d_photoshop_nature_landscape_15285.png";
    
    /*NSURL *dirnm= [[NSURL alloc]initWithString:@"/Users/betteradmin/Pictures/photos"];
    
    NSMutableArray * filesToUpload;
    
    NSFileManager *fileManager = [[NSFileManager alloc] init];
                                  NSURL *directoryURL = dirnm;// URL pointing to the directory you want to browse
    NSArray *keys = [NSArray arrayWithObject:NSURLIsDirectoryKey];
    
    NSDirectoryEnumerator *enumerator = [fileManager
                                         enumeratorAtURL:directoryURL
                                         includingPropertiesForKeys:keys
                                         options:0
                                         errorHandler:^(NSURL *url, NSError *error) {
                                             // Handle the error.
                                             // Return YES if the enumeration should continue after the error.
                                             return YES;
                                         }];
    
    for (NSURL *url in enumerator)
    {
        NSError *error;
        NSNumber *isDirectory = nil;
        if (! [url getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:&error]) {
            // handle error
        }
        else if (! [isDirectory boolValue]) {
            // No error and it’s not a directory; do something with the file
            NSString * filename= [url absoluteString];
            NSLog(@"File from Folder----->%@",filename);

            //NSRange rangeOfSubstring = [filename rangeOfString:@"file://"];
           // NSString * finalfilenm=[filename substringToIndex:rangeOfSubstring.location];
            
            NSString * finalfilenm=[filename stringByReplacingOccurrencesOfString:@"file://" withString:@""];
            NSLog(@"File from Folder----->%@",finalfilenm);
            filesToUpload= [[NSMutableArray alloc]initWithObjects:@"/Users/betteradmin/Pictures/photos/3d_photoshop_nature_landscape_15285.png",@"/Users/betteradmin/Pictures/photos/images.jpeg", nil];
           // [filesToUpload addObject:finalfilenm];
            //[filesToUpload addObject:@"/Users/betteradmin/Pictures/photos/3d_photoshop_nature_landscape_15285.png"];
            
            
            
        }
        
       }
     */
   //[self CreateSet];
   // First photo in the list getting uploaded
    
    NSString *apikey =OBJECTIVE_FLICKR_SAMPLE_API_KEY;
    // NSString *someTitle = @"My  PreUploadMac!";
    //NSString *someDesc = @"^^ :)";
    NSDictionary *getsetparams = [NSDictionary dictionaryWithObjectsAndKeys:
                                  apikey, @"api_key",
                                  nil];
    _flickrGetSet.sessionInfo=kGotPhotoSet;
    [_flickrGetSet callAPIMethodWithPOST:@"flickr.photosets.getList" arguments:getsetparams];
    

    
    [self MyUpload:uplist withindex:0];
    
    
    [_progressLabel setStringValue:@"Uploading photos..."];

    
    [_progressIndicator startAnimation:self];
    [_progressLabel setStringValue:@"Calling flickr.test.login..."];
    [_testLoginButton setEnabled:NO];

}

-(void)MyUpload:(NSMutableArray *)arr withindex:(int)i;
{
    
    
        NSLog(@"FileName=%@",[arr objectAtIndex:(i)]);
        NSString *someFilename = @"Foo.png";
        NSString *someTitle = @"My  PreUploadMac!";
        NSString *someDesc = @"^^ :)";
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                                someTitle, @"title",
                                someDesc, @"description",
                                nil];
    

        if([_flickrRequest isRunning])
        {
            //Do nothing
            NSLog(@"Request is running");
        }
        else
        {
            NSLog(@"Upload function called");
            _flickrRequest.sessionInfo=kUploadPhoto;
            [_flickrRequest uploadImageStream:[NSInputStream inputStreamWithFileAtPath:[arr objectAtIndex:(i)]] suggestedFilename:someFilename MIMEType:@"image/png" arguments:params];
        }
    
    
    
    

    
}




- (void)tryObtainAuthToken
{
    _flickrRequest.sessionInfo = kTryObtainAuthToken;
    [_flickrRequest callAPIMethodWithGET:@"flickr.auth.getToken" arguments:[NSDictionary dictionaryWithObjectsAndKeys:_frob, @"frob", nil]];
}


- (void)flickrAPIRequest:(OFFlickrAPIRequest *)inRequest didObtainOAuthRequestToken:(NSString *)inRequestToken secret:(NSString *)inSecret;
{
    _flickrContext.OAuthToken = inRequestToken;
    _flickrContext.OAuthTokenSecret = inSecret;
    
    NSURL *authURL = [_flickrContext userAuthorizationURLWithRequestToken:inRequestToken requestedPermission:OFFlickrWritePermission];
    NSLog(@"Auth URL: %@", [authURL absoluteString]);
    [[NSWorkspace sharedWorkspace] openURL:authURL];
    
    [_progressLabel setStringValue:@"Waiting fo user authentication (OAuth)..."];    
}

- (void)flickrAPIRequest:(OFFlickrAPIRequest *)inRequest didObtainOAuthAccessToken:(NSString *)inAccessToken secret:(NSString *)inSecret userFullName:(NSString *)inFullName userName:(NSString *)inUserName userNSID:(NSString *)inNSID
{
    _flickrContext.OAuthToken = inAccessToken;
    _flickrContext.OAuthTokenSecret = inSecret;

    NSLog(@"Token: %@, secret: %@", inAccessToken, inSecret);    
    
    [_progressLabel setStringValue:@"Authenticated"];
    [loginView setHidden:true];
    [uploadView setHidden:false];
    [mainView addSubview:uploadView];
    
    //Flickr Get Public Photo request created.
     _flickrGetPublicPhoto.sessionInfo=kGetPublicPhoto;
     _flickrGetPublicPhoto= [[OFFlickrAPIRequest alloc] initWithAPIContext:_flickrContext];
     [_flickrGetPublicPhoto setDelegate:self];
     [self nextPhotoAction:self];
     [[NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(nextPhotoAction:) userInfo:nil repeats:YES] fire];
     [webview setDrawsBackground:NO];
    

    
    [_progressIndicator stopAnimation:self];
    [_testLoginButton setEnabled:YES];
    NSRunAlertPanel(@"Authenticated", [NSString stringWithFormat:@"OAuth access token: %@, secret: %@", inAccessToken, inSecret], @"Dismiss", nil, nil);
    
    
    
}

- (void)flickrAPIRequest:(OFFlickrAPIRequest *)inRequest didCompleteWithResponse:(NSDictionary *)inResponseDictionary
{
      
    
    
    if(inRequest==_flickrGetPublicPhoto)
    {
       NSDictionary *photoDict = [[inResponseDictionary valueForKeyPath:@"photos.photo"] objectAtIndex:0];
        
        NSString *title = [photoDict objectForKey:@"title"];
        if (![title length]) {
            title = @"No title";
        }
        
        NSURL *photoSourcePage = [_flickrContext photoWebPageURLFromDictionary:photoDict];
        NSDictionary *linkAttr = [NSDictionary dictionaryWithObjectsAndKeys:photoSourcePage, NSLinkAttributeName, nil];
        
        NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:title attributes:linkAttr];
        [[textview textStorage] setAttributedString:attrString];
        
        NSURL *photoURL = [_flickrContext photoSourceURLFromDictionary:photoDict size:OFFlickrLargeSize];
        NSString *htmlSource = [NSString stringWithFormat:
                                @"<html>"
                                @"<head>"
                                @"  <style>body { margin: 0; padding: 0; } </style>"
                                @"</head>"
                                @"<body>"
                                @"  <table border=\"0\" align=\"center\" valign=\"center\" cellspacing=\"0\" cellpadding=\"0\" height=\"360\">"
                                @"    <tr><td><img src=\"%@\" /></td></tr>"
                                @"  </table>"
                                @"</body>"
                                @"</html>"
                                , photoURL];
        
        [[webview mainFrame] loadHTMLString:htmlSource baseURL:nil];
    
        
    }
    
  //  if(inRequest.sessionInfo==kCreatePhotoSet)
    
    if (inRequest==_flickrGetSet)
    {
        NSLog(@"GetPhotoSet Api called");
        //NSString * photosetGet =[[inResponseDictionary objectForKey:@"photosets"]objectForKey:@"photoset"];
        NSMutableArray *photoset= [[NSMutableArray alloc] initWithArray:[[inResponseDictionary objectForKey:@"photosets"]objectForKey:@"photoset"]];
        NSDictionary * mysets= [[NSDictionary alloc]init];
       for(mysets in photoset)
        {
            //NSLog(@"My Dictionary=%@",mysets);
            id albumtitle= [[mysets objectForKey:@"title"]objectForKey:@"_text"];
            NSLog(@"My Album Title=%@",albumtitle);

 
        }
      //  NSLog(@"Set Array=%@",photoset);
       // photosetid=photosetRes; 
    }
    
    if (inRequest==_flickrCreateSetRequest)
    {
        NSLog(@"CreatePhotoSet Api called");
        NSString * photosetRes =[[inResponseDictionary objectForKey:@"photoset"]objectForKey:@"id"];
        NSLog(@"Response=%@",photosetRes);
        photosetid=photosetRes;
    }
    
    if(inRequest.sessionInfo==kUploadPhoto)
    {
        NSLog(@"UploadingPhoto Api called");
        NSString * photoidRes =[[inResponseDictionary objectForKey:@"photoid"]objectForKey:@"_text"];
        NSLog(@"Response=%@",photoidRes);
        uploadcount++;
        NSLog(@"So far photo uploaded==%d out of %d",uploadcount,totoalphtcnt);
       // NSMutableString  *selectDay=@"So far photo uploaded==";
       // NSString * newString = [NSString stringWithFormat:@"%@%i", uploadcount, totoalphtcnt];
        //NSLog(@"%@", newString);
        
        NSMutableString  *selectDay=@"So far photo uploaded  ";
        NSString *newString = [selectDay stringByAppendingFormat:@"%i / %i", uploadcount,totoalphtcnt];
        NSLog(@"%@", newString);
        [uploadprogress setStringValue:newString];
        if(uploadcount==1)
        {
            [self CreateSet:photoidRes];
        }
        else
        {
            NSLog(@"Photo Set created with id==%@",photosetid);
            [self AddPhotoToSet:photosetid withphotoid:photoidRes];
            
         }
        
        if(!uplist||!uplist.count)
        {
            NSLog(@"Upload Queue empty");
        }
        if(uplist||uplist.count)
        {
            
            int i=0;
            [uplist removeObjectAtIndex:i];
            if(uplist.count!=0)
            {
                [self MyUpload:uplist withindex:(i)];
                //[self AddPhotoToSet:photosetid withphotoid:photoid];
                
            }
        }
        else
        {
            NSLog(@"Upload Queue empty");
            NSLog(@"Photo uploaded==%d",uploadcount);
            
        }
        
        //photoid=photoidRes;
      //  [self CreateSet:photoid];
           
    }
        
    if(inRequest==_flickrAddToSetRequest)
    {
        NSLog(@"AddToPhotoset Api called");
       // NSLog(@"%s, ResponseFromreturn: %@", __PRETTY_FUNCTION__, inResponseDictionary);

    }
    
    
    
    NSLog(@"%s, return: %@", __PRETTY_FUNCTION__, inResponseDictionary);
    
    [_progressIndicator stopAnimation:self];
    [_progressLabel setStringValue:@"API call succeeded"];
    
    
    
    
    
    if (inRequest.sessionInfo == kFrobRequest)
    {
        _frob = [[inResponseDictionary valueForKeyPath:@"frob._text"] copy];
        NSLog(@"%@: %@", kFrobRequest, _frob);
        
        NSURL *authURL = [_flickrContext loginURLFromFrobDictionary:inResponseDictionary requestedPermission:OFFlickrWritePermission];
        [[NSWorkspace sharedWorkspace] openURL:authURL];
        
        [self performSelector:@selector(tryObtainAuthToken) withObject:nil afterDelay:kTryObtainAuthTokenInterval];
        
        [_progressIndicator startAnimation:self];
        [_progressLabel setStringValue:@"Waiting for user authentication..."];
    }
    else if (inRequest.sessionInfo == kTryObtainAuthToken)
    {
        NSString *authToken = [inResponseDictionary valueForKeyPath:@"auth.token._text"];
        NSLog(@"%@: %@", kTryObtainAuthToken, authToken);
        
        _flickrContext.authToken = authToken;
        _flickrRequest.sessionInfo = nil;
        
        [_upgradeTokenButton setEnabled:YES];
        [_testLoginButton setEnabled:YES];
    }
    else if (inRequest.sessionInfo == kUpgradeToken)
    {
        NSString *oat = [inResponseDictionary valueForKeyPath:@"auth.access_token.oauth_token"];
        NSString *oats = [inResponseDictionary valueForKeyPath:@"auth.access_token.oauth_token_secret"];
        
        _flickrContext.authToken = nil;
        _flickrContext.OAuthToken = oat;
        _flickrContext.OAuthTokenSecret = oats;
        NSRunAlertPanel(@"Auth Token Upgraded", [NSString stringWithFormat:@"New OAuth token: %@, secret: %@", oat, oats], @"Dismiss", nil, nil);
        
        [_oldStyleAuthButton setEnabled:NO];
        [_upgradeTokenButton setEnabled:NO];
    }
    else if (inRequest.sessionInfo == kTestLogin)
    {
        _flickrRequest.sessionInfo = nil;
        [_testLoginButton setEnabled:YES];
        NSRunAlertPanel(@"Test OK!", @"API returns successfully", @"Dismiss", nil, nil);
    }
}

- (void)flickrAPIRequest:(OFFlickrAPIRequest *)inRequest didFailWithError:(NSError *)inError
{
    NSLog(@"%s, error: %@", __PRETTY_FUNCTION__, inError);
    
    if (inRequest.sessionInfo == kTryObtainAuthToken) {
        [self performSelector:@selector(tryObtainAuthToken) withObject:nil afterDelay:kTryObtainAuthTokenInterval];        
    }
    else {
        if (inRequest.sessionInfo == kOAuthAuth || inRequest.sessionInfo == kFrobRequest || inRequest.sessionInfo == kTryObtainAuthToken) {
            [_oldStyleAuthButton setEnabled:YES];
            [_oauthAuthButton setEnabled:YES];
            [_testLoginButton setEnabled:NO];
            [_upgradeTokenButton setEnabled:NO];
        }
        else if (inRequest.sessionInfo == kUpgradeToken) {
            [_upgradeTokenButton setEnabled:YES];
        }
        else if (inRequest.sessionInfo == kTestLogin) {
            [_testLoginButton setEnabled:YES];
        }
        
        [_progressIndicator stopAnimation:self];
        [_progressLabel setStringValue:@"Error"];
        NSRunAlertPanel(@"API Error", [NSString stringWithFormat:@"An error occurred in the stage \"%@\", error: %@", inRequest.sessionInfo, inError], @"Dismiss", nil, nil);
    }
}



- (void)flickrAPIRequest:(OFFlickrAPIRequest *)inRequest imageUploadSentBytes:(NSUInteger)inSentBytes totalBytes:(NSUInteger)inTotalBytes
{
    NSLog(@"%s %lu/%lu", __PRETTY_FUNCTION__, inSentBytes, inTotalBytes);
}



- (IBAction)nextPhotoAction:(id)sender {
    
    if (![_flickrGetPublicPhoto isRunning]) {
		[_flickrGetPublicPhoto callAPIMethodWithGET:@"flickr.photos.getRecent" arguments:[NSDictionary dictionaryWithObjectsAndKeys:@"1", @"per_page", nil]];
	}
    
}
@end
