//
//  ZoomingUIImageView.swift
//  Random Photos 3
//
//  Created by Max Bertfield on 12/27/22.
//

import UIKit

extension UIImageView {
    func enableZoom() {
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(startZooming(_:)))
        isUserInteractionEnabled = true
        addGestureRecognizer(pinchGesture)
        print("added recognizer")
    }
    
    @objc
    private func startZooming(_ sender: UIPinchGestureRecognizer) {
        print("zooming")
        let scaleResult = sender.view?.transform.scaledBy(x: sender.scale, y: sender.scale)
        guard let scale = scaleResult, scale.a > 1, scale.d > 1 else { return }
        sender.view?.transform = scale
        sender.scale = 1
    }
    
    func resetZoom() {
        self.transform = CGAffineTransformIdentity
    }
}
    
class ZoomingUIImageView: UIImageView {
    override public func awakeFromNib() {
        super.awakeFromNib();
        enableZoom()
    }
}
