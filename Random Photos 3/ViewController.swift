//
//  ViewController.swift
//  Random Photos 3
//
//  Created by Max Bertfield on 12/19/22.
//

import UIKit
import Photos
import PhotosUI

private extension UICollectionView {
    func indexPathsForElements(in rect: CGRect) -> [IndexPath] {
        let allLayoutAttributes = collectionViewLayout.layoutAttributesForElements(in: rect)!
        return allLayoutAttributes.map { $0.indexPath }
    }
}

class GridViewController: UICollectionViewController, PHPhotoLibraryAvailabilityObserver, PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        print("yikes")
    }
    
    func photoLibraryDidBecomeUnavailable(_ photoLibrary: PHPhotoLibrary) {
        print("yikess")
    }
    
    
    @IBOutlet weak var gridView: UICollectionView!

    var fetchResult: PHFetchResult<PHAsset>! {
        didSet {
            if (indexList == nil || indexList!.isEmpty ) {
                refreshIndexList()
            }
        }
    }
    var indexList: [Int]!
    
    fileprivate let imageManager = PHCachingImageManager()
    fileprivate var thumbnailSize: CGSize!
    fileprivate var previousPreheatRect = CGRect.zero
    var assetCollection: PHAssetCollection!
    var availableWidth: CGFloat = 0
    var presetScrollLocation: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        PHPhotoLibrary.shared().register(self as PHPhotoLibraryAvailabilityObserver)
        resetCachedAssets()
        let allPhotosOptions = PHFetchOptions()
        if (fetchResult == nil || fetchResult.count == 0) {
            fetchResult = PHAsset.fetchAssets(with: allPhotosOptions)
        }
        collectionView.contentOffset.y = presetScrollLocation
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Determine the size of the thumbnails to request from the PHCachingImageManager.
        let scale = UIScreen.main.scale
        let cellSize = gridView.contentSize
        thumbnailSize = CGSize(width: cellSize.width * scale, height: cellSize.height * scale)
        navigationItem.rightBarButtonItem = nil
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateCachedAssets()
    }
    
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    
    func refreshIndexList() {
        let numItems = fetchResult.count
        indexList = Array(0..<numItems)
        indexList.shuffle()
    }
    
    fileprivate func resetCachedAssets() {
        imageManager.stopCachingImagesForAllAssets()
        previousPreheatRect = .zero
    }
    /// - Tag: UpdateAssets
    fileprivate func updateCachedAssets() {
        // Update only if the view is visible.
        guard isViewLoaded && view.window != nil else { return }
        
        let visibleRect = CGRect(origin: gridView!.contentOffset, size: gridView!.bounds.size)
        
        // Update only if the visible area is significantly different from the last preheated area.
        let delta = abs(visibleRect.midY - previousPreheatRect.midY)
        guard delta > view.bounds.height / 3 else { return }
        
        // Compute the assets to start and stop caching.
        let (addedRects, removedRects) = differencesBetweenRects(previousPreheatRect, visibleRect)
        let addedAssets = addedRects
            .flatMap { rect in gridView!.indexPathsForElements(in: rect) }
            .map { indexPath in fetchResult.object(at: indexList[indexPath.item]) }
        let removedAssets = removedRects
            .flatMap { rect in gridView!.indexPathsForElements(in: rect) }
            .map { indexPath in fetchResult.object(at: indexList[indexPath.item]) }
        
        // Update the assets the PHCachingImageManager is caching.
        imageManager.startCachingImages(for: addedAssets,
                                        targetSize: thumbnailSize, contentMode: .aspectFill, options: nil)
        imageManager.stopCachingImages(for: removedAssets,
                                       targetSize: thumbnailSize, contentMode: .aspectFill, options: nil)
        // Store the computed rectangle for future comparison.
        previousPreheatRect = visibleRect
    }
    
    fileprivate func differencesBetweenRects(_ old: CGRect, _ new: CGRect) -> (added: [CGRect], removed: [CGRect]) {
        if old.intersects(new) {
            var added = [CGRect]()
            if new.maxY > old.maxY {
                added += [CGRect(x: new.origin.x, y: old.maxY,
                                 width: new.width, height: new.maxY - old.maxY)]
            }
            if old.minY > new.minY {
                added += [CGRect(x: new.origin.x, y: new.minY,
                                 width: new.width, height: old.minY - new.minY)]
            }
            var removed = [CGRect]()
            if new.maxY < old.maxY {
                removed += [CGRect(x: new.origin.x, y: new.maxY,
                                   width: new.width, height: old.maxY - new.maxY)]
            }
            if old.minY < new.minY {
                removed += [CGRect(x: new.origin.x, y: old.minY,
                                   width: new.width, height: new.minY - old.minY)]
            }
            return (added, removed)
        } else {
            return ([new], [old])
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchResult.count
    }
    /// - Tag: PopulateCell
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> GridViewCell {
        var index = indexPath.item
        if (index >= indexList.count) {
            index = indexList.count - 1
        }
        let asset = fetchResult.object(at: indexList[index])
        // Dequeue a GridViewCell.
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GridViewCell", for: indexPath) as? GridViewCell
            else { fatalError("Unexpected cell in collection view") }
        
       
        
        // Request an image for the asset from the PHCachingImageManager.
        cell.representedAssetIdentifier = asset.localIdentifier
        let _: UIImage? = fetchAndSetUIImageInCell(asset: asset, retryAttempts: 0, cell: cell, imageManager: imageManager)
        return cell
    }
    
    private func fetchAndSetUIImageInCell(asset: PHAsset, retryAttempts: Int = 0, cell: GridViewCell!, imageManager: PHCachingImageManager!) -> UIImage? {
        var img: UIImage?
        let options = PHImageRequestOptions()
        
        options.resizeMode = PHImageRequestOptionsResizeMode.fast;
        options.isSynchronous = true
        options.isNetworkAccessAllowed = true
        options.deliveryMode = PHImageRequestOptionsDeliveryMode.opportunistic
        imageManager.requestImage(for: asset, targetSize: CGSize(width: 500, height: 500), contentMode: .aspectFit, options: options, resultHandler: { image, _ in
            img = image
            // UIKit may have recycled this cell by the handler's activation time.
            // Set the cell's thumbnail image only if it's still showing the same asset.
            if cell.representedAssetIdentifier == asset.localIdentifier && img != nil {
                cell.thumbnailImage = img
            }
        })
        if img == nil && retryAttempts > 0 {
            return fetchAndSetUIImageInCell(asset: asset, retryAttempts: retryAttempts - 1, cell: cell, imageManager: imageManager)
        }
        return img
    }
    
    // MARK: UIScrollView
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateCachedAssets()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destination = segue.destination as? PageView else { fatalError("Unexpected view controller for segue") }
        guard let collectionViewCell = sender as? GridViewCell else { fatalError("Unexpected sender for segue") }
        let indexPath = collectionView.indexPath(for: collectionViewCell)!
        destination.asset = fetchResult.object(at: indexList[indexPath.item])
        destination.indexList = indexList
        destination.fetchResult = fetchResult
        destination.prevContentOffset = collectionView.contentOffset.y
        destination.index = indexPath.item
    }


}

