//
//  DoctorCell.swift
//  AppointmentProject
//
//  Created by George on 16.07.2021.
//

import UIKit
import RxSwift
import RxCocoa

class DoctorCell: UITableViewCell {
    let disposeBag = DisposeBag()
    var data:DoctorModelCell? {
        
        didSet {
            collectionData.onNext(data?.arrayCollection ?? [])
            name.text = data?.name
            subdivision.text = data?.subdivision
            profession.text = data?.profession
            
            myCollcetionViewSlots.layoutSubviews()
            self.layoutSubviews()
            index = 0
        }
    }
    
    var index = 0
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var profession: UILabel!
    @IBOutlet weak var subdivision: UILabel!
    @IBOutlet weak var myCollcetionViewSlots: DynamicHeightCollectionView!
    let collectionData = PublishSubject<[String]>()
    var delegateSelect:SelectTimeSlotProtocol?
    override func awakeFromNib() {
        super.awakeFromNib()
        createCollection()

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

    func createCollection() {
        let layout = CollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 90, height: 50)
      
        myCollcetionViewSlots.setCollectionViewLayout(layout, animated: true)
        
        collectionData.bind(to:myCollcetionViewSlots.rx.items(cellIdentifier: "DoctorTimeCell", cellType: DoctorTimeCell.self)) { [self] row , titleLabel , cell in
           
            cell.textLabel.text = titleLabel
            let isSelected = index == row
            cell.textLabel.backgroundColor = isSelected ? .systemBlue : #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 0.1698313328)
            cell.textLabel.textColor = isSelected ? .white : .systemBlue
            
        }.disposed(by: disposeBag)
        
        
        myCollcetionViewSlots.rx.itemSelected.subscribe(onNext: {[self] indexPath in
            index = indexPath.row
            delegateSelect?.selectSlot(docId: data?.docId ?? "" , rowSlot: indexPath.row)
            myCollcetionViewSlots.reloadData()
        }).disposed(by: disposeBag)
    }
    
    
}
