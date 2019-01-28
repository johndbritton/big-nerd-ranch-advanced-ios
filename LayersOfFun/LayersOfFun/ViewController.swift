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
        
        let animator = UIViewPropertyAnimator(duration: 1.0, curve: .easeInOut) {
            self.imageHeight.constant -= 100
            self.view.layoutIfNeeded()
        }
        animator.startAnimation()
        
    }
    
    
}
