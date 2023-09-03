//
//  viewLocationsViewController.swift
//  myMap
//
//  Created by Alihan Hoylu on 1.09.2023.
//

import UIKit
import CoreData
import CoreLocation

class viewLocationsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    

    @IBOutlet weak var showLocations: UITableView!
    var nameArray = [String]()
    var idArray = [UUID]()
    
    var selectNameSend = String()
    var selectİdSend = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showLocations.delegate = self
        showLocations.dataSource = self
        getData()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = nameArray[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nameArray.count
    }
    
    func getData(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Location")
        fetch.returnsObjectsAsFaults = false
        
        do{
            let data = try context.fetch(fetch)
            
            
            
            for dataObject in data as! [NSManagedObject]{
                
                if let name = dataObject.value(forKey: "name") as? String{
                    nameArray.append(name)
                }
                
                if let idAdd = dataObject.value(forKey: "id") as? UUID{
                    idArray.append(idAdd)
                }
            }
            
        }catch{
            print("eror")
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectNameSend = nameArray[indexPath.row]
        selectİdSend = idArray[indexPath.row].uuidString
        performSegue(withIdentifier: "toShowSelectedInfo", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toShowSelectedInfo"{
            let mapView = segue.destination as! addLocationsViewController
            mapView.selectid = selectİdSend
            mapView.selectName = selectNameSend
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Location")
            let id = idArray[indexPath.row].uuidString
            fetch.predicate = NSPredicate(format: "id = %@", id)
            fetch.returnsObjectsAsFaults = false
            
            do{
                let getData = try context.fetch(fetch)
                
                for getDataObject in getData as! [NSManagedObject]{
                    
                    context.delete(getDataObject)
                    idArray.remove(at: indexPath.row)
                    nameArray.remove(at: indexPath.row)
                    tableView.reloadData()
                    
                    do{
                        try context.save()
                    }catch{
                        print("eror")
                    }
                    break
                }
                
            }catch{
                print("eror")
            }
            
            
        }
    }
}
