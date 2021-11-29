//
//  MyTabBar.swift
//  AppointmentProject
//
//  Created by George on 04.11.2021.
//

import UIKit



class TabBarController: UITabBarController {
    
    let coustmeTabBarView:UIView = {
        
        //  daclare coustmeTabBarView as view
        let view = UIView(frame: .zero)
        
        // to make the cornerRadius of coustmeTabBarView
        view.backgroundColor = .white
//        view.layer.cornerRadius = 30
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.clipsToBounds = true
        
        // to make the shadow of coustmeTabBarView
        view.layer.masksToBounds = false
        view.layer.shadowColor = #colorLiteral(red: 0.3879221976, green: 0.3879221678, blue: 0.3879221678, alpha: 1)
        view.layer.shadowOffset = CGSize(width: 0, height: -8.0)
        view.layer.shadowOpacity = 0.12
        view.layer.shadowRadius = 10.0
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        addcoustmeTabBarView()
        hideTabBarBorder()
        
        

    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewDidLayoutSubviews() {
          super.viewDidLayoutSubviews()
          coustmeTabBarView.frame = tabBar.frame
       
      }
    
    

    private func addcoustmeTabBarView() {
       coustmeTabBarView.frame = tabBar.frame
        view.addSubview(coustmeTabBarView)
        view.bringSubviewToFront(self.tabBar)
    }
    
    
    func hideTabBarBorder()  {
        let tabBar = self.tabBar
        tabBar.backgroundImage = UIImage.from(color: .clear)
        tabBar.shadowImage = UIImage()
        tabBar.clipsToBounds = true
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {

        let index = self.tabBar.items?.firstIndex(of: item)
        let subView = tabBar.subviews[index! + 1].subviews.first as! UIImageView
        self.performSpringAnimation(imgView: subView)
    }

    //func to perform spring animation on imageview
    func performSpringAnimation(imgView: UIImageView) {
      
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: {

            imgView.transform = CGAffineTransform.init(scaleX: 1.4, y: 1.4)

            //reducing the size
            UIView.animate(withDuration: 0.5, delay: 0.2, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: {
                imgView.transform = CGAffineTransform.init(scaleX: 1, y: 1)
            }) { (flag) in
            }
        }) { (flag) in

        }


    }
    
    

}

extension UIImage {
    static func from(color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(color.cgColor)
        context!.fill(rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
    }
}
