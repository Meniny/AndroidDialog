//
//  ViewController.swift
//  Sample
//
//  Created by Meniny on 2018-04-29.
//  Copyright © 2018年 Meniny Lab. All rights reserved.
//

import UIKit
import AndroidDialog

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.view.backgroundColor = #colorLiteral(red: 0.99, green:0.78, blue:0.49, alpha:1.00)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBOutlet weak var someView: UIView!
    @IBAction func show(_ sender: UIButton) {
        AndroidDialog.init().setTitle("Alert").setMessage("This is a message!!!\nhahahahahahahahahahahahha!😆\nO(∩_∩)O~").setPositiveButton("Done") { (d) in
            d.hide()
            }.show(to: self.randomView)
    }

    public var randomView: UIView {
        let index = Int(arc4random_uniform(2))
        print(index)
        return [self.view, self.someView][index]
    }
}

