//
//  DetailViewController.swift
//  classProject
//
//  Created by Jacquelin Huang on 11/20/19.
//  Copyright © 2019 Jacquelin Huang. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    var temperature:Double?
    var selectedCity:String?
    var selectedImage:Data?
    var selectedLat:Double?
    var selectedLng:Double?

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageLabel: UIImageView!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var currTempLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.titleLabel.text = selectedCity
        self.imageLabel.image = UIImage(data: selectedImage!)
        // Do any additional setup after loading the view.
        self.tempLabel.text = "Longitude: \(selectedLat!) Latitude: \(selectedLng!)"
        
        DispatchQueue.main.async(execute: {
            self.getRequest()
        })
    }
    
    func getRequest(){
        //add you own key here
        let urlString = "https://api.darksky.net/forecast/ADD-YOUR-KEY-HERE/\(selectedLat!),\(selectedLng!)"
        
        let url = URL(string: urlString)!
        
        let urlSession = URLSession.shared

        
        let jsonQuery = urlSession.dataTask(with: url, completionHandler: { data, response, error -> Void in
        if (error != nil) {
            print(error!.localizedDescription)
        }
        var err: NSError?
        
        var jsonResult = (try! JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers)) as! NSDictionary
        if (err != nil) {
            print("JSON Error \(err!.localizedDescription)")
        }
        
        print(jsonResult)
            
            let x = jsonResult as? [String: AnyObject]
            let z = x?["currently"] as? [String: AnyObject]
            let currTemp = (z?["temperature"])!
            self.currTempLabel.text = "\(currTemp)"
            
            })
        
        jsonQuery.resume()
        

    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
