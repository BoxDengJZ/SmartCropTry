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
        cropView.configureWithCorners(on: imageView)
    }


    
    @IBAction func saveImg(_ sender: Any) {
        do {
            guard let corners = cropView.cornerLocations, let image = imageView.image else {
                return
            }
            let imgViewSize = imageView.bounds.size
            let cn = corners.map { (pt) -> CGPoint in
                return pt.inner(img: imgViewSize, relative: image.size)
            }
            let croppedImage = try SEQuadrangleHelper.cropImage(with: image, quad: cn)
            performSegue(withIdentifier: "doCrop", sender: croppedImage)
        } catch let error as SECropError {
            print(error)
        } catch {
            print(error)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        guard let vc = segue.destination as? ImageViewController else { return }
        guard let img = sender as? UIImage else { return }
        vc.image = img
    }
}


extension CGPoint{
    func inner(img s: CGSize, relative dot: CGSize) -> CGPoint{
        let xx = x * dot.width/s.width
        let yy = y * dot.height/s.height
        return CGPoint(x: xx, y: yy)
    }
}
