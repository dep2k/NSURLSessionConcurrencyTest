//
//  ViewController.swift
//  ImageDownloader
//
//  Created by Deep Arora on 7/18/18.
//  Copyright © 2018 Deep Arora. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, URLSessionDelegate {

    var downloads = Dictionary<URL,Download>()
    
    lazy var session: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.httpMaximumConnectionsPerHost = 1
        configuration.timeoutIntervalForRequest = 10
        return URLSession(configuration: configuration, delegate: self as URLSessionDelegate, delegateQueue: nil)
    }()
    

    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.downloadImages()
        // Do any additional setup after loading the view, typically from a nib.
    }

    
   private func downloadImages() {
        
        let documentsUrl:URL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        print("HomeDirectory:\(documentsUrl.absoluteString)");
        self.createDownloadItems()
    }
    

    
    func downloadItem(_ downloadItem: Download) {
        
        let documentsUrl:URL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let destinationFileUrl = documentsUrl.appendingPathComponent(downloadItem.url.absoluteString)
        
        let downloadUrl =  downloadItem.url
        let request = URLRequest(url:downloadUrl)
        
        downloadItem.state = .InProgress
        let task = session.downloadTask(with: request) { (tempLocalUrl, response, error) in
            if let tempLocalUrl = tempLocalUrl, error == nil {
                // Success
                
                downloadItem.state = .Downloaded
                if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                    print("Successfully downloaded. Status code: \(statusCode)")
                }
                /*
                do {
                    try FileManager.default.copyItem(at: tempLocalUrl, to: destinationFileUrl)
                } catch (let writeError) {
                    print("Error creating a file \(destinationFileUrl) : \(writeError)")
                }*/
                
            } else {
                downloadItem.state = .Failed
                print("Error took place while downloading a file. Error description: %@", error?.localizedDescription ?? "Some Error");
            }
        }
        
        task.resume()
    }
    
    
    
    func createDownloadItems() {
       
        for i in 1...200{
            
            let urlString = "http://placehold.it/1200x1200&text=\(i)"
            if let downloadUrl =  URL(string: urlString) {
                
                let download = Download(url: downloadUrl)
                downloads[download.url] = download
                self.downloadItem(download)
            }
    
        }
    }

}


enum DownloadState: Int {
    
   case New ,
    InProgress,
    Failed,
    Downloaded
    
}


class Download {
    
    let url: URL
    var task: URLSessionDownloadTask?
    var state = DownloadState.New
    var image = UIImage(named: "placeholder")
    
    init(url: URL) {
        self.url = url
    }
}
