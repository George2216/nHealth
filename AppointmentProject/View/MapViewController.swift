//
//  MapViewController.swift
//  AppointmentProject
//
//  Created by George on 15.07.2021.
//

import UIKit
import MapKit
import RxSwift
import RxCocoa
class MapViewController: UIViewController {
    private let disposeBag = DisposeBag()
    @IBOutlet weak var map: MKMapView!
    var coordinate = BehaviorSubject<(latitude:String,longitude:String,title:String,subtitle:String)>(value: (latitude: "", longitude: "",title:"",subtitle:""))
    private let viewModel = MapViewModel()
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Map"
        
        let output = viewModel.transform(MapViewModel.Input(latitude: coordinate.map{$0.latitude}, longitude: coordinate.map {$0.longitude}, title: coordinate.map {$0.title}, subtitle: coordinate.map {$0.subtitle}))
        
        createMap(output)
        navigationSettings(output)
    }
    
    private func createMap(_ output:MapViewModel.Output) {
        Driver.combineLatest(output.latitude, output.longitude,output.title,output.subtitle).drive { [self] latitude ,  longitude , titleAnnotation , subtitleAnnotation  in
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            annotation.title = titleAnnotation
            annotation.subtitle = subtitleAnnotation
            map.addAnnotation(annotation)

            let initialLocation = CLLocation(latitude: latitude, longitude: longitude)
            let region = MKCoordinateRegion(
                  center: initialLocation.coordinate,
                  latitudinalMeters: 500,
                  longitudinalMeters: 500)
            map.setRegion(region, animated: true)
                
        }.disposed(by: disposeBag)
    }
    
    private func navigationSettings(_ output:MapViewModel.Output) {
        output.titleText.drive(rx.title).disposed(by: disposeBag)
    }
}
