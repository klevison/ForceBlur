//
//  SettingsViewController.swift
//  Demo
//
//  Created by Klevison Matias on 12/7/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit

protocol SettingsSliderChangeable {
    
    func valueChanged(value: CGFloat)
    
}

final class SettingsViewController: UIViewController {
    
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var label: UILabel!
    var radius: CGFloat!
    var delegate: SettingsSliderChangeable?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        slider.maximumValue = 100
        slider.minimumValue = 0
        slider.value = Float(radius)
        self.label.text = "\(Int(radius!))%"
        
    }
    
    @IBAction func valueChanged(_ sender: Any) {
        let slider = sender as! UISlider
        let currentValue = Int(slider.value)
        DispatchQueue.main.async {
            self.label.text = "\(currentValue)%"
            self.delegate?.valueChanged(value: CGFloat(currentValue))
        }
    }
    
}
