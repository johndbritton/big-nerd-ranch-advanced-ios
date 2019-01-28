import UIKit
import QuartzCore

class ViewController: UIViewController {

    @IBOutlet var imageView: UIView!
    @IBOutlet var topPin: NSLayoutConstraint!
    @IBOutlet var imageHeight: NSLayoutConstraint!
    
    @IBAction func buttonTapped(_ sender: UIButton) {
        let layer = imageView.layer
        let anim: CABasicAnimation = CABasicAnimation(keyPath: "opacity")
        anim.toValue = 0.0
        anim.duration = 2.0
        layer.add(anim, forKey: "disappear")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.layer.cornerRadius = 20.0
        imageView.layer.masksToBounds = true
        
        imageView.layer.borderWidth = 5.0
        imageView.layer.borderColor = UIColor.orange.cgColor
    }
    
}
