//
//  ImageCacheable.swift
//  ImageCacheable
//
//  Created by Shabeer Hussain on 23/11/2016.
//  Copyright © 2016 Desert Monkey. All rights reserved.
//

import Foundation
import UIKit

protocol ImageCacheable {
    /**
     Retrieves an image from the local file system. If the image does not exist it will save it
     */
    func localImage(forKey key: String, from remoteUrl: URL, completion:@escaping ((UIImage?, String) -> Void))
    
    /**
     Retrieves an image from the in memory cache. These images are not persisted across sessions
     */
    func inMemoryImage(forKey key: String, from url: URL, completion:@escaping ((UIImage?, String) -> Void))
    
    /**
     Folder name needs to be initialized by dedicated cache object if using local file storage
     */
    var imageFolderName: String? {get}
    
    /**
     Cache object to be initialized by the conforming object if using in-memory storage
     */
    var inMemoryImageCache: NSCache<AnyObject, UIImage>? {get}
}

extension ImageCacheable {
    
    //set both properties to nil so they are optional to implement by the conforming object
    var imageFolderName: String? { return "ImageCacheable" }
    var inMemoryImageCache:  NSCache<AnyObject, UIImage>? { return NSCache<AnyObject, UIImage>() }
    
    //MARK:- Image Fetching
    
    func localImage(forKey key: String, from remoteUrl: URL, completion:@escaping ((UIImage?, String) -> Void)) {
        
        //create the file path
        let documentsDir = imageDirectoryURL().path
        var filePathString = "\(documentsDir)/\(key)"
        //get the file extension
        if let fileExtension = fileExtension(for: remoteUrl) {
            filePathString.append(fileExtension)
        }
        //next create the localURL
        let localURL = URL(fileURLWithPath: filePathString)
        
        //checks if the image should be saved locally
        let imageExistsLocally = self.fileExists(at: filePathString)
        
        //creates the data url from where to fetch, can be local or remote
        let dataURL = imageExistsLocally ? localURL : remoteUrl
        
        //finally fetch the image, pass in the localURL if we need to save it locally
        self.fetchImage(from: dataURL, saveTo: (imageExistsLocally ? nil : localURL)) { image  in
            
            //grab main thread, as its more than likley this will serve UI layers
            DispatchQueue.main.sync {
                completion(image, key)
            }
        }
    }
    
    func inMemoryImage(forKey key: String, from url: URL, completion:@escaping ((UIImage?, String) -> Void)) {
        
        guard let inMemoryImageCache = inMemoryImageCache else {
            fatalError("ERROR: in Memory Image Cache must be set in order to use in-memory image cache")
        }
        
        if let cachedImage = inMemoryImageCache.object(forKey: key as AnyObject) {
            completion(cachedImage, key)
        } else {
            
            fetchImage(from: url, saveTo: nil, completion: { (image) in
                if let image = image {
                    inMemoryImageCache.setObject(image, forKey: key as AnyObject)
                }
                completion(image, key)
            })
        }
    }
    
    /**
     Creates the UIImage from either local or remote url. If remote, will save to disk
     */
    private func fetchImage(from url: URL,
                            saveTo localURL: URL?,
                            session: URLSession = URLSession.shared,
                            completion:@escaping ((UIImage?) -> Void)) {
        
        session.dataTask(with: url) { (imageData, response, error) in
            do {
                guard
                    let imageData = imageData,
                    let image = UIImage(data: imageData)
                    else {
                        completion(nil)
                        return
                }
                
                //save if the localURL exists
                if let localURL = localURL {
                    try imageData.write(to: localURL, options: .atomic)
                }
                completion(image)
                
            } catch {
                debugPrint(error.localizedDescription)
                completion(nil)
            }
            }.resume()
    }
    
    //MARK:- Cache Management
    
    /**
     Deletes the image files on disk
     */
    internal func clearLocalCache(success: (Bool) -> Void) {
        
        let fileManager = FileManager.default
        let imageDirectory = imageDirectoryURL()
        
        if fileManager.isDeletableFile(atPath: imageDirectory.path) {
            do {
                try fileManager.removeItem(atPath: imageDirectory.path)
                success(true)
            } catch {
                debugPrint(error.localizedDescription)
                success(false)
            }
        }
        
        success(true)
    }
    
    /**
     Clears the in memory image cache
     */
    internal func clearInMemoryCache(success: (Bool) -> Void) {
        
        guard let inMemoryImageCache = inMemoryImageCache else {
            success (false)
            return
        }
        
        inMemoryImageCache.removeAllObjects()
        success (true)
    }
    
    /*
     TODO: need to handle the success/failure options better before implementing
     a clear function that handles both caches
     /**
     Clears both the in-memory and disk image cache
     */
     internal func clearCache(success: (Bool) -> Void) {
     clearInMemoryCache { (_) in
     clearLocalCache { (_) in
     success(true)
     }
     }
     }
     */
    
    //MARK:- File Management
    
    internal func fileExtension(for url: URL) -> String? {
        
        let components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        guard let fileExtension = components?.url?.pathComponents.last?.components(separatedBy: ".").last else {
            return nil
        }
        
        return ".\(fileExtension)"
    }
    
    internal func fileExists(at path: String) -> Bool {
        return FileManager.default.fileExists(atPath: path)
    }
    
    /**
     Returns the image folder directory
     */
    internal func imageDirectoryURL() -> URL {
        
        guard let imageFolderName = imageFolderName else {
            fatalError("ERROR: Image Folder Name must be set in order to use local file storage image cache")
        }
        
        //get a ref to the sandbox documents folder
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        //next create a file path to the new documents folder (uses the protcols imagefolderName)
        let imageFolderPath = documentsPath.appendingPathComponent(imageFolderName)
        
        //next we check if the folder needs to be creaded
        let fileManager = FileManager.default
        var directoryExists : ObjCBool = false
        if fileManager.fileExists(atPath: imageFolderPath.path, isDirectory:&directoryExists) {
            if directoryExists.boolValue {
                //if it already exists, return it
                return imageFolderPath
            }
        } else {
            // otherwise if it doesnt exist, we create and return it
            do {
                try FileManager.default.createDirectory(atPath: imageFolderPath.path, withIntermediateDirectories: true, attributes: nil)
            } catch {
                
                debugPrint(error.localizedDescription)
            }
        }
        
        return imageFolderPath
    }
}
