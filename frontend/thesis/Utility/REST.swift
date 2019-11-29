import Foundation

func post(method:String, endPoint: String, postData: [String:Any], completion: @escaping (NSDictionary?, Int?) -> ()) {
    let data = try! JSONSerialization.data(withJSONObject: postData, options: JSONSerialization.WritingOptions.prettyPrinted)
    print("postData = \(postData)")
    
    let json = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
    if let json = json {
        print(json)
    }
    let jsonData = json!.data(using: String.Encoding.utf8.rawValue);
    
    let url = URL(string: "https://diet-thesis.herokuapp.com/\(endPoint)")!
    print("url = \(url)")
    var request = URLRequest(url: url)
    request.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
    request.setValue("Bearer \(AuthData.shared.accessToken)", forHTTPHeaderField: "Authorization")
    request.httpMethod = method
    request.httpBody = jsonData

    post(method: method, endPoint: endPoint, request: request, completion: completion)
}

func post(method:String, endPoint: String, postString: String, completion: @escaping (NSDictionary?, Int?) -> ()) {
    print("postString = \(postString)")

    let url = URL(string: "https://diet-thesis.herokuapp.com/\(endPoint)")!
    print("url = \(url)")
    var request = URLRequest(url: url)
    request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
    request.setValue("Bearer \(AuthData.shared.accessToken)", forHTTPHeaderField: "Authorization")
    request.httpMethod = method
    request.httpBody = postString.data(using: .utf8)

    post(method: method, endPoint: endPoint, request: request, completion: completion)
}

func post(method:String, endPoint: String, request: URLRequest, completion: @escaping (NSDictionary?, Int?) -> ()) {
    
    DispatchQueue.main.async {
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                return // check for fundamental networking error
            }
            
            var statusCode: Int? = nil
            if let response = response as? HTTPURLResponse {
                statusCode = response.statusCode
            }
            // Getting values from JSON Response
            let responseString = String(data: data, encoding: .utf8)
            print("responseString = \(String(describing: responseString))")
            do {
                let jsonResponse = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions()) as? NSDictionary
                completion(jsonResponse, statusCode)
            }catch _ {
                print ("OOps not good JSON formatted response")
            }
        }
        task.resume()
    }
}
