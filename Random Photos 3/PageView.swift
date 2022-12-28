//
//  PageView.swift
//  Random Photos 3
//
//  Created by Max Bertfield on 12/27/22.
//

import UIKit
import Photos

class PageView: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    var asset: PHAsset!
    var indexList: [Int]!
    var prevContentOffset: CGFloat!
    var fetchResult: PHFetchResult<PHAsset>!
    var intialIndex: Int!
    var currentIndex: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        dataSource = self
        self.delegate = self
        
        setViewControllers([ImageView.getInstance(asset: asset, index: intialIndex)], direction: .forward, animated: true, completion: nil)
        currentIndex = intialIndex
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if currentIndex == 0 {
             return nil // To show there is no previous page
        } else {
            return ImageView.getInstance(asset: fetchResult.object(at: indexList[currentIndex! - 1]), index: currentIndex! - 1)
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if currentIndex == indexList.count - 1 {
             return nil // To show there is no next page
        } else {
            return ImageView.getInstance(asset: fetchResult.object(at: indexList[currentIndex! + 1]), index: currentIndex! + 1)
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if (completed) {
            currentIndex = (self.viewControllers![0] as! ImageView).index
        }
    }
    
}
