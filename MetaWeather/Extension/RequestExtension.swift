//
//  RequestExtension.swift
//  MetaWeather
//
//  Created by 정종문 on 2021/01/18.
//

import UIKit

class RequestExtension {
    let baseURL = "https://www.metaweather.com/api/location"
    
    func createURL(_ subURL: String) -> String{
        return baseURL.appending(subURL)
    }
    
    func getCountryRequest<T : Decodable>(_ urlString: String, completion: @escaping ([T]?) -> Void) {
        if let urlstr: URL = URL(string: urlString) {
            var requestObj = URLRequest(url: urlstr)
            requestObj.httpMethod = "GET"
                        
            URLSession.shared.dataTask(with: requestObj) {
                (data, response, error) in
                
                if let e = error {
                    print("URL Session Task Error (\(urlString)) : \(e.localizedDescription)")
                    return completion(nil)
                }
                
                guard let data = data else {
                    print("Response Data is nil")
                    return completion(nil)
                }
                
                guard let country = try? JSONDecoder().decode([T].self, from: data) else {
                    print("Decoding Error")
                    return completion(nil)
                }
                
                completion(country)
            }.resume()
        }
    }
    
    func getweatherRequest<T : Decodable>(woeid: Int, completion: @escaping (T?) -> ()) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        let year = formatter.string(from: Date())
        formatter.dateFormat = "MM"
        let month = formatter.string(from: Date())
        formatter.dateFormat = "dd"
        let day = formatter.string(from: Date())
        
        let requestURLString: String = RequestExtension().createURL("/\(woeid)/\(year)/\(month)/\(day)")
        var requestObj = URLRequest(url: URL(string: requestURLString)!)
        requestObj.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: requestObj) {
            (data, response, error) in
         
            if let e = error {
                print("URL Session Task Error : \(e.localizedDescription)")
                return completion(nil)
            }
            
            guard let data = data else {
                print("Response Data is nil")
                return completion(nil)
            }
            
            guard let details = try? JSONDecoder().decode(T.self, from: data) else {
                print("Decoding Error")
                return completion(nil)
            }
            
            completion(details)
        }.resume()
    }
    
    func getweatherImage(imageAbbr abbr:String) -> Data? {
        let imageURL: String = "https://www.metaweather.com/static/img/weather/png/64/\(abbr).png"
        if let url: URL = URL(string: imageURL) {
            let imageData = try? Data(contentsOf: url)
            
            guard let data = imageData else {
                return nil
            }
            return data
        }
        return nil
    }
}
