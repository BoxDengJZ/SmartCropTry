//
//  ViewController.swift
//  secondCrop
//
//  Created by Jz D on 2021/2/2.
//

import UIKit

class ViewController: UIViewController {
    
    let cropView = SECropView()
    @IBOutlet weak var imageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        cropView.configureWithCorners(corners: [CGPoint(x: 120, y: 100),
                                                CGPoint(x: 270, y: 170),
                                                CGPoint(x: 280, y: 450),
                                                CGPoint(x: 120, y: 400)], on: imageView)
    }


    
    @IBAction func saveImg(_ sender: Any) {
        do {
            guard let corners = cropView.cornerLocations else { return }
            guard let image = imageView.image else { return }
            
            let croppedImage = try SEQuadrangleHelper.cropImage(with: image, quad: corners)
            
            performSegue(withIdentifier: "doCrop", sender: croppedImage)
        } catch let error as SECropError {
            print(error)
        } catch {
            print("Something went wrong, are you feeling OK?")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        guard let vc = segue.destination as? ImageViewController else { return }
        guard let img = sender as? UIImage else { return }
        vc.image = img
    }
}

