//
//  UIExtension.swift
//  AppointmentProject
//
//  Created by George on 27.07.2021.
//

import Foundation
import UIKit
import SnapKit

extension UISearchBar {

    enum PlaseholderPosition {
       case center
       case left
   }
    
 func setPlaseholderPosition(_ position:PlaseholderPosition) {
        let textFieldInsideSearchBar = self.value(forKey: "searchField") as? UITextField
        self.backgroundColor = .white
        //get the sizes
        let searchBarWidth = UIScreen.main.bounds.width
        let placeholderIconWidth = textFieldInsideSearchBar?.leftView?.frame.width
        let placeHolderWidth = textFieldInsideSearchBar?.attributedPlaceholder?.size().width
        let offsetIconToPlaceholder: CGFloat = 20
        let placeHolderWithIcon = placeholderIconWidth! + offsetIconToPlaceholder
        let offsetCenter = UIOffset(horizontal: ((searchBarWidth / 2) - (placeHolderWidth! / 2) - placeHolderWithIcon), vertical: 0)
    
        let offsetLeft = UIOffset.zero

      
        switch position {
        case .center:
            self.showsCancelButton = false
            self.setPositionAdjustment(offsetCenter, for: .search)
        case .left:
            self.showsCancelButton = true
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
    
    public func clearView() {
        let navigationClear = UINavigationController()
        self.navigationItem.titleView = navigationClear.navigationItem.titleView
    }
}
extension UITabBarController {
    public func clearView() {
        let navigationClear = UINavigationController()
        self.navigationItem.titleView = navigationClear.navigationItem.titleView
    }
}


extension UIAlertAction {
    var titleTextColor: UIColor? {
        get {
            return self.value(forKey: "titleTextColor") as? UIColor
        } set {
            self.setValue(newValue, forKey: "titleTextColor")
        }
    }
}


  
    extension UITableView {
       private func hasRowAtIndexPath(indexPath: IndexPath) -> Bool {
                return indexPath.section < self.numberOfSections && indexPath.row < self.numberOfRows(inSection: indexPath.section)
            }
        func scrollToBottom(){
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                guard self.numberOfSections != 0 else { return }
                let indexPath = IndexPath(
                    row: self.numberOfRows(inSection:  self.numberOfSections-1) - 1, 
                    section: self.numberOfSections - 1)
                if self.hasRowAtIndexPath(indexPath: indexPath) {
                    self.scrollToRow(at: indexPath, at: .bottom, animated: false)
                }
            }
        }
    }

extension UIView {
    func fillEqual(_ view:UIView) {
        self.snp.makeConstraints { make in
            make.trailing.equalTo(view)
            make.leading.equalTo(view)
            make.top.equalTo(view)
            make.bottom.equalTo(view)
        }
    }
}


extension UIViewController {

    func presentAlertWithTitle(title: String, message: String, options: String... ,style: UIAlertAction.Style, completion: @escaping (String) -> Void) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        for (index, option) in options.enumerated() {
            alertController.addAction(UIAlertAction.init(title: option, style: style, handler: { (action) in
                completion(options[index])
            }))
        }
        self.present(alertController, animated: true, completion: nil)
    }
}
