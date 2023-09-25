//
//  FaceViewController.m
//  flutterindia
//
//  Created by admin on 2023/9/1.
//

#import "FaceViewController.h"
#import "DFActionfaceViewController.h"
#import "DFActionLivenessController.h"
#import "DFLivenessCommon.h"
#import "NSBundle+Localization.h"
#import "DFAlertView.h"
#import <FlutterBoost.h>

@interface FaceViewController () <DFActionLivenessDelegate, DFAlertViewDelegate>


@property (nonatomic, copy) NSString *version;

@property (nonatomic, weak) DFActionLivenessController *actionVC;

@end

@implementation FaceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"viewDidLoad");
    // Do any additional setup after loading the view.
    DFActionLivenessController *actionVC = [[DFActionLivenessController alloc] init];
    actionVC.modalPresentationStyle = UIModalPresentationFullScreen;
    self.actionVC = actionVC;
    self.version = [actionVC getLivenessVersion];
    actionVC.delegate = self;
    
    NSDictionary *dictJson = @{@"sequence": @[@"HOLDSTILL", @"BLINK", @"MOUTH", @"NOD", @"YAW"],
                               @"outType": @"multiImg",
                               @"threshold": @[@(0.7), @(0.7), @(0.7), @(0.7), @(0.7)],
                               @"autoAntiHack": @(YES)};
    NSString *strJson = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:dictJson options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding];
    [actionVC setJsonCommand:strJson];
    [self.navigationController presentViewController:actionVC animated:NO completion:^{
        [self restart];
    }];
    
}

- (void)restart
{
    [self.actionVC restart];
}

/**
 *  Action detecting successfully callback when set autoAntiHack to NO
 *  @param data       Pass back the encrypted binary data
 *  @param arrDFImage Return the DFImage array according to the specified output scheme. See DFImage.h for the DFImage property
 *  @param dfVideoData Return NSData video data according to the specified output scheme(nil)
 */
- (void)actionLivenessDidSuccessfulGetData:(NSData *)encryTarData
                                  dfImages:(NSArray *)arrDFImage
                               dfVideoData:(NSData *)dfVideoData {
    NSLog(@"actionLivenessDidSuccessfulGetData1");
    
}

/**
 *  Action detecting successfully callback when set autoAntiHack to YES
 *  @param data       Pass back the encrypted binary data
 *  @param arrDFImage Return the DFImage array according to the specified output scheme. See DFImage.h for the DFImage property
 *  @param dfVideoData Return NSData video data according to the specified output scheme(nil)
 *  @param isHack  Is a hack user or not.
 */
- (void)actionLivenessDidSuccessfulGetData:(NSData *)encryTarData
                                  dfImages:(NSArray *)arrDFImage
                               dfVideoData:(NSData *)dfVideoData
                                    isHack:(BOOL)isHack{
    NSLog(@"actionLivenessDidSuccessfulGetData2");
    NSString *strFileName = @"liveness_video.mp4";
    
    UIImage *firstImage = nil;
    NSData *imageData = nil;
    if ([arrDFImage count]) {
        firstImage = ((DFImage *)[arrDFImage firstObject]).image;
        if (firstImage) {
            //NSArray *imagePathArray = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
            //NSString *imagePath = [[imagePathArray firstObject] stringByAppendingPathComponent:@"liveness_protobuf"];
            //NSString *imagePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"faceImage.png"];
            imageData = UIImageJPEGRepresentation(firstImage, 0.3f);
            
            //[UIImagePNGRepresentation(firstImage) writeToFile:imagePath atomically:YES];
        }
    }
    
    //[[NSFileManager defaultManager] createFileAtPath:[NSString pathWithComponents:@[NSTemporaryDirectory() , strFileName]] contents:dfVideoData attributes:nil];
    
    //NSArray *pathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    //NSString *dataPath = [[pathArray firstObject] stringByAppendingPathComponent:@"liveness_protobuf"];
    //[encryTarData writeToFile:dataPath atomically:YES];
    [FlutterBoost.instance sendEventToFlutterWith:@"faceData" arguments:@{@"protobuf": encryTarData, @"image": imageData}];
    [_actionVC dismissViewControllerAnimated:YES completion:^{
        [self.navigationController popViewControllerAnimated:YES];
    }];
}

/**
 *  Action detecting failed callback
 *
 *  @param iErrorType      Type of failure
 *  @param iDetectionType  Detection module type on failure
 *  @param iIndex          The index of the detection module in the action sequence when it fails, starting from 0
 *  @param encryTarData    Pass back the encrypted binary data
 *  @param arrDFImage      Return the DFImage array according to the specified output scheme. See DFImage.h for the DFImage property
 *  @param dfVideoData     Return NSData video data according to the specified output scheme(nil)
 */
- (void)actionLivenessDidFailWithType:(DFActionLivenessError)iErrorType
                        DetectionType:(DFDetectionType)iDetectionType
                       DetectionIndex:(NSInteger)iIndex
                                 Data:(NSData *)encryTarData
                             dfImages:(NSArray *)arrDFImage
                          dfVideoData:(NSData *)dfVideoData{
    NSLog(@"actionLivenessDidFailWithType");
    if (iErrorType == DFActionLivenessFaceChanged && iIndex == 0) {
        [self restart];
        return;
    }
    switch (iErrorType) {
            
            case DFActionLivenessInitFaild: {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:DFLOCALIZATION(@"DFLivenessTipInitFaild") delegate:self cancelButtonTitle:DFLOCALIZATION(@"DFLivenessCancel") otherButtonTitles:nil, nil];
                [alert show];
            }
            break;
            
            case DFActionLivenessCameraError: {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:DFLOCALIZATION(@"DFLivenessTipCameraError") delegate:self cancelButtonTitle:DFLOCALIZATION(@"DFLivenessCancel") otherButtonTitles:nil, nil];
                [alert show];
            }
            break;
            
            case DFActionLivenessFaceChanged: {
                DFAlertView *alert = [[DFAlertView alloc] initWithTitle:DFLOCALIZATION(@"DFLivenessTipFaceChanged") delegate:self];
                [alert showOnView:[UIApplication sharedApplication].keyWindow];
            }
            break;
            
            case DFActionLivenessTimeOut: {
                DFAlertView *alert = [[DFAlertView alloc] initWithTitle:DFLOCALIZATION(@"DFLivenessTipTimeOut") delegate:self];
                [alert showOnView:[UIApplication sharedApplication].keyWindow];
                
            }
            break;
            
            case DFActionLivenessWillResignActive: {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:DFLOCALIZATION(@"DFLivenessTipWillResignActive") delegate:self cancelButtonTitle:DFLOCALIZATION(@"DFLivenessCancel") otherButtonTitles:DFLOCALIZATION(@"DFLivenessConfirm"), nil];
                [alert show];
            }
            break;
            
            case DFActionLivenessInternalError: {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:DFLOCALIZATION(@"DFLivenessTipInternalError") delegate:self cancelButtonTitle:DFLOCALIZATION(@"DFLivenessCancel") otherButtonTitles:nil, nil];
                [alert show];
            }
            break;
            
            case DFActionLivenessBadJson: {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:DFLOCALIZATION(@"DFLivenessTipBadJson") delegate:self cancelButtonTitle:DFLOCALIZATION(@"DFLivenessCancel") otherButtonTitles:nil, nil];
                [alert show];
                return;
            }
            break;
            
            case DFActionLivenessBundleIDError: {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:DFLOCALIZATION(@"DFLivenessTipBundleIDError") delegate:self cancelButtonTitle:DFLOCALIZATION(@"DFLivenessCancel") otherButtonTitles:nil, nil];
                [alert show];
                return;
            }
            break;
            
            case DFActionLivenessSequenceError: {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:DFLOCALIZATION(@"DFLivenessTipSequenceError") delegate:self cancelButtonTitle:DFLOCALIZATION(@"DFLivenessCancel") otherButtonTitles:nil, nil];
                [alert show];
                return;
            }
            break;
            case DFActionLivenessAuthExpire: {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:DFLOCALIZATION(@"DFLivenessTipAuthExpire") delegate:self cancelButtonTitle:DFLOCALIZATION(@"DFLivenessCancel") otherButtonTitles:nil, nil];
                [alert show];
                return;
            }
            break;
            case DFActionLivenessFaceMoreThanOneError: {
                DFAlertView *alert = [[DFAlertView alloc] initWithTitle:DFLOCALIZATION(@"DFLivenessTipFaceMoreThanOneError") delegate:self];
                [alert showOnView:[UIApplication sharedApplication].keyWindow];
            }
            break;
            case DFActionLivenessLicenseInvalid: {
                DFAlertView *alert = [[DFAlertView alloc] initWithTitle:DFLOCALIZATION(@"DFLivenessTipLicenseInvalid") delegate:self];
                [alert showOnView:[UIApplication sharedApplication].keyWindow];
            }
                break;
        default:
            break;
    }

}

/**
 *  Cancel the action detection callback
 */
- (void)actionLivenessDidCancel{
    NSLog(@"actionLivenessDidCancel");
    [_actionVC dismissViewControllerAnimated:YES completion:^{
        [self.navigationController popViewControllerAnimated:YES];
    }];
}


- (void)alertView:(DFAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0: {
            [self.actionVC cancel];
        }
            break;
        case 1: {
            [self restart];
        }
            break;
            
        default: {
            [self.actionVC cancel];
        }
            break;
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0: {
            [self.actionVC cancel];
        }
            break;
        case 1: {
            [self restart];
        }
            break;
            
        default: {
            [self.actionVC cancel];
        }
            break;
    }
}
@end
