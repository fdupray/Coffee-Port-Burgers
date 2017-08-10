//
//  ViewController.swift
//  Coffee Port Burgers
//
//  Created by Frederick Dupray on 09/08/2017.
//  Copyright © 2017 Nattr. All rights reserved.
//

import UIKit
import Kingfisher
import ReachabilitySwift

class BurgerTableViewController: UITableViewController {
    
    /* NOTES as seen in README:
    
    - Kingfisher, Reachability and Gloss were installed with cocoapods. 
     
    - No unit tests. Writing tests would've greatly increased development time.
     
    - App can be used horizontally too.
     
    - This table view controller is embedded in a navigation controller in storyboard. Although it isn't needed in this test, it makes for better design and presentation (prevents table view from going under status bar
    
     - Hard coded values have been done so consciously (referring to Color Literals in cellForRow func mainly).
    */
    
    //API link.
    let api = "http://coffeeport.herokuapp.com"
    
    //Store burgers.
    var arrayOfBurgers: [Burger] = [Burger]()
    
    //Check for internet connection
    let reachability = Reachability()!
    
    let pathOfTheBurger = "/burgers"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Necessary for automatic cell height. This is the size of our largest cell.
        tableView.estimatedRowHeight = 176
        
        //Fetch burgers
        fetchBurgerObjects()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //Set up reachability notififier.
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged), name: ReachabilityChangedNotification, object: nil)
        do {
            
            try reachability.startNotifier()
            
        } catch {
            
            print("Could not start reachability notifier")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
    }
    
    //Called when reachability changes.
    func reachabilityChanged() {
        self.tableView.reloadData()
    }
    
    //Self descriptive
    func fetchBurgerObjects () {
        
        //Stretch path to burgers in URL
        let urlString = URL(string: api.appending(pathOfTheBurger))!
        
        //URL GET request
        var request = URLRequest(url: urlString)
        
        request.httpMethod = "GET"

        //Use cached data if cache is validated.
        request.cachePolicy = .returnCacheDataElseLoad
        
        //Check extensions at bottom of script for this method.
        self.burgerTaskInBackground(request: request) { (data, error) in
            
            if let data = data {
                
                //Parse data
                do {
                    
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any], let burgers = json["burgers"] as? [[String: Any]] {
                        
                        for burger in burgers {
                            
                            let burgerObject = Burger(json: burger)
                            
                            self.arrayOfBurgers.append(burgerObject!)
                        }
                    }
                    
                    //Promotions become first elements of array.
                    self.arrayOfBurgers.sort { $0.isPromoted && !$1.isPromoted }
                    
                    DispatchQueue.main.sync {
                        
                        self.tableView.reloadData()
                    }
                    
                } catch {
                    
                    //Parsing error!
                    self.presentAlert("PARSING ERROR", "\(error)", nil)
                }
            }
            
            else {
                
                //Error occured.
                print(error?.localizedDescription ?? "UNIDENTIFIED ERROR.")
            }
        }
    }
    
    
    
    //-- Table view delegate / data source methods.
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //Show no burgers cell if array is empty.
        if self.arrayOfBurgers.isEmpty {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "NoBurgersCell")!
            
            return cell
        }
        
        //Array isn't nil, nor is it empty. Proceed.

        //Get burger in question
        let burger = self.arrayOfBurgers[indexPath.row]
        
        //Reuse correct cell.
        
        //Unwrap to avoid compiler crash.
        let reuseId = burger.isPromoted! ? "PromotedBurgerTableViewCell" : "BurgerTableViewCell"
        
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseId) as! BurgerTableViewCell
        
        cell.selectionStyle = .none
        
        //Give burger data to cell.
        cell.enterBurgerInfo(burger)
        
        //Allow user to purchase burger.
        cell.purchaseItemButton.addTarget(self, action: #selector(confirmPurchase(_:)), for: .touchUpInside)
        
        //Only enabled when we are connected.
        cell.purchaseItemButton.isEnabled = self.reachability.isReachable
        //Hard coding values for test only.
        cell.purchaseItemButton.backgroundColor = self.reachability.isReachable ? #colorLiteral(red: 0.9277763963, green: 0.2847055495, blue: 0.2086157799, alpha: 1) : #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        
        //Load image in background using kingfisher library.
        let imageURL = URL(string: api.appending(burger.imageLinkString))!
        let imageResource = ImageResource(downloadURL: imageURL)
        
        if burger.isPromoted {
        
            cell.burgerImageView.kf.setImage(with: imageResource, placeholder: UIImage(named: "placeholder_BIG"))
            
            //Add shadow for increased visibility
            cell.burgerNameLabel.layer.shadowOffset = CGSize(width: 0, height: 0)
            cell.burgerNameLabel.layer.shadowOpacity = 1
            cell.burgerNameLabel.layer.shadowRadius = 6
        }
        
        else {
            
            cell.burgerImageView.kf.setImage(with: imageResource, placeholder: UIImage(named: "placeholder"))
        }
        
        return cell
    }

    //Determine cells that can be selected.
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        
        //Only burger cells are selectable.
        if let _ = tableView.cellForRow(at: indexPath) as? BurgerTableViewCell {
            
            return indexPath
            
        }

        return nil
    }
    
    //Present burger notes
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //Present burger note with "sounds delicious" button.
        let burger = self.arrayOfBurgers[indexPath.row]
        
        let close = UIAlertAction(title: "Close", style: .default, handler: nil)
        
        self.presentAlert("\(burger.burgerName!) notes", burger.burgerNotes, [close])
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        //Return amount of cells in array of burgers otherwise return 1 (for "where are the burgers?" cell).
        if !self.arrayOfBurgers.isEmpty {
            
            return self.arrayOfBurgers.count
        }
        
        else {
            
            //Error cell will be presented.
            return 1
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
     
        //Unsure whether you wanted 2 distinct sections. So I sorted array and placed promotion cells on top. This decision was influenced by the example image provided.
        
        //All cells will be in the same section.
        return 1
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        //Automatically set cell height. Height is determined by layout constraints in storyboard.
        return UITableViewAutomaticDimension
    }
    
    //--
    
    
    //Show purchase confirmation 
    func confirmPurchase (_ sender: UIButton) {
        
        //--Detect burger from touch coordinates.
        let point = sender.convert(CGPoint.zero, to: tableView)
        
        let burger = self.arrayOfBurgers[tableView.indexPathForRow(at: point)!.row]
        //--
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let buyBurger = UIAlertAction(title: "Purchase!", style: .default) { (action) in
            
            let dataToUpload = ["id": burger.id!, "bitcoin": burger.burgerPrice!]
            
            guard let jsonData = try? JSONSerialization.data(withJSONObject: dataToUpload) else {
                
                self.presentAlert("Error", "Couldn't process your order", nil)
                
                return
            }
            
            
            //POST request
            var request = URLRequest(url: URL(string: self.api.appending(self.pathOfTheBurger))!)
            
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = jsonData
            
            
            self.burgerTaskInBackground(request: request, completion: { (data, error) in
                
                if data != nil {
                    
                    do {
                        
                        if let json = try JSONSerialization.jsonObject(with: data!) as? [String: Any] {
                            
                            print("DATA: \(json)")
                        }
                        
                    } catch {
                        
                        print(error.localizedDescription)
                    }
                    
                    //Successfully uploaded.
                    
                    let close = UIAlertAction(title: "Close", style: .default, handler: nil)
                    
                    //UI updates executed on main queue.
                    DispatchQueue.main.async {
                        
                        self.presentAlert("Thank you for your order", "Prepare for a rich gustatory experience of intergalactic dimensions", [close])
                    }
                }
                
                else {
                    
                    print(error?.localizedDescription ?? "Data unavailable")
                }
            })
        }

        self.presentAlert("Confirm purchase", "Would you like to purchase a \(burger.burgerName!) for ฿\(burger.burgerPrice!)", [buyBurger, cancel])
    }
}

//Avoid repeating code.
extension BurgerTableViewController {
    
    
    //Used as extension because no need for other classes.
    //@escaping -> Closure invoked after function returns.
    func burgerTaskInBackground (request: URLRequest, completion: @escaping (_ data: Data?, _ error: Error?) -> ()) {
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            guard let data = data, error == nil, let _ = response else {
                
                completion(nil, error)
                
                return
            }
            
            completion(data, error)
        }
        
        task.resume()
    }
    
    func presentAlert(_ title: String, _ message: String, _ actions: [UIAlertAction]?) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        if let actions = actions {
            
            for action in actions {
                
                alert.addAction(action)
            }
        }
            //Default action
        else {
            
            let ok = UIAlertAction(title: "Ok", style: .default, handler: nil)
            
            alert.addAction(ok)
        }
        
        self.present(alert, animated: true, completion: nil)
    }
}

