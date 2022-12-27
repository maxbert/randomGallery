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
    var indexList: [Int]!
    var prevContentOffset: CGFloat!
    var fetchResult: PHFetchResult<PHAsset>!
    var index: Int!
    
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        PHPhotoLibrary.shared().register(self)
        updateStaticImage()
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeRight.direction = UISwipeGestureRecognizer.Direction.right
        self.view.addGestureRecognizer(swipeRight)

        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeDown.direction = UISwipeGestureRecognizer.Direction.down
       self.view.addGestureRecognizer(swipeDown)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeLeft.direction = UISwipeGestureRecognizer.Direction.left
        self.view.addGestureRecognizer(swipeLeft)
    }
    
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizer.Direction.right:
                if (index > 0) {
                    index -= 1
                    asset = fetchResult.object(at: indexList[index])
                    updateStaticImage()
                    imageView.resetZoom()
                }
            case UISwipeGestureRecognizer.Direction.down:
                returnToGallery(self)
                imageView.resetZoom()
            case UISwipeGestureRecognizer.Direction.left:
                if (index < indexList.count - 1) {
                    index += 1
                    asset = fetchResult.object(at: indexList[index])
                    updateStaticImage()
                    imageView.resetZoom()
                }
            case UISwipeGestureRecognizer.Direction.up:
                print("Swiped up")
            default:
                break
            }
        }
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
    
    @IBAction func returnToGallery(_ sender: Any) {
        performSegue(withIdentifier: "returnToGallery", sender: sender)
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
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destination = segue.destination as? GridViewController else { fatalError("Unexpected view controller for segue") }
        destination.indexList = indexList
        destination.presetScrollLocation = prevContentOffset
        destination.fetchResult = fetchResult
    }
}

