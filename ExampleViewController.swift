//
//  ExampleViewController.swift
//  LovelyActivityIndicatorView
//
//  Created by Evan Bacon on 09/14/2016.
//  Copyright (c) 2016 bacon brix. All rights reserved.
//

import UIKit

class ExampleViewController: UIViewController {
    var loop: UIButton!
}

extension ExampleViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLoopingButton()
        startAnimation(loop)
    }
    
    private func setupLoopingButton() {
        loop = UIButton(frame: CGRect(origin: view.center, size: CGSize(width: self.view.frame.size.width,height: 100)))
        loop.frame.origin.y += 100
        loop.frame.origin.x = 0
        
        loop.setTitle("Loop", forState: .Normal)
        loop.setTitleColor(UIColor.blackColor(), forState: .Normal)
        loop.setTitleColor(UIColor.lightGrayColor(), forState: .Disabled)
        loop.titleLabel?.font = UIFont(name: "Avenir-Book", size: 20.0)
        loop.titleLabel?.textAlignment = .Center
        loop.addTarget(self, action: #selector(ExampleViewController.startAnimation(_:)), forControlEvents: .TouchUpInside)
        view.addSubview(loop)
    }
    
    func startAnimation(sender:UIButton) {
        sender.enabled = false
        
        view.startLoading()
        NSTimer.scheduledTimerWithTimeInterval(5.0, target: self, selector: #selector(ExampleViewController.stopAnimation), userInfo: nil, repeats: false)
    }
    
    func stopAnimation() {
        loop.enabled = true
        view.stopLoading()
    }
}
