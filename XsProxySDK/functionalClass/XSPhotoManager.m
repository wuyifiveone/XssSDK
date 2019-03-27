//
//  XSPhotoManager.m
//  XsProxySDK
//
//  Created by 吴怿 on 2019/3/12.
//  Copyright © 2019 吴怿. All rights reserved.
//

#import "XSPhotoManager.h"
#import "../XsProxySDK.h"
#import "../ClassFiles/XsRoot.h"
static XSPhotoManager *instance = nil;
@interface XSPhotoManager ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@end

@implementation XSPhotoManager

+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[XSPhotoManager alloc] init];
    });
    return instance;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
- (void)openPhoto:(NSString *)data {
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        NSLog(@"Photo failed: this Deivce can not use camera.");
        return;
    }
    NSDictionary *dic = [[XsRoot sharedInstance] parseJSONStrToObj:data];
    NSString *type = [NSString stringWithFormat:@"%@",[dic objectForKey:@"type"]];
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    if ([type isEqualToString:@"2"]) {
        picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    } else {
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    picker.delegate = self;
    picker.allowsEditing = YES;
    //    picker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window.rootViewController presentViewController:self animated:YES completion:nil];
    [self presentViewController:picker animated:YES completion:nil];
}

#pragma mark - UIImagePickerController Delegate
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    NSLog(@"Photo Cancel: User cancel camera.");
    [picker dismissViewControllerAnimated:YES completion:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info {
    NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
    if ([type isEqualToString:@"public.image"]) {
        UIImage *newImage = [info objectForKey:UIImagePickerControllerEditedImage];
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(200, 200), NO, 1.0);
        [newImage drawInRect:CGRectMake(0, 0, 200, 200)];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        NSData *data;
        data = UIImageJPEGRepresentation(image, 0.75); //jpg 压缩
        NSString * DocumentsPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString* fileName = [NSString stringWithFormat:@"/%s.jpg", "photoimg"];
        [fileManager createDirectoryAtPath:DocumentsPath withIntermediateDirectories:YES attributes:nil error:nil];
        [fileManager createFileAtPath:[DocumentsPath stringByAppendingString:fileName] contents:data attributes:nil];
        NSString *filePath = [[NSString alloc]initWithFormat:@"%@%@", DocumentsPath, fileName];
        [picker dismissViewControllerAnimated:YES completion:nil];
        [self dismissViewControllerAnimated:YES completion:nil];
        NSDictionary *dic = [NSDictionary dictionaryWithObject:filePath forKey:@"imagePath"];
        // 上传客户端 dic
//        [[XsProxySDK sharedInstance].delegate nativeCallJs:TAG_PHOTO andCode:0 withData:dic];
    }
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
