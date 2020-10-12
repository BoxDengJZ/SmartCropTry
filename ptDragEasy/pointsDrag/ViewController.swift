//
//  ViewController.swift
//  pointsDrag
//
//  Created by Jz D on 2020/10/10.
//  Copyright © 2020 Jz D. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    
    
    @IBAction func photoIt(_ sender: Any) {
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = UIImagePickerController.SourceType.camera
        present(picker, animated: true)
        
    }
    

}




extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{

    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true)
        
        
        if let image = info[.originalImage] as? UIImage{
            var midImg = image
            let s = image.size
            if s.width > s.height{
               midImg = image.leftTurn
            }
            
            
            let sketchC = SketchController()
            sketchC.image = midImg
            sketchC.modalPresentationStyle = .fullScreen
            present(sketchC, animated: true) {}
        
 
    
        }
    
       
    }



}

