//
//  ViewController.swift
//  myMap
//
//  Created by Alihan Hoylu on 1.09.2023.
//

import UIKit
import MapKit
import CoreData

class ViewController: UIViewController,CLLocationManagerDelegate,MKMapViewDelegate {

    
    @IBOutlet weak var showMyMAp: MKMapView!
    
    var latitude = [Double]()
    var longitude = [Double]()
    var name = [String]()
    var note = [String]()
    
    var annotionName = String()
    var annotionNote = String()
    var annotionLongitude = Double()
    var annotionLatitude = Double()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(addButton))
        navigationController?.navigationBar.topItem?.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.organize, target: self, action: #selector(showLovationsButton))
        getdata()
    }
    
    @objc func addButton(){
        performSegue(withIdentifier: "toAddLocations", sender: nil)
    }
    
    @objc func showLovationsButton(){
        performSegue(withIdentifier: "toViewLocations", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toAddLocations"{
            let mapViewVC = segue.destination as! addLocationsViewController
            mapViewVC.selectName = ""
        }
    }
    
    func getdata(){
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appdelegate.persistentContainer.viewContext
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Location")
        fetch.returnsObjectsAsFaults = false
        
        do{
            let getData = try context.fetch(fetch)
            
            for getDataObject in getData as! [NSManagedObject]{
                
                if let namee = getDataObject.value(forKey: "name") as? String{
                    self.name.append(namee)
                }
                
                if let notee = getDataObject.value(forKey: "note") as? String{
                    self.note.append(notee)
                }
                
                if let longitudee = getDataObject.value(forKey: "longitude") as? Double{
                    self.longitude.append(longitudee)
                }
                
                if let latitudee = getDataObject.value(forKey: "latitude") as? Double{
                    self.latitude.append(latitudee)
                }
                
            }
            annotations()

        }catch{
            print("eror")
        }
        
    }
    
    func annotations(){
        
        for index in 1...name.count{
            let indexRow = index - 1
            annotionName = name[indexRow]
            annotionNote = note[indexRow]
            annotionLatitude = latitude[indexRow]
            annotionLongitude = longitude[indexRow]
            
            let coordinate = CLLocationCoordinate2D(latitude: annotionLatitude, longitude: annotionLongitude)
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = annotionName
            annotation.subtitle = annotionNote
            showMyMAp.addAnnotation(annotation)
        }
        
        
    }


}

