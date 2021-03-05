//
//  PreviewUploadVC.swift
//  LogInProgrammatic
//
//  Created by Glenn Posadas on 3/2/21.
//  Copyright © 2021 Eric Park. All rights reserved.
//

import DKImagePickerController
import Kingfisher
import UIKit

protocol ShowPickerDelegate {
    func showImagePicker()
}

class PreviewUploadVC: UIViewController {
    
    let tableView = UITableView()
    var images: [UIImage] = []
    var postImages: Array<Post.PostImage>?
    let cellID = "PreviewImageCell"

    var delegate: ShowPickerDelegate?
    var cellDynamicHeights: [Int : CGFloat] = [:]
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view = UIView()
        view.backgroundColor = UIColor.white
        setNavBarAndTableView()
        registerTable()
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        tableView.reloadData()
    }
    
    
    // MARK: - Handlers
    
    @objc func handleBackTapped() {
        self.dismiss(animated: true, completion: nil)
        
        if postImages == nil {
            // Only do this when showing previews.
            self.delegate?.showImagePicker()
        }
    }
    
    @objc func handleNextTapped() {
        let vc = CreateTitleVC()
        self.definesPresentationContext = true
        self.providesPresentationContextTransitionStyle = true
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .coverVertical
        vc.images = images

        self.present(vc, animated: true, completion: nil)
    }
    
    func setNavBarAndTableView() {
        if postImages != nil {
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(handleBackTapped))
            navigationItem.rightBarButtonItem = nil
            self.navigationItem.title = "Photos"
        } else {
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(handleBackTapped))
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(handleNextTapped))
            self.navigationItem.title = "Preview"
        }

        navigationItem.leftBarButtonItem?.tintColor = UIColor.black
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        self.view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        
        tableView.contentInset = UIEdgeInsets(top: 14, left: 0, bottom: 0, right: 0)
    }
    
}

//MARK: - TableView DataSource and Delegate

extension PreviewUploadVC: UITableViewDataSource, UITableViewDelegate {
    
    func registerTable() {
        tableView.register(PreviewTableViewCell.self, forCellReuseIdentifier: cellID)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postImages == nil ? images.count : postImages?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! PreviewTableViewCell
        
        if postImages != nil {
            let postImage = postImages![indexPath.row]
            
            if let url = URL(string: postImage.imageUrl) {
                let resource = ImageResource(downloadURL: url)
                cell.cellImageView.kf.indicatorType = .activity
                cell.cellImageView.kf.setImage(with: resource)
            }
        } else {
            let image = images[indexPath.item]
            cell.cellImageView.image = image
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if postImages != nil {
            let postImage = postImages![indexPath.row]
            let widthRatio = CGFloat(postImage.width / postImage.height)
            let height = tableView.frame.width / widthRatio
            return height
        } else {
            let currentImage = images[indexPath.row]
            let imageCrop = currentImage.getCropRatio()
            return tableView.frame.width / imageCrop
        }
    }
}

extension UIImage {
    func getCropRatio() -> CGFloat {
        let widthRatio = CGFloat(self.size.width / self.size.height)
        return widthRatio
    }
}

