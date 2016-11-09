//
//  ViewController.swift
//  OperationAndDependency
//
//  Created by Othonas Antoniou on 09/11/2016.
//  Copyright © 2016 ozzotto Inc. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    fileprivate var imagesOperationQueue = OperationQueue()
    fileprivate var imageURL = "https://dummyimage.com/600x600/7a10b3/ffffff.jpg"
    fileprivate var images = [UIImage](repeating: UIImage(named: "tmp")!, count: 100)
    fileprivate let collectionViewReuseIdentifier = "ImageCollectionCellIdentifier"
    @IBOutlet weak var collectionView: UICollectionView?

    //MARK: UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.lightGray
        
        imagesOperationQueue.name = "com.ozzotto.OperationAndDependency.imagesOperationQueue"
        for i in 0...99 {
            let fetchImageOperation = fetchImageFromNetworkOperation(i)
            let transformImageOperation = applyTransformationToImageOperation(i)
            transformImageOperation.addDependency(fetchImageOperation)
            imagesOperationQueue.addOperations([fetchImageOperation, transformImageOperation], waitUntilFinished: false)
        }
    }

    //MARK: UICollectionViewDataSource, UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemWidth = view.bounds.size.width / 4
        return CGSize(width: itemWidth, height: itemWidth)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: collectionViewReuseIdentifier, for: indexPath) as! ImageCollectionViewCell
        let image = images[indexPath.row]
        cell.imageView!.image = image
        return cell
    }
    
    //MARK: Private
    private func fetchImageFromNetworkOperation(_ index: Int) -> BlockOperation {
        return BlockOperation(block: { 
            let urlSession = URLSession(configuration: .default)
            let semaphore = DispatchSemaphore(value: index)
            let dataTask = urlSession.dataTask(with: URL(string: self.imageURL  + "&text=\(index + 1)")!, completionHandler: { (data, urlResponse, error) in
                guard let image = UIImage(data: data!) else {
                    semaphore.signal()
                    return
                }
                OperationQueue.main.addOperation({ 
                    self.collectionView!.performBatchUpdates({
                        self.images[index] = image
                        self.collectionView!.reloadItems(at: [IndexPath(item: index, section: 0)])
                        semaphore.signal()
                    }, completion: nil)
                })
            })
            dataTask.resume()
            semaphore.wait()
        })
    }
    
    private func applyTransformationToImageOperation(_ index: Int) -> BlockOperation {
        return BlockOperation(block: {
            let image = self.images[index]
            let inputImage = CIImage(image: image)
            let filter = CIFilter(name: "CIPhotoEffectMono")
            filter!.setDefaults()
            filter!.setValue(inputImage, forKey: kCIInputImageKey)
            if let outputImage = filter!.outputImage {
                let transformedImage = UIImage(ciImage: outputImage)
                OperationQueue.main.addOperation({
                    self.collectionView!.performBatchUpdates({
                        self.images[index] = transformedImage
                        self.collectionView!.reloadItems(at: [IndexPath(item: index, section: 0)])
                    }, completion: nil)
                })
            }
        })
    }
}

