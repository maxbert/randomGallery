//
//  PageViewControllerWrapperController.swift
//  Random Photos 3
//
//  Created by Max Bertfield on 12/27/22.
//

import UIKit
import Photos

class PageViewControllerWrapperController: UIViewController {
    var asset: PHAsset!
    var indexList: [Int]!
    var fetchResult: PHFetchResult<PHAsset>!
    var index: Int!
    var childPageView: PageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let swipeDown = UIPanGestureRecognizer(target: self, action: #selector(self.panGestureRecognizerHandler))
        self.view.addGestureRecognizer(swipeDown)
    }
    
    
    @objc func panGestureRecognizerHandler(_ sender: UIPanGestureRecognizer) {
        
        let translationY = sender.translation(in: sender.view!).y
        
        switch sender.state {
        case .began:
            break
        case .changed:
            view.transform = CGAffineTransform(translationX: 0, y: translationY)
        case .ended, .cancelled:
            if translationY > 160 {
                dismiss(animated: true, completion: nil)
            } else {
                UIView.animate(withDuration: 0.2, animations: {
                    self.view.transform = CGAffineTransform(translationX: 0, y: 0)
                })
            }
        case .failed, .possible:
            break
        @unknown default:
            break
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "seguePageView") {
            guard let pageView = segue.destination as? PageView else { fatalError("Unexpected view controller for segue") }
            self.childPageView = pageView
            pageView.intialIndex = index
            pageView.asset = asset
            pageView.indexList = indexList
            pageView.fetchResult = fetchResult
        } else {
            guard let destination = segue.destination as? GridViewController else { fatalError("Unexpected view controller for segue") }
            destination.indexList = indexList
            destination.fetchResult = fetchResult
        }
    }
    
    @IBAction func shareImageButton(_ sender: UIBarButtonItem) {
//            // set up activity view controller
        let indexToShare:Int! = childPageView.currentIndex
        let assetToShare:PHAsset! = fetchResult.object(at: indexList[indexToShare])
        let imageToShare = [ getImageFromAsset(asset: assetToShare)! ]
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
    
    
}
