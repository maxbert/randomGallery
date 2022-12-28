//
//  ImageView.swift
//  Random Photos 3
//
//  Created by Max Bertfield on 12/21/22.
//
import UIKit
import Photos
import PhotosUI

class ImageView: UIViewController, PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        print("yikez2")
    }
    
    var asset: PHAsset!
    var index: Int!
    
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        PHPhotoLibrary.shared().register(self)
        updateStaticImage()
    }

    
    var targetSize: CGSize {
        let scale = UIScreen.main.scale
        return CGSize(width: imageView.bounds.width * scale, height: imageView.bounds.height * scale)
    }
    
    func updateStaticImage() {
        // Prepare the options to pass when fetching the (photo, or video preview) image.
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true
        
        
        PHImageManager.default().requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFit, options: options,
                                              resultHandler: { image, _ in
                                                // If the request succeeded, show the image view.
                                                guard let image = image else { return }
                                                self.imageView.isHidden = false
                                                self.imageView.image = image
        })
    }
    
    @IBAction func shareImageButton(_ sender: UIBarButtonItem) {
            // set up activity view controller
            let imageToShare = [ getImageFromAsset(asset: asset)! ]
            let activityViewController = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
            
            // present the view controller
            self.present(activityViewController, animated: true, completion: nil)
    }
    
    
    func getImageFromAsset(asset: PHAsset) -> UIImage! {
        let manager = PHImageManager.default()
        let option = PHImageRequestOptions()
        var image = UIImage()
        option.isSynchronous = true
        manager.requestImage(for: asset, targetSize: CGSize(width: asset.pixelWidth, height: asset.pixelHeight), contentMode: .aspectFit, options: option, resultHandler: {(result, info)->Void in
            image = result!
        })
        return image
    }
    
    
    static func getInstance(asset: PHAsset!, index: Int!) -> ImageView {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "imageViewPage")as! ImageView
        vc.asset = asset
        vc.index = index
        return vc
      }

}

