//
//  BarCodeViewController.m
//  SimiCartPluginFW
//
//  Created by Nghieply91 on 1/20/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import "BarCodeViewController.h"
#import <SimiCartBundle/SCProductViewController.h>
#import <SimiCartBundle/SCProductViewControllerPad.h>

#define PreviewFrame self.view.frame
#define ImageCanvasFrame UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone? CGRectMake(0, 90, 320, 270):CGRectMake(337, 200, 350, 350)
#define ButtonFlashFrame  UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone?CGRectMake(60, 40, 80, 30):CGRectMake(0, 0, 0, 0)
#define ButtonPhotoFrame  UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone?CGRectMake(190, 40, 80, 30):CGRectMake(880, 90, 80, 30)
#define ImageBackgroundHeader UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone? CGRectMake(0, 0, 320, 90):CGRectMake(0, 0, 1024, 200)
#define ImageBackgroundFooter UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone? CGRectMake(0, 360, 320, 200):CGRectMake(0, 550, 1024, 218)
#define BackGroundColor UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone?[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5]:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.7]

@interface BarCodeViewController ()
@end

@implementation BarCodeViewController
- (void)viewDidLoadBefore
{
    [super viewDidLoadBefore];
    _previewView = [UIView new];
    isFistLoad = YES;
    
    _imgCanvas = [UIImageView new];
    [_imgCanvas setImage:[UIImage imageNamed:@"barcode_canvas"]];
    [_imgCanvas setBackgroundColor:[UIColor clearColor]];
    
    _btnFlash = [UIButton new];
    [_btnFlash setImage:[UIImage imageNamed:@"barcode_flashicon"] forState:UIControlStateNormal];
    [_btnFlash addTarget:self action:@selector(didTapButtonFlash) forControlEvents:UIControlEventTouchUpInside];
    
    _btnPhoto = [UIButton new];
    [_btnPhoto setImage:[UIImage imageNamed:@"barcode_photoicon"] forState:UIControlStateNormal];
    [_btnPhoto addTarget:self action:@selector(didTapButtonPhoto) forControlEvents:UIControlEventTouchUpInside];
    
    _imgBackgroundHeader = [UIImageView new];
    [_imgBackgroundHeader setBackgroundColor:BackGroundColor];
    
    _imgBackgroundFooter = [UIImageView new];
    [_imgBackgroundFooter setBackgroundColor:BackGroundColor];
    
    _activityIndicatorView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    _activityIndicatorView.hidesWhenStopped = YES;
    
    _barCodeModel = [BarCodeModel new];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetProductID:) name:@"BarCode-DidGetProductID" object:_barCodeModel];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"ApplicationWillResignActive" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"ApplicationDidBecomeActive" object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    if (isFistLoad) {
        isFistLoad = NO;
        CGRect frame = self.view.bounds;
        [_activityIndicatorView setFrame:frame];
        [_previewView setFrame:frame];
        [_imgCanvas setFrame:[SimiGlobalVar scaleFrame:ImageCanvasFrame]];
        [_imgBackgroundHeader setFrame:[SimiGlobalVar scaleFrame:ImageBackgroundHeader]];
        [_imgBackgroundFooter setFrame:[SimiGlobalVar scaleFrame:ImageBackgroundFooter]];
        [_btnFlash setFrame:[SimiGlobalVar scaleFrame:ButtonFlashFrame]];
        [_btnPhoto setFrame:[SimiGlobalVar scaleFrame:ButtonPhotoFrame]];
        
        
        [self.view addSubview:_previewView];
        [self.view addSubview:_imgCanvas];
        [self.view addSubview:_imgBackgroundHeader];
        [self.view addSubview:_imgBackgroundFooter];
        [self.view addSubview:_btnFlash];
        [self.view addSubview:_btnPhoto];
    }
    if (isAfterPresentImagePickerView) {
        isAfterPresentImagePickerView = NO;
        if (isImagePickerViewCancel) {
            isImagePickerViewCancel = NO;
            [self hiddenCanvasScan:NO];
            [_previewView setHidden:NO];
        }else
        {
            if (isScanFromPhotoSuccess) {
                isScanFromPhotoSuccess = NO;
                [_previewView setHidden:YES];
            }else
            {
                [_previewView setHidden:NO];
            }
            [self hiddenCanvasScan:YES];
        }
    }else
    {
        isWaitingDataFromServer = NO;
        [self hiddenCanvasScan:NO];
        [_previewView setHidden:NO];
    }
    [self toggleScanningTapped];
}
- (void)viewWillAppearAfter:(BOOL)animated
{
    
}

- (void)viewWillDisappearAfter:(BOOL)animated
{
    if (!isAfterPresentImagePickerView) {
        [self hiddenCanvasScan:YES];
        [_previewView setHidden:YES];
        [self stopScanning];
    }
}

#pragma mark - Properties

- (void)setUniqueCodes:(NSMutableArray *)uniqueCodes {
    _uniqueCodes = uniqueCodes;
}

#pragma mark - Scanner
- (MTBBarcodeScanner *)scanner {
    if (!_scanner) {
        _scanner = [[MTBBarcodeScanner alloc] initWithPreviewView:_previewView];
    }
    return _scanner;
}

#pragma mark - Scanning

- (void)startScanning {
    self.uniqueCodes = [[NSMutableArray alloc] init];
    
    [self.scanner startScanningWithResultBlock:^(NSArray *codes) {
        if (!isWaitingDataFromServer & !isScanningFromPhoto) {
            for (AVMetadataMachineReadableCodeObject *code in codes) {
                if([code.type isEqualToString:@"org.iso.QRCode"])
                {
                    if (code.bounds.origin.x > _imgCanvas.frame.origin.x & code.bounds.origin.x < (_imgCanvas.frame.origin.x + _imgCanvas.frame.size.width/2) & code.bounds.origin.y > _imgCanvas.frame.origin.y & code.bounds.origin.y < (_imgCanvas.frame.origin.y + _imgCanvas.frame.size.height/2)) {
                        if (code.stringValue) {
                            [self.uniqueCodes addObject:code.stringValue];
                            
                            AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
                            [self hiddenCanvasScan:YES];
                            [_previewView setHidden:YES];
                            [self showAlertContactSimiCartWithMessage:[NSString stringWithFormat:@"Scan Data: %@\n This feature can only be accessed with the fully synced version. Please contact SimiCart by email or chat with us",code.stringValue]];
//                            [_barCodeModel getProductIdWithParams:@{@"code":code.stringValue, @"type":@"1"}];
                            isWaitingDataFromServer = YES;
//                            [self.view addSubview:_activityIndicatorView];
//                            [_activityIndicatorView startAnimating];
                            break;
                        }
                    }
                }else
                {
                    if (code.stringValue) {
                        [self.uniqueCodes addObject:code.stringValue];
                        
                        AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
                        [self hiddenCanvasScan:YES];
                        [_previewView setHidden:YES];
                        [self showAlertContactSimiCartWithMessage:[NSString stringWithFormat:@"Scan Data: %@\n This feature can only be accessed with the fully synced version. Please contact SimiCart by email or chat with us",code.stringValue]];
//                        [_barCodeModel getProductIdWithParams:@{@"code":code.stringValue, @"type":@"0"}];
                        isWaitingDataFromServer = YES;
//                        [self.view addSubview:_activityIndicatorView];
//                        [_activityIndicatorView startAnimating];
                        break;
                    }
                }
            }
        }
    }];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    isWaitingDataFromServer = NO;
    isScanningFromPhoto = NO;
    [_previewView setHidden:NO];
    [self hiddenCanvasScan:NO];
    switch (buttonIndex) {
        case 1:
            [self sendEmailToStoreWithEmail:@[@"support@simicart.com"] andEmailContent:@""];
            break;
        default:
            break;
    } 
}


- (void)stopScanning {
    [self.scanner stopScanning];
}

#pragma mark - Actions

- (void)toggleScanningTapped {
    [MTBBarcodeScanner requestCameraPermissionWithSuccess:^(BOOL success) {
        if (success) {
            [self startScanning];
        } else {
            [self displayPermissionMissingAlert];
        }
    }];
}

#pragma mark - Helper Methods

- (void)displayPermissionMissingAlert {
    NSString *message = nil;
    if ([MTBBarcodeScanner scanningIsProhibited]) {
        message = SCLocalizedString(@"This app does not have permission to use the camera.");
    } else if (![MTBBarcodeScanner cameraIsPresent]) {
        message = SCLocalizedString(@"This device does not have a camera.");
    } else {
        message = SCLocalizedString(@"An unknown error occurred.");
    }
    
    [[[UIAlertView alloc] initWithTitle:SCLocalizedString(@"Scanning Unavailable")
                                message:message
                               delegate:nil
                      cancelButtonTitle:@"Ok"
                      otherButtonTitles:nil] show];
}

#pragma mark - Action
- (void)didTapButtonFlash
{
    [self setTorchState:!self.torchState];
}

- (void)didTapButtonPhoto
{
    [self hiddenCanvasScan:YES];
    UIImagePickerController * picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    [self presentViewController:picker animated:YES completion:NULL];
    isAfterPresentImagePickerView = YES;
    isScanningFromPhoto = YES;
}

#pragma mark -Flash
- (void)setTorchState:(BOOL)torchState {
    AVCaptureDevice *device =
    [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if ([device hasTorch]) {
        [device lockForConfiguration:nil];
        [device
         setTorchMode:torchState ? AVCaptureTorchModeOn : AVCaptureTorchModeOff];
        [device unlockForConfiguration];
    }
    
    _torchState = torchState;
    if (_torchState) {
        [_btnFlash setImage:[UIImage imageNamed:@"barcode_flashonicon"] forState:UIControlStateNormal];
    }else
    {
        [_btnFlash setImage:[UIImage imageNamed:@"barcode_flashicon"] forState:UIControlStateNormal];
    }
}

#pragma mark UIImagePickerController Delegate
- (void) imagePickerController: (UIImagePickerController*) reader
 didFinishPickingMediaWithInfo: (NSDictionary*) info
{
    [reader dismissViewControllerAnimated:NO completion:nil];
    // EXAMPLE: do something useful with the barcode image
    UIImage *resultImage = [info objectForKey: UIImagePickerControllerOriginalImage];
    
    ZBarReaderController *imageReader = [ZBarReaderController new];
    [imageReader.scanner setSymbology: ZBAR_I25|ZBAR_EAN2|ZBAR_EAN5|ZBAR_EAN8|ZBAR_UPCE|ZBAR_CODE93|ZBAR_CODE128|ZBAR_QRCODE|ZBAR_PDF417|ZBAR_CODE39|ZBAR_EAN13
                               config: ZBAR_CFG_ENABLE
                                   to: 0];
    
    id <NSFastEnumeration> results = [imageReader scanImage:resultImage.CGImage];
    // Get only last symbol
    ZBarSymbol *sym = nil;
    for(sym in results) {
        break;
    }
    
    if (!sym) {
        [self hiddenCanvasScan:YES];
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:SCLocalizedString(@"Scanning Error") message:SCLocalizedString(@"Unable to detect valid code.") delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        alert.simiObjectName = @"AlertScanError";
        [alert show];
    }else
    {
//        NSLog(@"%@", sym.typeName);
//        if([sym.typeName  isEqualToString:@"QR-Code"])
//        {
//            [_barCodeModel getProductIdWithParams:@{@"code":sym.data, @"type":@"1"}];
//        }else
//        {
//            [_barCodeModel getProductIdWithParams:@{@"code":sym.data, @"type":@"0"}];
//        }
        [self showAlertContactSimiCartWithMessage:[NSString stringWithFormat:@"Scan Data: %@\n This feature can only be accessed with the fully synced version. Please contact SimiCart by email or chat with us",sym.data]];
        isWaitingDataFromServer = YES;
        isScanFromPhotoSuccess = YES;
        isScanningFromPhoto = NO;
//        [self.view addSubview:_activityIndicatorView];
//        [_activityIndicatorView startAnimating];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:NO completion:nil];
    isImagePickerViewCancel = YES;
    isScanningFromPhoto = NO;
}

#pragma mark Hidden Canvas
- (void)hiddenCanvasScan:(BOOL)isHidden
{
    [self.imgBackgroundHeader setHidden:isHidden];
    [self.imgBackgroundFooter setHidden:isHidden];
    [self.imgCanvas setHidden:isHidden];
    [self.btnFlash setHidden:isHidden];
    [self.btnPhoto setHidden:isHidden];
}

#pragma mark DidGetProductID
- (void)didGetProductID:(NSNotification*)noti
{
    if ([noti.name isEqualToString:@"BarCode-DidGetProductID"]) {
        [_activityIndicatorView stopAnimating];
        [_activityIndicatorView removeFromSuperview];
        SimiResponder *responder = [noti.userInfo valueForKey:@"responder"];
        if ([[responder.status uppercaseString] isEqualToString:@"SUCCESS"]) {
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
                SCProductViewController *productViewController = [SCProductViewController new];
                productViewController.firstProductID = [_barCodeModel valueForKey:@"product_id"];
                productViewController.arrayProductsID = [[NSMutableArray alloc]initWithArray: @[productViewController.firstProductID]];
                [self.navigationController pushViewController:productViewController animated:YES];
            }else
            {
                SCProductViewControllerPad *productViewController = [SCProductViewControllerPad new];
                productViewController.firstProductID = [_barCodeModel valueForKey:@"product_id"];
                productViewController.arrayProductsID = [[NSMutableArray alloc]initWithArray: @[productViewController.firstProductID]];
                [self.navigationController pushViewController:productViewController animated:YES];

            }
        }else
        {
            [_previewView setHidden:NO];
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:SCLocalizedString(@"Scanning Error") message:SCLocalizedString(@"No product matching code") delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            alert.simiObjectName = @"AlertFindProductFail";
            [alert show];
        }
    }
}

- (void)didReceiveNotification:(NSNotification *)noti
{
    if ([noti.name isEqualToString:@"ApplicationWillResignActive"]) {
        [self stopScanning];
        [self hiddenCanvasScan:YES];
    }else if ([noti.name isEqualToString:@"ApplicationDidBecomeActive"])
    {
        [self startScanning];
        [self hiddenCanvasScan:NO];
        [_previewView setHidden:NO];
    }
}

#pragma mark UIPopover Delegate
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    isWaitingDataFromServer = NO;
    [self hiddenCanvasScan:NO];
    [_previewView setHidden:NO];
}

@end
