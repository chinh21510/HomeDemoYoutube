//
//  YoutubeParser.swift
//  HomeYoutubeDemo
//
//  Created by Chinh Dinh on 7/9/20.
//  Copyright © 2020 Chinh Dinh. All rights reserved.
//

import UIKit

public extension NSURL {

func dictionaryForQueryString() -> [String: AnyObject]? {
    if let query = self.query {
        return query.dictionaryFromQueryStringComponents()
    }


    let result = absoluteString?.components(separatedBy: "?")
    if result!.count > 1 {
        return result!.last?.dictionaryFromQueryStringComponents()
    }
    return nil
}
}

public extension NSString {

func stringByDecodingURLFormat() -> String {
    let result = self.replacingOccurrences(of: "+", with: " ")
    return result.removingPercentEncoding!
}

func dictionaryFromQueryStringComponents() -> [String: AnyObject] {
    var parameters = [String: AnyObject]()
    for keyValue in components(separatedBy: "&") {
        let keyValueArray = keyValue.components(separatedBy: "=")
        if keyValueArray.count < 2 {
            continue
        }
        let key = keyValueArray[0].stringByDecodingURLFormat()
        let value = keyValueArray[1].stringByDecodingURLFormat()
        parameters[key] = value as AnyObject
    }
    return parameters
}
}

public class YoutubeUrlReciver: NSObject {
static let infoURL = "http://www.youtube.com/get_video_info?video_id="
static var userAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_2)  AppleWebKit/537.4 (KHTML, like Gecko) Chrome/22.0.1229.79 Safari/537.4"

public static func h264videosWithYoutubeID(youtubeID: String) -> [String] {
    let urlString = String(format: "%@%@", infoURL, youtubeID) as String
    let url = NSURL(string: urlString)!
    let request = NSMutableURLRequest(url: url as URL)
    request.timeoutInterval = 5.0
    request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
    request.httpMethod = "GET"
    var responseString = NSString()
    let session = URLSession(configuration: URLSessionConfiguration.default)
    let group = DispatchGroup()
    group.enter()
    session.dataTask(with: request as URLRequest, completionHandler: { (data, response, _) -> Void in
        if let data = data as NSData? {
            responseString = NSString(data: data as Data, encoding: String.Encoding.utf8.rawValue)!
        }
        group.leave()
    }).resume()
    group.wait()
    let parts = responseString.dictionaryFromQueryStringComponents()
    let pr = parts["player_response"] as! String
    if let data = pr.data(using: .utf8) {
        do {
            let data = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
            let streamingData = data["streamingData"] as! [String: Any]
            let adaptiveFormats = streamingData["adaptiveFormats"] as! [[String: Any]]
            return adaptiveFormats.compactMap { $0["url"] as? String }
        } catch {
            print(error.localizedDescription)
        }
    }
    return []
}
public static func h264videosWithYoutubeURL(id: String,completion: ((
    _ videoInfo: [String], _ error: NSError?) -> Void)?) {
    DispatchQueue.global().async {
        let urls = self.h264videosWithYoutubeID(youtubeID: id)
        DispatchQueue.main.async {
            completion?(urls, nil)
        }
    }
}
}
