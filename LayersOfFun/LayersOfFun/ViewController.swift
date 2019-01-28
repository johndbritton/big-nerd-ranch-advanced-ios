import UIKit
import QuartzCore

class ViewController: UIViewController {

    @IBOutlet var imageView: UIView!
    @IBOutlet var topPin: NSLayoutConstraint!
    @IBOutlet var imageHeight: NSLayoutConstraint!
    
    @IBAction func buttonTapped(_ sender: UIButton) {
        
        if topPin.isActive {
            imageHeight.constant = imageView.frame.height
            imageHeight.isActive = true
            topPin.isActive = false
        }
        
        let params = UISpringTimingParameters(mass: 0.5,
                                              stiffness: 50.0,
                                              damping: 1.0,
                                              initialVelocity: CGVector.zero)
        
        let animator = UIViewPropertyAnimator(duration: 1.0, timingParameters: params)

        animator.addAnimations {
            self.imageHeight.constant -= 100
            self.view.layoutIfNeeded()
        }
        
        animator.startAnimation()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.layer.cornerRadius = 20.0
        imageView.layer.masksToBounds = true
        
        imageView.layer.borderWidth = 5.0
        imageView.layer.borderColor = UIColor.orange.cgColor
    }
    
}
