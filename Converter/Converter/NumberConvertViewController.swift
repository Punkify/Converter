//
//  ViewController.swift
//  Converter
//
//  Created by Developer on 2/12/21.
//

import UIKit

class NumberConvertViewController: UIViewController {
    
    var parser = XMLParser()
    
    var numberToWordResponse:String = ""
    var numberToDollarResponse:String = ""
    
    var content:String = ""
    var newContent:String = ""
        
    @IBOutlet weak var numberToWordTextField: UITextField!
    @IBOutlet weak var showNumberToWordLabel: UILabel!
    
    @IBOutlet weak var numberToDollarTextField: UITextField!
    @IBOutlet weak var showNumberToDollarLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    func textfieldToInteger(from textField: UITextField) -> Int {
        guard let text = textField.text, let number = Int(text) else {
            return 0
        }
        return number
    }
    
    @IBAction func numberToWordPressed(_ sender: Any) {
        
        let number = textfieldToInteger(from: numberToWordTextField)
        let requestBody = """
        <soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope" xmlns:web="http://www.dataaccess.com/webservicesserver/">
           <soap:Header/>
           <soap:Body>
              <web:NumberToWords>
                 <web:ubiNum>\(number)</web:ubiNum>
              </web:NumberToWords>
           </soap:Body>
        </soap:Envelope>
        """
        var request = URLRequest(url: URL(string: "https://www.dataaccess.com/webservicesserver/NumberConversion.wso")!)
        request.setValue("application/soap+xml", forHTTPHeaderField: "Content-Type")
        request.setValue("\(requestBody.count)", forHTTPHeaderField: "Content-Length")
        request.httpMethod = "POST"
        request.httpBody = requestBody.data(using: .utf8)
        
        let session = URLSession(configuration: .default)
        
        session.dataTask(with: request) { data, response, error in
            print("the response is", data)
            self.parser = XMLParser(data: data!)
            self.parser.delegate = self
            self.parser.parse()
        }.resume()
    }
    
    @IBAction func numberToDollarPressed(_ sender: Any) {
        
        let number = textfieldToInteger(from: numberToDollarTextField)
        let requestBody = """
            <soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope" xmlns:web="http://www.dataaccess.com/webservicesserver/">
               <soap:Header/>
               <soap:Body>
                  <web:NumberToDollars>
                     <web:dNum>\(number)</web:dNum>
                  </web:NumberToDollars>
               </soap:Body>
            </soap:Envelope>
            """
        var request = URLRequest(url: URL(string: "https://www.dataaccess.com/webservicesserver/NumberConversion.wso")!)
        request.setValue("application/soap+xml", forHTTPHeaderField: "Content-Type")
        request.setValue("\(requestBody.count)", forHTTPHeaderField: "Content-Length")
        request.httpMethod = "POST"
        request.httpBody = requestBody.data(using: .utf8)
        let session = URLSession(configuration: .default)
        session.dataTask(with: request) { data, response, error in
            self.parser = XMLParser(data: data!)
            self.parser.delegate = self
            self.parser.parse()
        }.resume()
    }
}



extension NumberConvertViewController: XMLParserDelegate {
    
    func parserDidStartDocument(_ parser: XMLParser) {
        numberToWordResponse.removeAll()
        numberToDollarResponse.removeAll()
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        if elementName == "m:NumberToWordsResult" {
            numberToWordResponse.removeAll()
        }
        else if elementName == "m:NumberToDollarsResult" {
            numberToDollarResponse.removeAll()
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "m:NumberToWordsResult" {
            numberToWordResponse = content
        }
        else if elementName == "m:NumberToDollarsResult" {
            numberToDollarResponse = newContent
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        content = string
        newContent = string
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
        
       
        DispatchQueue.main.async {
            self.showNumberToWordLabel.text = self.numberToWordResponse
            self.showNumberToDollarLabel.text = self.numberToDollarResponse
        }
        
    }
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        print(parseError .localizedDescription)
    }
}
