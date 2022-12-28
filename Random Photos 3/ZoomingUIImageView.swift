//
//  ZoomingUIImageView.swift
//  Random Photos 3
//
//  Created by Max Bertfield on 12/27/22.
//

import UIKit
    
class ZoomingUIImageView: UIImageView, UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self
    }
    
}
