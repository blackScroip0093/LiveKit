//
//  WSPhotosServer.swift
//  WisedomSong
//
//  Created by droog on 2018/8/27.
//  Copyright © 2018年 droog. All rights reserved.
//

import UIKit
import AVFoundation
//import EFQRCodeThanks♪(･ω･)ﾉ
//import SDWebImage
import Photos

public typealias imageClosure = (_ image: UIImage?) -> ()
public typealias albumSelectClosure = (_ images: [UIImage], _ videoPaths: [String]) -> ()
public typealias imagesClosure = (_ images: [UIImage]?) -> ()
public func safeAsync(_ block: @escaping ()->()) {
    if Thread.isMainThread {
        block()
    } else {
        DispatchQueue.main.async {
            block()
        }
    }
}
class PhotosServer {
    
    public class func isOpenAlbum(complete:((_ isOpen: Bool) -> ())?) {
        PHPhotoLibrary.requestAuthorization { (status) in
            safeAsync {
                if status == .authorized {
                    complete?(true)
                }else{
                    complete?(false)
                }
            }
        }
    }
    
    public class func isOpenCamera() -> Bool {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        if status == .restricted || status == .denied {
            return false
        }
        return true
    }
    
    public class func isOpenMic() -> Bool {
        let status = AVAudioSession.sharedInstance().recordPermission
//        if status != .denied {
//            return true
//        }
        return false
    }
    
    /// 拍照
    ///
    /// - Parameters:
    ///   - controller: 控制器
    ///   - complete: 回调图片
    public class func presentTakePhoto(controller: UIViewController?,sourceType: UIImagePickerController.SourceType = .camera , allowsEditing: Bool = true, isUserIcon: Bool = true ,_ complete: imageClosure?) {
        guard let `controller` = controller else { return }
        let imagePicker = UMIImagePickerController()
        imagePicker.isUserIcon = isUserIcon
        imagePicker.sourceType = sourceType
        imagePicker.delegate = imagePicker
        imagePicker.allowsEditing = true
        imagePicker.isAllowEdit = allowsEditing
        imagePicker.navigationBar.isTranslucent = false
        imagePicker.selectImageClosure = complete
        controller.present(imagePicker, animated: true, completion: nil)
    }
    
    /// 保存图片到相册
    ///
    /// - Parameters:
    ///   - image: 图片
    ///   - complete: 回调
//    public class func saveImageToAlbum(image: UIImage, complete: ((_ isFinish: Bool)->())?) {
//        DYPhotosHelper.saveImageToAlbum(image: image) { (finish) in
//            complete?(finish)
//        }
//    }
//
//    public class func saveGifToAlbum(filePath: String, complete: ((_ isFinish: Bool)->())?){
//        DYPhotosHelper.saveGifToAlbum(filePath: filePath) { (finish) in
//            complete?(finish)
//        }
//    }
    
    /// 设置图片缓存
    ///
    /// - Parameters:
    ///   - url: key
    ///   - image: image
//    public class func setImageCache(url: String, image: UIImage) {
//        SDWebImageManager.shared.imageCache.store(image, imageData: image.imageData, forKey: url, cacheType: .all, completion: nil)
//    }
//
//    public class func clearImageMemoryCache(url: String) {
//        SDWebImageManager.shared.imageCache.removeImage(forKey: url, cacheType: .all, completion: nil)
//    }
    
    /// 检验是否存在二维码
    ///
    /// - Parameters:
    ///   - image: image
//    public class func checkIsHaveQRcode(image: UIImage?) -> String {
//        guard let cgimage = image?.cgImage, let result = EFQRCode.recognize(image: cgimage)?.last else { return "" }
//        return result
//    }
}

class UMIImagePickerController: UIImagePickerController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {

    open var selectImageClosure: imageClosure?
    
    open var isAllowEdit: Bool = false
    
    open var isUserIcon: Bool = true
    
    //MARK:UIImagePickerControllerDelegate
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation{
        return .landscapeRight
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask{
        return .landscapeRight
    }
    override var shouldAutorotate: Bool{
        return true
    }
    override func shouldAutomaticallyForwardRotationMethods() -> Bool {
        return true
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var image: UIImage? = nil
//        if self.allowsEditing {
//            image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
//        }else{
//            image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
//        }
        
        if image == nil {
            return
        }
//        if isAllowEdit {
//            let cropVC = CropViewController()
//            cropVC.delegate = self
//            cropVC.image = image
//            pushViewController(cropVC, animated: true)
//        }else{
            selectImageClosure?(image)
            dismiss(animated: true, completion: nil)
//        }
    }
}

extension PHAsset {
    var fileName: String{
        return self.value(forKey: "filename") as? String ?? ""
    }
    
//    var isGif: Bool {
//        return fileName.pathExtension.uppercased() == "GIF"
//    }
}

