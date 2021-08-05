//
//  UIExtension.swift
//  AppointmentProject
//
//  Created by George on 27.07.2021.
//

import Foundation
import UIKit

extension UISearchBar {

    enum PlaseholderPosition {
       case center
       case left
   }
    
 func setPlaseholderPosition(_ position:PlaseholderPosition) {
        let textFieldInsideSearchBar = self.value(forKey: "searchField") as? UITextField

        //get the sizes
        let searchBarWidth = self.frame.width
        let placeholderIconWidth = textFieldInsideSearchBar?.leftView?.frame.width
        let placeHolderWidth = textFieldInsideSearchBar?.attributedPlaceholder?.size().width
        let offsetIconToPlaceholder: CGFloat = 20
        let placeHolderWithIcon = placeholderIconWidth! + offsetIconToPlaceholder
        let offsetCenter = UIOffset(horizontal: ((searchBarWidth / 2) - (placeHolderWidth! / 2) - placeHolderWithIcon), vertical: 0)
    
        let offsetLeft = UIOffset.zero

        
        switch position {
        case .center:
            self.setPositionAdjustment(offsetCenter, for: .search)
        case .left:
            self.setPositionAdjustment(offsetLeft, for: .search)
        }
   }
}

// complition to navigation pop&push
extension UINavigationController {
    public func pushViewController(viewController: UIViewController,
                                   animated: Bool,
                                   completion: (() -> Void)?) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        pushViewController(viewController, animated: animated)
        CATransaction.commit()
    }

    public func popViewController(animated: Bool,
                                  completion: (() -> Void)?) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        popViewController(animated: animated)
        CATransaction.commit()
    }
}
