//
//  ViewController.swift
//  classProject
//
//  Created by Jacquelin Huang on 11/3/19.
//  Copyright © 2019 Jacquelin Huang. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class ViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var myMap: MKMapView!
    @IBOutlet weak var searchButton: UIBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()
        initCounter()
    }
    
    let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var counter = 1;
    
    var fetchResults = [CityEntity]()
    var count = 0;
    
    func fetchRecord() -> Int {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CityEntity")
        //let sort = NSSortDescriptor(key: "name", ascending: true)
        //fetchRequest.sortDescriptors = [sort]
        var x = 0
        fetchResults = ((try? managedObjectContext.fetch(fetchRequest)) as? [CityEntity])!
        
        x = fetchResults.count
        
        print(x)

        return x
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchRecord()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cityCell", for: indexPath)
        cell.layer.borderWidth = 1.0
        cell.textLabel?.text = fetchResults[indexPath.row].name
        //cell.detailTextLabel?.text = fetchResults[indexPath.row].details
        
        if let picture = fetchResults[indexPath.row].picture {
            cell.imageView?.image =  UIImage(data: picture  as Data)
        } else {
            cell.imageView?.image = nil
        }
        
        return cell
    }
    
    
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell.EditingStyle { return UITableViewCell.EditingStyle.delete }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath)
    {
        
        if editingStyle == .delete
        {
            
            managedObjectContext.delete(fetchResults[indexPath.row])
            fetchResults.remove(at:indexPath.row)
            
            do {
                try managedObjectContext.save()
            } catch {
                
            }
            cityTable.reloadData()
        }
        
    }
    
    
    
    @IBAction func clickSearch(_ sender: Any) {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.delegate = self
        present(searchController, animated: true, completion: nil)
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //lock rest of the screen
        UIApplication.shared.beginIgnoringInteractionEvents()

        searchBar.resignFirstResponder()
        dismiss(animated: true, completion: nil)
        
        //search request
        //let address = MKLocalSearch.Request()
        //address.naturalLanguageQuery = searchBar.text
        
        let geoCoder = CLGeocoder();
        let addressString = searchBar.text!
        CLGeocoder().geocodeAddressString(addressString, completionHandler:
            {(placemarks, error) in
                
                if error != nil {
                    print("Geocode failed: \(error!.localizedDescription)")
                } else if placemarks!.count > 0 {
                    let placemark = placemarks![0]
                    let location = placemark.location
                    let coords = location!.coordinate
                    print(location)
                   
                    let span = MKCoordinateSpan.init(latitudeDelta: 0.05, longitudeDelta: 0.05)
                    let region = MKCoordinateRegion(center: placemark.location!.coordinate, span: span)
                    self.myMap.setRegion(region, animated: true)
                    let ani = MKPointAnnotation()
                    ani.coordinate = placemark.location!.coordinate
                    ani.title = placemark.locality
                    ani.subtitle = placemark.subLocality
                    
                    self.myMap.addAnnotation(ani)
                    self.count+1;
                    UIApplication.shared.endIgnoringInteractionEvents()
                   
                }
        })
    }
    
    
    @IBAction func addLocation(_ sender: Any) {
        
        if (self.myMap.annotations.isEmpty) {
            print("No address is entered! Cannot add...")
        } else {
            var c = 0;
            if(self.count != 0) {
                c = self.count-1;
            }
            let temp = self.myMap.annotations[c]
            print(temp.title)
            
            
            let ent = NSEntityDescription.entity(forEntityName: "CityEntity", in: self.managedObjectContext)
            let newItem = CityEntity(entity: ent!, insertInto: self.managedObjectContext)

            newItem.name = temp.title!
            newItem.lat = temp.coordinate.latitude
            newItem.lng = temp.coordinate.longitude
            //newItem.details = ""
            updateCounter()

            let alertController = UIAlertController(title: "Add Image", message: "", preferredStyle: .alert)
            
            
            let searchAction = UIAlertAction(title: "Photo Library", style: .default) { (aciton) in
                let name = temp.title!
                //let desc = alertController.textFields![1].text
                newItem.name = name
                //newItem.details = desc
                
                let photoPicker = UIImagePickerController ()
                photoPicker.delegate = self
                photoPicker.sourceType = .photoLibrary
                self.present(photoPicker, animated: true, completion: nil)
            }
            
            let cameraAction = UIAlertAction(title: "Camera", style: .default) { (aciton) in
                let name = temp.title!
                //let desc = alertController.textFields![1].text
                newItem.name = name
                //newItem.details = desc
                
                let picker = UIImagePickerController ()

                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    picker.allowsEditing = false
                    picker.sourceType = UIImagePickerController.SourceType.camera
                    picker.cameraCaptureMode = .photo
                    picker.modalPresentationStyle = .fullScreen
                    self.present(picker,animated: true,completion: nil)
                } else {
                    print("No camera")
                }
            }
            
            
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            }
            
            alertController.addAction(searchAction)
            alertController.addAction(cameraAction)

            alertController.addAction(cancelAction)
            
            self.present(alertController, animated: true, completion: nil)

            do {
                try self.managedObjectContext.save()
            } catch _ {
            }
            
            
            print(newItem)

            cityTable.reloadData()
        }



        
    }
    
    func updateLastRow() {
        let indexPath = IndexPath(row: fetchResults.count - 1, section: 0)
        cityTable.reloadRows(at: [indexPath], with: .automatic)
    }
    
    
    func initCounter() {
        counter = UserDefaults.init().integer(forKey: "counter")
    }
    
    func updateCounter() {
        counter += 1
        UserDefaults.init().set(counter, forKey: "counter")
        UserDefaults.init().synchronize()
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
        
        picker .dismiss(animated: true, completion: nil)

        if let city = fetchResults.last, let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            city.picture = image.pngData()! as NSData as Data
            updateLastRow()
            do {
                try managedObjectContext.save()
            } catch {
                print("Error while saving the new image")
            }
            
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let selectedIndex: IndexPath = self.cityTable.indexPath(for: sender as! UITableViewCell)!
                
        let city = fetchResults[(selectedIndex.row)]
        if(segue.identifier == "detailView"){
            if let viewController: DetailViewController = segue.destination as? DetailViewController {
                viewController.selectedCity = city.name;
                viewController.selectedImage = city.picture;
                viewController.selectedLat = city.lat;
                viewController.selectedLng = city.lng;
            }
        }
    }
    
    @IBOutlet weak var cityTable: UITableView!
    
}

