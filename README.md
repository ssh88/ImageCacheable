# ImageCacheable

[![CI Status](http://img.shields.io/travis/ssh88/ImageCacheable.svg?style=flat)](https://travis-ci.org/ssh88/ImageCacheable)
[![Version](https://img.shields.io/cocoapods/v/ImageCacheable.svg?style=flat)](http://cocoapods.org/pods/ImageCacheable)
[![License](https://img.shields.io/cocoapods/l/ImageCacheable.svg?style=flat)](http://cocoapods.org/pods/ImageCacheable)
[![Platform](https://img.shields.io/cocoapods/p/ImageCacheable.svg?style=flat)](http://cocoapods.org/pods/ImageCacheable)

### Usage

First conform to the protocol

```
struct MyObject: ImageCacheable {
```

To use the in-memory cache call:

```
inMemoryImage(forKey: "uniqueImageID", from: imageURL) { (image, key) in

}
```
If the image does not already exist, it will download the image from the specified url, and store it a a Swift Cache, but wont persist across sessions. 


Alternatively you can persist images to disk and across sessions by calling:

```
localImage(forKey: "uniqueImageID", from: imageURL) { (image, key) in

}
```
To clear the cache, call either of the following functions, depending on if your using the in-memory cache or local file storage

```
clearInMemoryCache(success: (Bool) -> Void)
clearLocalCache(success: (Bool) -> Void)
```

## Requirements

- iOS 9.0+
- Swift 3
- Xcode 8

## Installation

ImageCacheable is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "ImageCacheable"
```

## Author

ssh88, shabeershussain@gmail.com

## License

ImageCacheable is available under the MIT license. See the LICENSE file for more info.
