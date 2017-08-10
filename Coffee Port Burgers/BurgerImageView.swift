//
//  BurgerImageView.swift
//  Coffee Port Burgers
//
//  Created by Frederick Dupray on 09/08/2017.
//  Copyright © 2017 Nattr. All rights reserved.
//

import UIKit
import Kingfisher

class BurgerImageView: UIImageView {

    private var task: URLSessionDataTask!

    func loadImageDataFromURLInBackground (url: URL) {
        
        var request = URLRequest(url: url)
        
        request.httpMethod = "GET"
        
        //Data takes a while to load. So I opted to go for cached data whenever available.
        request.cachePolicy = .returnCacheDataElseLoad
        
        let session = URLSession(configuration: .default)
        
        self.task = session.dataTask(with: request, completionHandler: { (data, response, error) in
            
            guard error == nil, let data = data, let _ = response else {
                
                //Error occured.
                print(error?.localizedDescription ?? "UNIDENTIFIED ERROR.")
                
                return
            }
            
            DispatchQueue.main.sync {
                
                self.image = UIImage(data: data)
            }
        })
        
        self.task.resume()
    }
    
    func cancelLoad () {
        
        if task != nil {
            
            task.cancel()
        }
    }
}
