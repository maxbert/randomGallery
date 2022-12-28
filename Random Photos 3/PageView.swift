//
//  PageView.swift
//  Random Photos 3
//
//  Created by Max Bertfield on 12/27/22.
//

import UIKit
import Photos

class PageView: UIPageViewController, UIPageViewControllerDataSource {
    var asset: PHAsset!
    var indexList: [Int]!
    var prevContentOffset: CGFloat!
    var fetchResult: PHFetchResult<PHAsset>!
    var index: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeDown.direction = UISwipeGestureRecognizer.Direction.down
        self.view.addGestureRecognizer(swipeDown)
    
        dataSource = self
        
        setViewControllers([ImageView.getInstance(asset: asset, index: index)], direction: .forward, animated: true, completion: nil)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        var currentIndex = (viewController as! ImageView).index!
        if currentIndex == 0 {
             return nil // To show there is no previous page
        } else {
            return ImageView.getInstance(asset: fetchResult.object(at: indexList[currentIndex - 1]), index: currentIndex - 1)
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        var currentIndex = (viewController as! ImageView).index!
        if currentIndex == indexList.count - 1 {
             return nil // To show there is no next page
        } else {
            return ImageView.getInstance(asset: fetchResult.object(at: indexList[currentIndex + 1]), index: currentIndex + 1)
        }
    }
    
    @IBAction func returnToGallery(_ sender: Any) {
        performSegue(withIdentifier: "returnToGallery", sender: sender)
    }
    
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizer.Direction.right:
                print("right")
            case UISwipeGestureRecognizer.Direction.down:
                returnToGallery(self)
                //imageView.resetZoom()
            case UISwipeGestureRecognizer.Direction.left:
                print("left")
            case UISwipeGestureRecognizer.Direction.up:
                print("Swiped up")
            default:
                break
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destination = segue.destination as? GridViewController else { fatalError("Unexpected view controller for segue") }
        destination.indexList = indexList
        destination.presetScrollLocation = prevContentOffset
        destination.fetchResult = fetchResult
    }
    
}
