//
//  ViewController.h
//  Polaroid
//
//  Created by Anthony Tuil on 31/03/2015.
//  Copyright (c) 2015 Anthony Tuil. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface ViewController : UIViewController <UIImagePickerControllerDelegate,UINavigationControllerDelegate>{
    UIImagePickerController *mainViewController;
    UIImageView *imageView;
    UIToolbar *toolBar;
    UIImage *background;
    BOOL hasLoadedCamera;
    UIButton *take;
    UIActivityIndicatorView *loader;
    UIView *blackView;
    UIButton *dismiss;
    UIButton *flash;
    UIButton *doneButton;
}

@end

