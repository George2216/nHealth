//
//  ImageController.swift
//  AppointmentProject
//
//  Created by George on 25.08.2021.
//

import UIKit
import RxSwift
import RxCocoa
class ImageController: UIViewController , Storyboarded {
    private let disposeBag = DisposeBag()
    @IBOutlet weak var doctorImage: UIImageView!
    let imageId = BehaviorRelay<String>(value: "")
    private let viewModel = ImageViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        let output = viewModel.transform(ImageViewModel.Input(idImage: imageId.asObservable()))
        createImage(output)
        
    }
    private func createImage(_ output:ImageViewModel.Output) {
        output.imageData.drive(onNext: { name in
            self.doctorImage.image = UIImage(named: name)
        }).disposed(by: disposeBag)
    }
    
    
       
}
