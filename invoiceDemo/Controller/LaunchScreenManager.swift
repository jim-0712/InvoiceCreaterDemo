//
//  LaunchScreenManager.swift
//  invoiceDemo
//
//  Created by Fu Jim on 2020/9/30.
//  Copyright © 2020 Fu Jim. All rights reserved.
//

import UIKit
import Foundation

class LaunchScreenManager {
    static let instance = LaunchScreenManager(animationDurationBase: 1.3)
    var displayLink: CADisplayLink!
    
    var view: UIView?
    var value: CGFloat = 0.0
    var invert: Bool = false
    var firstTime: Bool = false
    var parentView: UIView?
    let animationDurationBase: Double

    init(animationDurationBase: Double) {
        self.animationDurationBase = animationDurationBase
    }

    // MARK: - Animation

    func animateAfterLaunch(_ parentViewPassedIn: UIView) {
        parentView = parentViewPassedIn
        view = loadView()
        displayLink = CADisplayLink(target: self, selector: #selector(handleCircleAlpha))
        displayLink.add(to: .current, forMode: .common)
        fillParentViewWithView()
    }

    func loadView() -> UIView {
        return UINib(nibName: "LaunchView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
    }
    
    @objc func handleCircleAlpha() {
        if invert {
            value -= 3
        } else {
            value += 3
        }
        view!.subviews.forEach { view in
            if view.tag > 0 {
                let tag = Double(view.tag)
                DispatchQueue.main.asyncAfter(deadline: .now() + (tag * 0.2)) {
                    view.alpha = self.value / 100
                }
            }
        }
        if value > 100 || value < 0 {
            invert = !invert
        }
        print(value/100)
    }
    
    func fillParentViewWithView() {
        parentView!.addSubview(view!)
        
        view!.frame = parentView!.bounds
        view!.center = parentView!.center
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.displayLink.isPaused = true
            self.view!.removeFromSuperview()
        }
    }
}
