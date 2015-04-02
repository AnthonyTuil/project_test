//
//  ViewController.m
//  Polaroid
//
//  Created by Anthony Tuil on 31/03/2015.
//  Copyright (c) 2015 Anthony Tuil. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    blackView = [[UIView alloc] init];
    blackView.frame = self.view.frame;
    blackView.backgroundColor = [UIColor blackColor];
    

    
    UILabel *printing = [[UILabel alloc] init];
    printing.text = @"printing...";
    [printing setFont:[UIFont fontWithName:@"GothamBold" size:30]];
    printing.textAlignment = NSTextAlignmentCenter;
    printing.textColor = [UIColor whiteColor];
    printing.frame = CGRectMake(0, 0, 320, 50);
    printing.center = blackView.center;
    
    [blackView addSubview:printing];
    
    hasLoadedCamera = NO;
    mainViewController = [[UIImagePickerController alloc] init];
    mainViewController.delegate = self;
    mainViewController.sourceType = UIImagePickerControllerSourceTypeCamera;
    mainViewController.showsCameraControls = NO;
    
    mainViewController.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
    
    imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 425)];
    imageView.center = self.view.center;
    imageView.hidden = YES;
    
    UIView *overlayView = [[UIView alloc] initWithFrame:self.view.frame];
    overlayView.opaque = NO;
    overlayView.backgroundColor = [UIColor clearColor];
    
    take = [UIButton buttonWithType:UIButtonTypeCustom];
    [take setBackgroundImage:[UIImage imageNamed:@"classic6"] forState:UIControlStateNormal];
    [take setBackgroundImage:[UIImage imageNamed:@"classic6_pushed"] forState:UIControlStateHighlighted];

    take.frame = CGRectMake((self.view.frame.size.width-170/2)/2, 925/2, 170/2, 170/2);
    [take addTarget:self action:@selector(takePicture) forControlEvents:UIControlEventTouchUpInside];
    
    loader = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    loader.frame = CGRectMake(0, 0, 50, 50);
    loader.center = take.center;
    [take addSubview:loader];
    
    flash = [UIButton buttonWithType:UIButtonTypeCustom];
    [flash setBackgroundImage:[UIImage imageNamed:@"Flash"] forState:UIControlStateSelected];
    [flash setBackgroundImage:[UIImage imageNamed:@"Flash_unselected"] forState:UIControlStateNormal];
    
    flash.frame = CGRectMake(43, take.center.y-84/4, 42/2, 84/2);
    [flash addTarget:self action:@selector(changeFlash) forControlEvents:UIControlEventTouchUpInside];
    
    doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [doneButton setBackgroundImage:[UIImage imageNamed:@"Done"] forState:UIControlStateNormal];
    doneButton.frame = CGRectMake(34/2, 40/2, 155/2, 44/2);
    [doneButton addTarget:self action:@selector(dismissView) forControlEvents:UIControlEventTouchUpInside];

    
    UIButton *switchToMode = [UIButton buttonWithType:UIButtonTypeCustom];
    [switchToMode setBackgroundImage:[UIImage imageNamed:@"switch"] forState:UIControlStateNormal];
    switchToMode.frame = CGRectMake(477/2, take.center.y-87/4, 87/2, 87/2);
    [switchToMode addTarget:self action:@selector(switchMode) forControlEvents:UIControlEventTouchUpInside];
    
    [overlayView addSubview:take];
    [overlayView addSubview:switchToMode];
    [overlayView addSubview:flash];
    
    [blackView addSubview:imageView];
    
    mainViewController.cameraOverlayView = overlayView;
    

    // Do any additional setup after loading the view, typically from a nib.
}



-(void)dismissView{
    [doneButton removeFromSuperview];
    [imageView removeFromSuperview];
    [blackView removeFromSuperview];
}

#pragma Re-code basic imagepicker function

-(void)changeFlash{
    if (!flash.selected) {
        flash.selected = YES;
        mainViewController.cameraFlashMode = UIImagePickerControllerCameraFlashModeOn;
    }else{
        flash.selected = NO;
        mainViewController.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
    }
}

-(void)takePicture{
    [mainViewController.view addSubview:blackView];
    [mainViewController takePicture];
}

-(void)switchMode{
    if (mainViewController.cameraDevice == UIImagePickerControllerCameraDeviceRear) {
        mainViewController.cameraDevice = UIImagePickerControllerCameraDeviceFront;
        flash.selected = NO;
    }
    else {
        mainViewController.cameraDevice = UIImagePickerControllerCameraDeviceRear;
    }
}


-(void)viewDidAppear:(BOOL)animated{
    
    if (!hasLoadedCamera)
        [self performSelector:@selector(showcamera) withObject:nil afterDelay:0.3];
    

}

- (void)showcamera {
    hasLoadedCamera = YES;
    
    [self presentViewController:mainViewController animated:NO completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker
        didFinishPickingImage:(UIImage *)image
                  editingInfo:(NSDictionary *)editingInfo {

    
    background = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"background" ofType:@"jpg" inDirectory:@""]];
    UIImage *mask = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"mask" ofType:@"png" inDirectory:@""]];
    
    UIImage *polarizedImage;
    
    CGContextRef context;
    CGRect r = CGRectMake(0, 0, image.size.width, image.size.height);
    
    //	image = [UIImage imageWithCGImage:CGImageCreateWithImageInRect([image CGImage], r)];
    
    UIGraphicsBeginImageContext(image.size);
    context = UIGraphicsGetCurrentContext();
    CGContextClearRect(context, r);
    
    //CGContextClipToMask(context, r, mask.CGImage);
    
    [image drawInRect:r];
    
    //[image drawInRect:r blendMode:kCGBlendModeNormal alpha:0.5];
    [background drawInRect:r blendMode:kCGBlendModeSoftLight alpha:0.9];
    [background drawInRect:r blendMode:kCGBlendModePlusDarker alpha:0.3];
    [background drawInRect:r blendMode:kCGBlendModeOverlay alpha:0.7];
    //	[background drawInRect:r blendMode:kCGBlendModeLuminosity alpha:0.2];
    
    [mask drawInRect:r blendMode:kCGBlendModeNormal alpha:1.0];
    
    polarizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    imageView.image = polarizedImage;
    imageView.hidden = NO;
    imageView.center = CGPointMake(self.view.frame.size.width/2, 800);
    [blackView addSubview:imageView];
    [self.view bringSubviewToFront:imageView];
    
            NSLog(@"coucou");
        UIImageWriteToSavedPhotosAlbum(imageView.image, nil, nil, nil);
    [self animateImage];
    
 
}


-(void)animateImage{
    [UIView animateWithDuration:4.0
                          delay:0
                        options: UIViewAnimationOptionCurveLinear
                     animations:^{
                         imageView.center = self.view.center;
                     }
                     completion:^(BOOL finished){
                         [blackView addSubview:doneButton];
                        
                     }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
