//
//  ViewController.swift
//  NPProgressLabel
//
//  Created by Nestor Popko on 3/7/16.
//  Copyright © 2016 Nestor Popko. All rights reserved.
//

import UIKit

// perform task after given delay (in seconds)
func delay(seconds: Double, task: () -> Void) {
    let time = dispatch_time(DISPATCH_TIME_NOW, Int64(Double(NSEC_PER_SEC) * seconds))
    dispatch_after(time, dispatch_get_main_queue(), task)
}

class ViewController: UIViewController {
    
    @IBOutlet weak var progressView: NPProgressLabel!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var button: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(patternImage: UIImage(named: "paisley")!)
        updateLabel()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // Add gradient to progress label
        let colors = [UIColor.redColor(), UIColor(red: 0.5, green: 0.0, blue: 0.0, alpha: 1.0)]
        let locations: [CGFloat] = [0.0, 1.0]
        let gradientImage = UIImage.gradientImage(colors: colors, locations: locations, size: progressView.bounds.size)
        progressView.textColor = UIColor(patternImage: gradientImage)
        
        // Add appear animations
        
        let moveRight = CASpringAnimation(keyPath: "transform.translation.x")
        moveRight.fromValue = -view.bounds.width
        moveRight.toValue = 0
        moveRight.duration = moveRight.settlingDuration
        moveRight.fillMode = kCAFillModeBackwards
        progressView.layer.addAnimation(moveRight, forKey: nil)
        
        moveRight.beginTime = CACurrentMediaTime() + 0.2
        progressLabel.layer.addAnimation(moveRight, forKey: nil)
        
        moveRight.beginTime = CACurrentMediaTime() + 0.3
        button.layer.addAnimation(moveRight, forKey: nil)
        
        delay(moveRight.duration, task: updateProgress)
    }
    
    func updateProgress() {
        button.enabled = false
        progressView.progress += CGFloat(arc4random_uniform(5)) / 100.0
        if progressView.progress > 1.0 {
            progressView.progress = 1.0
            button.enabled = true
            finished()
        } else {
            delay(0.1, task: updateProgress)
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
        progressView.layer.addAnimation(pulse, forKey: nil)
    }
    
    @IBAction func buttonPressed(sender: AnyObject) {
        button.enabled = false
        progressView.setProgress(0.0, animated: true)
        UIView.transitionWithView(progressLabel, duration: 0.5, options: .TransitionCrossDissolve, animations: updateLabel, completion: nil)
        delay(1.2, task: updateProgress)
    }
}

