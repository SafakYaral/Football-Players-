//
//  AddPlayersVC.swift
//  FootballPlayers1
//
//  Created by Safak Yaral on 8.01.2025.
//

import UIKit
import CoreData

class AddPlayersVC: UIViewController , UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    
    @IBOutlet weak var pickerLabel: UILabel!
    @IBOutlet weak var cImageView: UIImageView!
    
   
    @IBOutlet weak var cNameText: UITextField!
    @IBOutlet weak var cRateText: UITextField!
    @IBOutlet weak var cTeamText: UITextField!
    @IBOutlet weak var cAgeText: UITextField!
    @IBOutlet weak var cNationalityText: UITextField!
    
    
    
    var chosenPlayer = ""
    var chosenPlayerId : UUID?
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if chosenPlayer != "" {
            //coredata
            // verileri veri tabanından göstermek için yaptığımız işlemler.
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Details")
            let idString = chosenPlayerId?.uuidString
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString!)
            fetchRequest.returnsObjectsAsFaults = false
            
            do{
                let results = try context.fetch(fetchRequest)
                
                
                if results.count > 0 {
                    for result in results as! [NSManagedObject] {
                        
                        if let name = result.value(forKey: "name") as? String{
                            cNameText.text = name
                        }
                        if let year = result.value(forKey: "age") as? Int{
                            cAgeText.text = String(year)
                        }
                        if let rate = result.value(forKey: "rate") as? Int{
                            cRateText.text = String(rate)
                        }
                        if let team = result.value(forKey: "team") as? String{
                            cTeamText.text = team
                        }
                        if let nationality = result.value(forKey: "nationality") as? String{
                            cNationalityText.text = nationality
                        }
                        
                        if let imageData = result.value(forKey: "image") as? Data{
                            let image = UIImage(data: imageData)
                            cImageView.image = image
                        }
                        
                        
                    }
                }
                
            }catch {
                print("error")
                
            }
      
            }
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeybord))
        view.addGestureRecognizer(gestureRecognizer)
        
        cImageView.isUserInteractionEnabled = true
        let imageTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        view.addGestureRecognizer(imageTapRecognizer)
        

    }
    
    @objc func hideKeybord(){
        view.endEditing(true)
    }
    
    @objc func imageTapped(){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        cImageView.image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func makeAlert(titleInput: String , messageInput: String){
        let alert = UIAlertController(title: titleInput, message: messageInput, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    

    @IBAction func saveClicked(_ sender: Any) {
        
        
        if cNameText.text == "" || cRateText.text == "" || cAgeText.text == "" || cTeamText.text == "" || cImageView.image == nil{
            makeAlert(titleInput: "Error", messageInput: "Please Fill All Fields")
            
        }else {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let newPlayer = NSEntityDescription.insertNewObject(forEntityName: "Details", into: context)
            
            //Attributes
            // her bir yeni resimi veri tabanına ekler ama burda dikkat etmemizz gereken attiribute lara verdiğimiz isimlerle aynı isimleri verip o şekilde kayıt işlemi gerçekleşir.
            
           
            newPlayer.setValue(cNameText.text, forKey: "name")
            newPlayer.setValue(cTeamText.text, forKey: "team")
            newPlayer.setValue(cNationalityText.text, forKey: "nationality")
            
            if let year = Int(cAgeText.text!)  {
                newPlayer.setValue(year, forKey: "age")
                
            }
            if let rate = Int(cRateText.text!)  {
                newPlayer.setValue(rate, forKey: "rate")
                
            }
            
            newPlayer.setValue(UUID(), forKey: "id")
            
            let data = cImageView.image!.jpegData(compressionQuality: 0.5)
            
            newPlayer.setValue(data, forKey: "image")
            
            do {
                try context.save()
                print("success")
            }catch{
                print("error")
            }
            
            NotificationCenter.default.post(name: NSNotification.Name("newData"), object: nil) // view controllerlar arasında mesaj yollamaya yarar.
            self.navigationController?.popViewController(animated: true)
            
            
        }
        
            
    }
    
    

}
