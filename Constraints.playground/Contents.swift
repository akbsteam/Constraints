//: A UIKit based Playground for presenting user interface
  
import UIKit
import PlaygroundSupport

class MyViewController : UIViewController {
    override func loadView() {
        let view = UIView()
        view.backgroundColor = .white

        let view2 = UIView()
        view2.backgroundColor = .red
        
        let view3 = UIView()
        view3.backgroundColor = .blue
        
        let insets = UIEdgeInsets(top: 10, left: 15, bottom: -52, right: -88)
        
        view.addSubview(view2, constraints: anchorEdgesToSuperviewEdges(insets: insets))
            
        view2.addSubview(view3, constraints: sizedToRect(CGRect(x: 180, y: 50, width: 150, height: 200)))
        
        self.view = view
    }
}
// Present the view controller in the Live View window
PlaygroundPage.current.liveView = MyViewController()
