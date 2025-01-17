//
//  ViewController.swift
//  FootballPlayers1
//
//  Created by Safak Yaral on 8.01.2025.
//

import UIKit
import CoreData

class ViewController: UIViewController , UITableViewDataSource , UITableViewDelegate {
  
    

    @IBOutlet weak var tableView: UITableView!
    
    var nameArray = [String]()
    var idArray = [UUID]()
    
    var selectedPlayer = ""
    var selectedPlayerId: UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAddPlayerButton))
        
        getData()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(getData), name: NSNotification.Name("newData"), object: nil) // eklediğimiz datayı table viewda hemen gördük.
    }
   
    @objc func getData(){
        
        nameArray.removeAll(keepingCapacity: true)
        idArray.removeAll(keepingCapacity: true)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Details") // getirme isteği oluşturduk ve aslında database de verileri name ve id si ile tuttuk.
        fetchRequest.returnsObjectsAsFaults = false // geri döndüğünde nesne silinmemesi için yaptık.
        
        do{
            
            let results = try context.fetch(fetchRequest) // olası bir hatada yakalama işlemi uyguladık
            if results.count > 0{
                
            }
            
            for result in results as! [NSManagedObject] {
                
                if let name = result.value(forKey: "name") as? String{
                    self.nameArray.append(name)
                }
                if let id = result.value(forKey: "id") as? UUID{
                    self.idArray.append(id)
                }
                
                self.tableView.reloadData()
            }
            
        }catch{
            print("error")
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nameArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell() // table view cell in özelliklerini cell e aktardık.
        var content = cell.defaultContentConfiguration() // default cell konfigirasyonunu içerik değişkenine eşitledik
        
        content.text = nameArray[indexPath.row] //gelecek olan içerikleri bir dizide tuttuk
        cell.contentConfiguration = content
        return cell
        
    }
    @objc func didTapAddPlayerButton(){
        selectedPlayer = ""
        performSegue(withIdentifier: "toAddPlayersVC", sender: nil)
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) { // segue yapmak için hazırlandık yani name ile name id ile id matchlendi
        
        if segue.identifier == "toAddPlayersVC" { //eğer segue id si todetailsvc ise varış noktasını detailsvc olarak tanımladık.
            
            let destinationVC = segue.destination as! AddPlayersVC
            destinationVC.chosenPlayer = selectedPlayer // kullanıcı hücredeki isme tıkladığında doğru resmin açılmasını name ve id yi eşitleyerek sağladık.
            destinationVC.chosenPlayerId = selectedPlayerId
            
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) { //herhangi bir hücreye tıkladığımızda gidilcek lokasyon bilgilerini verdik.
        selectedPlayer = nameArray[indexPath.row]
        selectedPlayerId = idArray[indexPath.row]
        performSegue(withIdentifier: "toAddPlayersVC", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            nameArray.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic) 
            
        }
    }
}

