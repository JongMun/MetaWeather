//
//  WeatherController.swift
//  MetaWeather
//
//  Created by 정종문 on 2021/01/18.
//

import UIKit

class WeatherController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var searchField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    var weatherArray = [Weather]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        searchField.text = "se"
        tableView.isHidden = true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // Get Country Search Function
    @IBAction func callWeatherBtnTap(_ sender: Any) {
        // DataSource Array Clear
        weatherArray.removeAll()
        
        tableView.isHidden = false
        
        // Get Search Keyword
        guard let word: String = self.searchField.text,
              word.isEmpty == false else {
            print("검색할 키워드를 입력해주십시오.")
            tableView.isHidden = true
            return
        }
        
        let requestURLString: String = RequestExtension().createURL("/search/?query=\(word)")
        
        RequestExtension().getCountryRequest(requestURLString, completion: {
            [self] (result:[Country]?) in
            if let country = result {
                for countryItem in country {
                    if let woeid: Int = countryItem.woeid {
                        var getOne = [Weather]()
                        
                        RequestExtension().getweatherRequest(woeid: woeid, completion: {
                            [self] (detailresult:[WeatherDetail]?) in
                            if let details = detailresult {
                                for detail in details {
                                    let formatter = DateFormatter()
                                    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                                    formatter.timeZone = TimeZone(abbreviation: "UTC")
                                    
                                    if let createDate:String = detail.created {
                                        if let convertedDate = formatter.date(from: createDate) {
                                            let weather = Weather(title: countryItem.title, created: convertedDate, weather_state_name: detail.weather_state_name, weather_state_abbr: detail.weather_state_abbr, the_temp: detail.the_temp, humidity: detail.humidity)
                                            
                                            getOne.append(weather)
                                        }
                                    }
                                }
                            }
                            
                            let maxDateRow = getOne.max {
                                (first, second) -> Bool in
                                return first.created > second.created
                            }
                            
                            if let row = maxDateRow {
                                weatherArray.append(row)
                                DispatchQueue.main.async {
                                    tableView.reloadData()
                                }
                            }
                            
                            getOne.removeAll()
                        })
                    }
                }
            }
        })
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weatherArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ListCell", for: indexPath) as? ListCell else {
            return UITableViewCell()
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 MM월 dd일 HH시"
        
        if !weatherArray.isEmpty {
            if let urlDirectory = try? weatherArray[indexPath.row].weather_state_abbr {
                guard let data: Data? = RequestExtension().getweatherImage(imageAbbr: urlDirectory) else {
                    print("Doesn't Load to Image")
                }
                
                cell.imageView?.image = UIImage(data: data!)
            } else {
                // Image : exclamationmark.triangle
                cell.imageView?.image = UIImage(systemName: "exclamationmark.triangle")
            }
            cell.areaLabel.text = weatherArray[indexPath.row].title
            cell.timeLabel.text = formatter.string(from: weatherArray[indexPath.row].created)
            cell.descLabel.text = weatherArray[indexPath.row].weather_state_name
            cell.tempLabel.text = String(weatherArray[indexPath.row].the_temp)
            cell.humiLabel.text = String(weatherArray[indexPath.row].humidity)
        }
        return cell
    }
}

class ListCell: UITableViewCell {
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var areaLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var humiLabel: UILabel!
}
