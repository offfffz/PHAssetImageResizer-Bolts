//
//  ImageResizer.swift
//
//  Created by offz on 7/21/2558 BE.
//  Copyright (c) 2558 off. All rights reserved.
//

import Bolts
import Photos
import FCFileManager

public class ImageResizer {
    
    let maxConcurrentCount: Int
    let targetFolderPath: String
    let sizeToFit: CGSize
    
    lazy var imageProcessingQueue: NSOperationQueue = {
        let queue = NSOperationQueue()
        queue.qualityOfService = NSQualityOfService.Background
        queue.maxConcurrentOperationCount = self.maxConcurrentCount
        
        return queue
    }()
    
    public init(targetFolderPath: String, sizeToFit: CGSize, maxConcurrentCount: Int = 3) {
        self.maxConcurrentCount = maxConcurrentCount
        self.targetFolderPath = targetFolderPath
        self.sizeToFit = sizeToFit
    }
    
    public func resizeAndCacheAssets(#assets: [PHAsset]) -> BFTask {
        let imgManager = PHImageManager.defaultManager()
        var tasks = [BFTask]()
        var counter = 0
        
        let imageRequestOptions = PHImageRequestOptions()
        imageRequestOptions.resizeMode = .Exact
        imageRequestOptions.synchronous = true
        
        for asset in assets {
            let fileName = "\(counter++).jpg"
            let filePath = targetFolderPath.stringByAppendingPathComponent(fileName)
            let completionSource = BFTaskCompletionSource()
            
            imageProcessingQueue.addOperation(NSBlockOperation(block: {
                imgManager.requestImageForAsset(asset, targetSize: sizeToFit, contentMode: PHImageContentMode.AspectFit, options: imageRequestOptions, resultHandler: {
                    [unowned self](image, _) -> Void in
                    
                    let imageData = UIImageJPEGRepresentation(image, 0.8)
                    if imageData != nil && FCFileManager.writeFileAtPath(filePath, content: imageData) {
                        completionSource.setResult(filePath)
                    } else {
                        completionSource.setError(NSError(domain: "ImageResizer", code: 101,
                            userInfo:[NSLocalizedDescriptionKey: "Cannot write image to \(filePath)"]))
                    }
                })
            }))
            
            tasks.append(completionSource.task)
        }
        
        return BFTask(forCompletionOfAllTasksWithResults: tasks)
    }
}