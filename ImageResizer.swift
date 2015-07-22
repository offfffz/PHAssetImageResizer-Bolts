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
    let imageQuality: Float
    
    lazy var imageProcessingQueue: NSOperationQueue = {
        let queue = NSOperationQueue()
        queue.qualityOfService = NSQualityOfService.Background
        queue.maxConcurrentOperationCount = self.maxConcurrentCount
        
        return queue
    }()
    
    init(targetFolderPath: String, sizeToFit: CGSize, imageQuality: Float = 0.8, maxConcurrentCount: Int = 3) {
        self.maxConcurrentCount = maxConcurrentCount
        self.targetFolderPath = targetFolderPath
        self.sizeToFit = sizeToFit
        self.imageQuality = imageQuality
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
                    
                    let imageData = UIImageJPEGRepresentation(image, CGFloat(self.imageQuality))
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