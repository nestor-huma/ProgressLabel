//
//  ViewController.swift
//  ProgressLabel
//
//  Created by nestorpopko on 01/21/2018.
//  Copyright (c) 2018 nestorpopko. All rights reserved.
//

import UIKit
import ProgressLabel

class ViewController: UIViewController {
    
    @IBOutlet weak var progressView: ProgressLabel!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var button: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(patternImage: UIImage(named: "paisley")!)
        updateLabel()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Add gradient to progress label
        let colors = [UIColor.red, UIColor(red: 0.5, green: 0.0, blue: 0.0, alpha: 1.0)]
        let locations: [CGFloat] = [0.0, 1.0]
        let gradientImage = UIImage.gradientImage(colors: colors, locations: locations, size: progressView.bounds.size)
        progressView.textColor = UIColor(patternImage: gradientImage)
        
        // Add appear animations
        
        let moveRight = CASpringAnimation(keyPath: "transform.translation.x")
        moveRight.fromValue = -view.bounds.width
        moveRight.toValue = 0
        moveRight.duration = moveRight.settlingDuration
        moveRight.fillMode = kCAFillModeBackwards
        progressView.layer.add(moveRight, forKey: nil)
        
        moveRight.beginTime = CACurrentMediaTime() + 0.2
        progressLabel.layer.add(moveRight, forKey: nil)
        
        moveRight.beginTime = CACurrentMediaTime() + 0.3
        button.layer.add(moveRight, forKey: nil)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + moveRight.duration, execute: updateProgress)
    }
    
    func updateProgress() {
        button.isEnabled = false
        progressView.progress += CGFloat(arc4random_uniform(5)) / 100.0
        if progressView.progress == 1.0 {
            button.isEnabled = true
            finished()
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: updateProgress)
        }
        updateLabel()
    }
    
    func updateLabel() {
        progressLabel.text = String(format: "%.0f%%", progressView.progress * 100.0)
    }
    
    func finished() {
        let pulse = CASpringAnimation(keyPath: "transform.scale")
        pulse.fromValue = 1.15
        pulse.toValue = 1.0
        pulse.damping = 7.5
        pulse.duration = pulse.settlingDuration
        progressView.layer.add(pulse, forKey: nil)
    }
    
    @IBAction func buttonPressed(_ sender: Any) {
        button.isEnabled = false
        progressView.setProgressAnimated(0)
        UIView.transition(with: progressLabel, duration: 0.5, options: .transitionCrossDissolve, animations: updateLabel, completion: nil)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2, execute: updateProgress)
    }
}
