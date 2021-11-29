//
//  SubdivisionCell.swift
//  AppointmentProject
//
//  Created by George on 15.07.2021.
//

import UIKit

class SubdivisionCell: UITableViewCell {
    internal var delegate:MapDelegate?
    internal var model:CenterListModel? {
        didSet {
            if let model = model {
            profession.text = model.name
            adress.text = "\(model.city  + ", " + model.address)"
            }
        }
    }
    @IBOutlet weak var profession: UILabel!
    @IBOutlet weak var adress: UILabel!
    
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    @IBAction func mapAction(_ sender: Any) {
        delegate?.showMap(content: CoordinateModel(latitude: model?.longitude ?? "", longitude: model?.latitude ?? "", title: model?.name ?? "" , subtitle: model?.address ?? ""))

//      
    }
    

}
