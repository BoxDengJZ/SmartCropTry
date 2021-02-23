//
//  ViewController.swift
//  captureAndFilter
//
//  Created by Jz D on 2021/2/23.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let camera = CusCamera()
        camera.takeDoneBlockX = { (info) in
            print(info)
        }
        showDetailViewController(camera, sender: nil)
    }


}

