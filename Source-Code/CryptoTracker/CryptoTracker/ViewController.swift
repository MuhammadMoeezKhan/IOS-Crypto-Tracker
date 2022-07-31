//
//  ViewController.swift
//  CryptoTracker
//
//  Created by Moeez Khan on 7/21/22.
//

//Sample JSON Formatted Data from API:
    //{
    //   "rates":{
    //      "btc":{
    //         "name":"Bitcoin",
    //         "unit":"BTC",
    //         "value":1.0,
    //         "type":"crypto"
    //      },
    //      "eth":{
    //         "name":"Ether",
    //         "unit":"ETH",
    //         "value":14.504,
    //         "type":"crypto"
    //      },
    //      "usd":{
    //         "name":"US Dollar",
    //         "unit":"$",
    //         "value":40411.784,
    //         "type":"fiat"
    //      },
    //      "aud":{
    //         "name":"Australian Dollar",
    //         "unit":"A$",
    //         "value":54744.592,
    //         "type":"fiat"
    //      },
    //   }
    //}

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var btcPrice: UILabel!
    
    @IBOutlet weak var ethPrice: UILabel!
    
    @IBOutlet weak var usdPrice: UILabel!
    
    @IBOutlet weak var pkrPrice: UILabel!
    
    @IBOutlet weak var lastUpdatedPrice: UILabel!
    
    let urlString = "https://api.coingecko.com/api/v3/exchange_rates"
        
    override func viewDidLoad()
        {
            super.viewDidLoad()
            
            //function call gets the JSON formatted data from API URl
            //calls created functions accordingly to update main storybaord appropriately
            fetchData()
            
            //updates the view and fetches new data from API JSON Objects every 5 seconds
            _ = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(refreshData), userInfo: nil, repeats: true)
        }
        
    //Objective C function
    //refreshed the view every ten seconds as used by the created timer
    //updates view from the new data fetched from the API URL
        @objc func refreshData() -> Void
        {
            fetchData()
        }
        
    //fetch the JSON data from the API URL
    //
        func fetchData()
        {
            let url = URL(string: urlString)                                        //use url stored in variable
            let defaultSession = URLSession(configuration: .default)                //use defauly swift configurations
            let dataTask = defaultSession.dataTask(with: url!) {
                (data: Data?, response: URLResponse?,error: Error?) in              //unwrap URL data
    
                if(error != nil)
                {
                    print(error!)
                    return
                }
                
                //intilaise JSON object
                do
                {
                    let json = try JSONDecoder().decode(Rates.self, from: data!)    //use created Rates structure
                    self.setPrices(currency: json.rates)                            //created funciton updates view -- send Currency object
                }
                catch
                {
                    print(error)
                    return
                }
                
                
            }
            dataTask.resume()
        }
        
    //function called when intialising JSON objects
    //use the data fetched from url to updates views on the storyboard
        func setPrices(currency: Currency)                                          //takes a Currency object -- as synced with fetched JSON objects
        {
            DispatchQueue.main.async                                                //sync view with specified updates
            {
                self.btcPrice.text = self.formatPrice(currency.btc)                 //update view with String version of the price using created formatPrice function
                self.ethPrice.text = self.formatPrice(currency.eth)
                self.usdPrice.text = self.formatPrice(currency.usd)
                self.pkrPrice.text = self.formatPrice(currency.cad)
                self.lastUpdatedPrice.text = self.formatDate(date: Date())          //uses formatDate function to get current date/time and update view with a string version of the data
            }
        }
        
    //function converts Price --> Stirng
    //recieves a price and return its String converted output
        func formatPrice(_ price: Price) -> String
        {
            return String(format: "%@ %.2f", price.unit, price.value)               //formatted as a String with a Float to 2 Decimal places
        }
        
    
        func formatDate(date: Date) -> String
        {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd MMM y HH:mm:ss"
            return formatter.string(from: date)
        }

        struct Rates: Codable
        {
            let rates: Currency
        }
        
    //using the JSON formatted API data
    //construct and name variables according to what title of each JSON object is
    //we are using only 4 objects from the enitire API JSON dataset
        struct Currency: Codable
        {
            let btc: Price
            let eth: Price
            let usd: Price
            let cad: Price
        }
        
    //using the JSON formatted API data
    //construct and name varibale according to what each JSON object is storing
    //all JSON objects store the same 4 units of data
    //use appriopriate data types -- see sample data
        struct Price: Codable
        {
            let name: String
            let unit: String
            let value: Float
            let type: String
        }
    
}
