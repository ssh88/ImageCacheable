//
//  ImageCacheableTests.swift
//  ImageCacheable
//
//  Created by Shabeer Hussain on 23/11/2016.
//  Copyright © 2016 Desert Monkey. All rights reserved.
//

import XCTest

@testable import ImageCacheable

struct Mock_LocalImageCache: ImageCacheable {
    
    var imageFolderName: String? = "imageFolder"
}

struct Mock_InMemoryImageCache: ImageCacheable {
    
    var inMemoryImageCache: NSCache<AnyObject, UIImage>? = NSCache<AnyObject, UIImage>()
}

class ImageCacheableTests: XCTestCase {
    
    /**
     Tests that the image directory is correctly created
     */
    func test_ImageDirectory() {
        
        let sut = Mock_LocalImageCache()
        let result = sut.imageDirectoryURL().path
        
        //create the expectation
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let expectation =  "\(documentsPath.path)/\(sut.imageFolderName!)"
        
        XCTAssertEqual(result, expectation, "Image directory not created")
        
        //finally clear the cache
        sut.clearLocalCache(){_ in }
    }
    
    /**
     Test the file extension from a remote image can be stripepd out
     */
    func test_fileExtensionForURL() {
        
        let url = URL(string: "http://www.shabeer.io/hero.png")
        
        let sut = Mock_LocalImageCache()
        let result = sut.fileExtension(for: url!)
        let expectation = ".png"
        
        XCTAssertEqual(result, expectation, "Incorrect file extension for image")
        
        //finally clear the cache
        sut.clearLocalCache(){_ in }
    }
    
    /**
     Tests images can be downloaded and stored on disk
     */
    func test_localImageForKeyFromURL() {
        
        let sut = Mock_LocalImageCache()
        
        //create the expectation file path
        let imageURL = URL(string: "http://www.planwallpaper.com/static/images/Seamless-Polygon-Backgrounds-Vol2-full_Kfb2t3Q.jpg")
        let imageKey = "uniqueKey"
        let fileExtension = sut.fileExtension(for: imageURL!)!
        let fileName = "\(imageKey)\(fileExtension)"
        
        //expect to be saved here
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let filePath = "\(documentsPath.path)/\(sut.imageFolderName!)/\(fileName)"
        let expectedFilePath = URL(string: filePath)!
        
        let expectation = self.expectation(description: "Image Download Failed")
        
        sut.localImage(forKey: imageKey, from: imageURL!) { (image, key) in
            XCTAssertNotNil(image, "Image incorrectly downloaded")
            
            let result = sut.fileExtension(for: expectedFilePath)
            XCTAssertTrue((result != nil), "Image not downloaded")
            
            expectation.fulfill()
            
            //finally clear the cache
            sut.clearLocalCache(){_ in }
        }
        waitForExpectations(timeout: 15)
    }
    
    /**
     Tests in-memory image cache
     */
    func test_InMemoryImageForKeyFromURL() {
        
        let sut = Mock_InMemoryImageCache()
        
        //create the expectation file path
        let imageURL = URL(string: "http://cache.net-a-porter.com/images/products/714463/714463_fr_sl.jpg")
        let imageKey = "uniqueKey"
        
        //first test the image is non existent
        let result1 = sut.inMemoryImageCache?.object(forKey: imageKey as AnyObject)
        XCTAssertNil(result1, "Image should not be cached yet")
        
        //next, we download it and see if it gets cached correctly
        let expectation = self.expectation(description: "Image Download Failed")

        sut.inMemoryImage(forKey: imageKey, from: imageURL!) { (image, key) in
            
            //check the image is returned
            XCTAssertNotNil(image, "Image should be downloaded")
        
            //next check the image exists in the cache now
            let result = sut.inMemoryImageCache?.object(forKey: imageKey as AnyObject)
            XCTAssertEqual(result , image)
            
            expectation.fulfill()
            
            //finally clear the cache for the nex test
            sut.clearInMemoryCache(){_ in }
        }
        waitForExpectations(timeout: 15)
    }
}
