#import "RNInstagramShare.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <QuartzCore/QuartzCore.h>

@interface RNInstagramShare ()

@property (nonatomic, strong) RCTResponseSenderBlock callback;
@property (nonatomic, strong) NSDictionary *defaultOptions;
@property (nonatomic, retain) NSMutableDictionary *options, *response;
@property (nonatomic, retain) UIDocumentInteractionController *documentController;


@end

@implementation RNInstagramShare

RCT_EXPORT_MODULE();

RCT_EXPORT_METHOD(createPost:(NSDictionary *)options callback:(RCTResponseSenderBlock)callback)
{
    callback(@[@([self instaGramWallPostWithURL:[options objectForKey:@"url"]])]);
}

- (NSString*)urlencodedString:(NSString*)instring
{
    return [instring stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
}

-(BOOL)instaGramWallPostWithURL: (NSString*) url
{
    NSURL *myURL = [NSURL URLWithString:url];
    NSData * imageData = [[NSData alloc] initWithContentsOfURL:myURL];
    UIImage *imgShare = [[UIImage alloc] initWithData:imageData];
    
    NSURL *instagramURL = [NSURL URLWithString:@"instagram://app"];
    
    if([[UIApplication sharedApplication] canOpenURL:instagramURL]) //check for App is install or not
    {
        UIImage *imageToUse = imgShare;
        NSString *documentDirectory=[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        NSString *saveImagePath=[documentDirectory stringByAppendingPathComponent:@"Image.igo"];
        NSData *imageData=UIImagePNGRepresentation(imageToUse);
        [imageData writeToFile:saveImagePath atomically:YES];
        NSURL *imageURL=[NSURL fileURLWithPath:saveImagePath];
        self.documentController=[[UIDocumentInteractionController alloc]init];
        self.documentController = [UIDocumentInteractionController interactionControllerWithURL:imageURL];
        self.documentController.delegate = self;
        self.documentController.annotation = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"Testing"], @"InstagramCaption", nil];
        self.documentController.UTI = @"com.instagram.exclusivegram";
        UIViewController *vc = [UIApplication sharedApplication].keyWindow.rootViewController;
        // [self.documentController presentOpenInMenuFromRect:CGRectMake(1, 1, 1, 1) inView:vc.view animated:YES];

        UIImage * im = imgShare;

        // new way skip sharing controller go direct to instagram

        // better just wait here

        __block BOOL done = NO;

        __block NSString * eurlInputImage = nil;

        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];

        [library writeImageToSavedPhotosAlbum:im.CGImage
                                  orientation:(ALAssetOrientation)(im.imageOrientation)
                              completionBlock:^(NSURL *assetURL, NSError *error) {

                                  NSLog(@"inputImage assetURL %@", assetURL);

                                  // pass out of block
                                  NSString * eurlInputImage = [self urlencodedString:assetURL.absoluteString];


                                  NSLog(@"inputImage assetURL encoded %@", eurlInputImage);


                                  NSString * eurl = eurlInputImage;

                                  NSString * caption = @""; // no longer supported picopt.instagramCaption;

                                  NSString * ecaption = [self urlencodedString:caption];

                                  NSString * iurl = [NSString stringWithFormat:@"instagram://library?AssetPath=%@&InstagramCaption=%@", eurl, ecaption];

                                  printf("ready to launch instagram for inputImage, is main thread = %d\n", [NSThread isMainThread]);

                                  [[UIApplication sharedApplication] openURL:[NSURL URLWithString:iurl]];

                                  done = YES;

                             }]; // writeImageToSaved


        return YES;
    } else {
        return NO;
    }
}

@end


