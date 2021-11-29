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
    private var disposeBag = DisposeBag()
    internal var externalDisposeBag = DisposeBag()
    private let collectionSlotIdentfier = "DoctorTimeCell"
    
    var data:DoctorModelCell? {
        didSet {
            collectionData.onNext(data?.arrayCollection ?? [])
            name.text = data?.name
            profession.text = data?.profession
            myCollcetionViewSlots.layoutSubviews()
            doctorImage?.image = UIImage(named: "doctor")
            self.layoutSubviews()
        }
    }
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var doctorImage: UIImageView!
    @IBOutlet weak var profession: UILabel!
    
    @IBOutlet weak var myCollcetionViewSlots: DynamicHeightCollectionView!
    private let collectionData = PublishSubject<[TimeSlotModel]>()
    internal lazy var selectSlot:Observable<Int> = {
        
        myCollcetionViewSlots.rx.itemSelected.map{$0.row}
    }()
    override func awakeFromNib() {
        super.awakeFromNib()
        createCollection()

    }

    override func prepareForReuse() {
                super.prepareForReuse()
        externalDisposeBag = DisposeBag()
    }
    
    func createCollection() {
        let layout = CollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 90, height: 50)
        myCollcetionViewSlots.setCollectionViewLayout(layout, animated: true)
       
        collectionData.bind(to:myCollcetionViewSlots.rx.items(cellIdentifier: collectionSlotIdentfier, cellType: DoctorTimeCell.self)) { row , slotData , cell in
            cell.textLabel.text = slotData.time
            cell.textLabel.backgroundColor =   #colorLiteral(red: 0.9335836768, green: 0.9536595941, blue: 0.9832097888, alpha: 1)
            cell.textLabel.textColor =  #colorLiteral(red: 0.182285279, green: 0.4131350517, blue: 0.7902112007, alpha: 1)


        }.disposed(by: disposeBag)
        
        
        
    }
    
    
}
