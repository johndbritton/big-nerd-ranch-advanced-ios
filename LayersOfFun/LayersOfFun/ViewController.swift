import UIKit
import QuartzCore

class ViewController: UIViewController {

    @IBOutlet var imageView: UIView!
    @IBOutlet var topPin: NSLayoutConstraint!
    @IBOutlet var imageHeight: NSLayoutConstraint!
    
    @IBAction func buttonTapped(_ sender: UIButton) {
        let layer = imageView.layer

        let anim = CAKeyframeAnimation(keyPath: "transform")
        
        let txform = layer.transform
        
        let angle = CGFloat.pi/2
        let scaleTxform = CATransform3DScale(txform, 0.5, 0.5, 0.5)
        let rotTxform = CATransform3DRotate(txform, angle, 0.0, 0.0, 1.0)

        anim.values = [txform, scaleTxform, rotTxform]
        
        anim.duration = 1.0
        anim.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        anim.autoreverses = true
        anim.repeatCount = Float.infinity
        layer.add(anim, forKey: "spin")
        layer.transform = rotTxform
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.layer.cornerRadius = 20.0
        imageView.layer.masksToBounds = true
        
        imageView.layer.borderWidth = 5.0
        imageView.layer.borderColor = UIColor.orange.cgColor
    }
    
}
