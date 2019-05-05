//
//  ViewController.swift
//  ThreadsOnPractica
//
//  Created by Kate on 27/04/2019.
//  Copyright © 2019 Kate. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
    
    lazy private var images: [UIImage?] = Array(repeating: nil, count: requests.count)
    private let defaultSession = URLSession(configuration: .default)
    private var dataTasks: [Int:URLSessionDownloadTask] = [:]
    @IBOutlet private var myRefreshControl: UIRefreshControl!
    lazy private var requests: [URLRequest] = {
        self.urlStrings.compactMap { URL(string: $0) }.compactMap { URLRequest(url: $0) }
    }()
    private let urlStrings = [
        "https://images.pexels.com/photos/207962/pexels-photo-207962.jpeg?cs=srgb&dl=artistic-blossom-bright-207962.jpg&fm=jpg",
        "https://images.unsplash.com/photo-1516589178581-6cd7833ae3b2?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&w=1000&q=80",
        "https://st4.depositphotos.com/9897138/20228/i/1600/depositphotos_202280128-stock-photo-silhouette-woman-hands-heart-shape.jpg",
        "https://jecoaching.com/wp-content/uploads/2015/02/ripple1.jpg",
        "https://thumbs.dreamstime.com/z/saving-drowning-man-hand-sea-33364386.jpg",
        "https://www.abc.net.au/news/image/9670912-3x2-700x467.jpg",
        "https://www.nyip.edu/media/zoo/images/how-to-instantly-improve-sunset-photos_2dbd0d9a0883b1e479745909e817b263.jpg",
        "https://tocka.com.mk/images/gallery/gallery-images/big/974/gal41717697.jpg",
        "https://3hh5bj8xbp7b7mq3hzh46bcs-wpengine.netdna-ssl.com/wp-content/uploads/2016/10/GoPro-Hero5-Black-Burst-Photo-750x536.jpg",
        "https://pixel.nymag.com/imgs/daily/vulture/2017/05/22/got-bts/got-06.w710.h473.jpg",
        "https://images.unsplash.com/photo-1509070016581-915335454d19?ixlib=rb-1.2.1&w=1000&q=80",
        "https://cdn.pixabay.com/photo/2015/11/02/14/26/maple-1018458_960_720.jpg",
        "https://d357bpt78riloh.cloudfront.net/my-picture2-co-uk/assets/img/products/photo-canvas-folded-0efc21fb5e.jpg",
        "https://www.incimages.com/uploaded_files/image/970x450/getty_670570584_200013751503697107170_367713.jpg",
        "https://images7.alphacoders.com/671/671281.jpg",
        "https://images7.alphacoders.com/305/305749.jpg",
        "https://images8.alphacoders.com/100/1003220.png",
        "https://images4.alphacoders.com/975/975294.jpg",
        "https://images5.alphacoders.com/481/481903.png",
        "https://images7.alphacoders.com/611/611138.png",
        "https://images6.alphacoders.com/515/515434.jpg",
        "https://images5.alphacoders.com/325/325117.jpg",
        "https://images5.alphacoders.com/564/564821.jpg",
        "https://images5.alphacoders.com/837/837093.jpg",
        "https://images7.alphacoders.com/867/867279.jpg",
        "https://images8.alphacoders.com/867/867237.jpg",
        "https://images2.alphacoders.com/159/159692.jpg",
        "https://images8.alphacoders.com/745/745710.jpg",
        "https://images6.alphacoders.com/704/704120.png",
        "https://images2.alphacoders.com/703/703553.jpg",
        "https://images6.alphacoders.com/613/613924.jpg",
        "https://images8.alphacoders.com/463/463477.jpg", "https://images.unsplash.com/photo-1483691278019-cb7253bee49f?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=1000&q=80",
        "https://images.livemint.com/rf/Image-621x414/LiveMint/Period2/2018/11/24/Photos/Home%20Page/wedding-kWdE--621x414@LiveMint-8925.jpg",
        "https://pub-static.haozhaopian.net/static/web/site/features/one-tap-enhance/images/1-tap-enhance_comparison_chart0cd39fa2358c48f674db97b65327666e.jpg",
        "https://cdn.vox-cdn.com/thumbor/oe7HgITxeapRVlTqL-WtdXI8ARg=/0x0:2000x1250/1200x800/filters:focal(840x177:1160x497)/cdn.vox-cdn.com/uploads/chorus_image/image/58822079/dunkirkcover.0.jpeg",
        "https://natgeo.imgix.net/factsheets/thumbnails/yourshot-underwater-1869254.adapt.1900.1.jpg?auto=compress,format&w=1024&h=560&fit=crop"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myRefreshControl = UIRefreshControl()
        myRefreshControl.addTarget(self, action: #selector(onPullToRefresh(_:)), for: .valueChanged)
        tableView.refreshControl = myRefreshControl
        
    }
    
    @IBAction func onPullToRefresh(_ sender: UIRefreshControl){
        dataTasks = [:]
        tableView.reloadData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1){[weak self] in self?.refreshControl?.endRefreshing()}
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return requests.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableCell", for: indexPath)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? TableCell else {
            fatalError("AAAAAAA")
        }
        let previosCellIndex = cell.getCurrentIndex()
        cell.configureCell(newCellNumber: indexPath.row, cellImage: images[indexPath.row])
        guard images[indexPath.row] == nil else {
            return
        }
        
        let dataTaskCompletionHandler: (URL?, URLResponse?, Error?) -> Void = { fileURL, response, error in
            guard let fileURL = fileURL,
                let response = response as? HTTPURLResponse,
                response.statusCode == 200 else {
                    print("DataTask error: " + (error?.localizedDescription ?? "Unknown") + "\n")
                    return
            }
            DispatchQueue.main.async { [weak self] in
                self?.images[indexPath.row] = self?.loadImage(by: fileURL)
                if cell.getCurrentIndex() == indexPath.row {
                    cell.setImage(self?.images[indexPath.row])
                }
            }
        }
        
        cancelDataTask(dataTaskNumber: previosCellIndex, dataTaskCompletionHandler: dataTaskCompletionHandler)
        executeDataTask(dataTaskNumber: indexPath.row, dataTaskCompletionHandler: dataTaskCompletionHandler)
    }
    
    private func loadImage(by url: URL) -> UIImage? {
        do {
            let data = try Data(contentsOf: url)
            let image = UIImage(data: data)
            return image
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    private func cancelDataTask(dataTaskNumber: Int, dataTaskCompletionHandler: @escaping (URL?, URLResponse?, Error?) -> Void) {
        dataTasks[dataTaskNumber]?.cancel { [weak self] (resumeData) in
            if let resumeData = resumeData {
                self?.dataTasks[dataTaskNumber] = self?.defaultSession.downloadTask(withResumeData: resumeData, completionHandler: dataTaskCompletionHandler)
            }
        }
    }
    
    private func executeDataTask(dataTaskNumber: Int, dataTaskCompletionHandler: @escaping (URL?, URLResponse?, Error?) -> Void) {
        if dataTasks[dataTaskNumber] == nil {
            dataTasks[dataTaskNumber] = defaultSession.downloadTask(with: requests[dataTaskNumber], completionHandler: dataTaskCompletionHandler)
        }
        dataTasks[dataTaskNumber]?.resume()
    }
}

class TableCell: UITableViewCell {
    
    @IBOutlet private var photoView: UIImageView!
    @IBOutlet weak var cellActivityIndicator: UIActivityIndicatorView!
    private var currentCellNumber: Int = -1
    
    func setNewCellNumber(newValue: Int) {
        currentCellNumber = newValue
    }
    
    func getCurrentIndex() -> Int {
        return currentCellNumber
    }
    
    func configureCell(newCellNumber: Int, cellImage: UIImage?) {
        setNewCellNumber(newValue: newCellNumber)
        setImage(cellImage)
    }
    
    func setImage(_ image: UIImage?) {
        if let image = image {
            photoView.image = image
            self.cellActivityIndicator.stopAnimating()
        } else {
            photoView.image = #imageLiteral(resourceName: "default")
            self.cellActivityIndicator.startAnimating()
        }
    }
}
