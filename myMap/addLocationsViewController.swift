//
//  addLocationsViewController.swift
//  myMap
//
//  Created by Alihan Hoylu on 1.09.2023.
//

import UIKit
import MapKit
import CoreData
import CoreLocation

class addLocationsViewController: UIViewController,CLLocationManagerDelegate,MKMapViewDelegate {
    
    @IBOutlet weak var subTitleTextWrite: UITextView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var mapAdd: MKMapView!
    var locationManager = CLLocationManager()
    @IBOutlet weak var addButton: UIButton!
    
    var selectName = String()
    var selectid = String()
    
    var latitudeAddData = Double()
    var longtitudeAddData = Double()
    
    var latitudeShow = Double()
    var longtitudeShow = Double()
    
    override func viewDidLoad() {
        
        if selectName == ""{
            setYourLocation()
            
        }else{
            addButton.titleLabel?.text = "Edit"
            addButton.isHidden = true
            getData()
        }
        
        
        let gestruge = UILongPressGestureRecognizer(target: self, action: #selector(annotion(gestruge:)))
        gestruge.minimumPressDuration = 2
        mapAdd.addGestureRecognizer(gestruge)
        
        let gestrueKeyboard = UITapGestureRecognizer(target: self, action: #selector(closeKeyboard))
        view.addGestureRecognizer(gestrueKeyboard)
    }
    
    @objc func closeKeyboard(){
        view.endEditing(true)
    }
    
    @objc func annotion(gestruge : UILongPressGestureRecognizer){
        
        
        
        if gestruge.state == .began{
            
            let selectedPoint = gestruge.location(in: mapAdd)
            let selectedLocaiton = mapAdd.convert(selectedPoint, toCoordinateFrom: mapAdd)
            
            let annotion = MKPointAnnotation()
            
            annotion.coordinate = selectedLocaiton
            annotion.title = titleTextField.text
            annotion.subtitle = subTitleTextWrite.text
            mapAdd.addAnnotation(annotion)
            latitudeAddData = selectedLocaiton.latitude
            longtitudeAddData = selectedLocaiton.longitude
            
            addButton.isEnabled = true
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: location, span: span)
        mapAdd.setRegion(region, animated: true)
    }
    
    @IBAction func addButtonClicked(_ sender: Any) {
        saveData()
        navigationController?.popViewController(animated: true)
    }
    
    func saveData(){
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let newLocations = NSEntityDescription.insertNewObject(forEntityName: "Location", into: context)
        newLocations.setValue(UUID(), forKey: "id")
        newLocations.setValue(titleTextField.text, forKey: "name")
        newLocations.setValue(subTitleTextWrite.text, forKey: "note")
        newLocations.setValue(latitudeAddData, forKey: "latitude")
        newLocations.setValue(longtitudeAddData, forKey: "longitude")
        
        do{
            try context.save()
            print("no eror")
        }catch{
            print("Eror")
        }
    }
    
    func getData(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Location")
        fetch.predicate = NSPredicate(format: "id = %@", selectid)
        fetch.returnsObjectsAsFaults = false
        
        do{
            let getData = try context.fetch(fetch)
            
            if getData.count > 0 {
                
                for getDataObject in getData as! [NSManagedObject]{
                    
                    if let name = getDataObject.value(forKey: "name") as? String{
                        titleTextField.text = name
                    }
                    
                    if let description = getDataObject.value(forKey: "note") as? String{
                        subTitleTextWrite.text = description
                    }
                    
                    if let latitude = getDataObject.value(forKey: "latitude") as? Double{
                        latitudeShow = latitude
                    }
                    
                    if let longitude = getDataObject.value(forKey: "longitude") as? Double{
                        longtitudeShow = longitude
                    }
                    
                    let annotion = MKPointAnnotation()
                    annotion.title=titleTextField.text
                    annotion.subtitle=subTitleTextWrite.text
                    let coordinate = CLLocationCoordinate2D(latitude: latitudeShow, longitude: longtitudeShow)
                    annotion.coordinate = coordinate
                    mapAdd.addAnnotation(annotion)
                    let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                    let MKCoordinateREgion = MKCoordinateRegion(center: coordinate, span: span)
                    mapAdd.setRegion(MKCoordinateREgion, animated: true)
                    
                }
                
            }
            
        }catch{
            print("eror")
        }
        
    }
    
    func setYourLocation(){
        addButton.isEnabled = false
        super.viewDidLoad()
        mapAdd.delegate = self
        locationManager.delegate = self
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
}
