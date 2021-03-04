//
//  PreviewUploadVC.swift
//  LogInProgrammatic
//
//  Created by Glenn Posadas on 3/2/21.
//  Copyright © 2021 Eric Park. All rights reserved.
//

import DKImagePickerController
import UIKit

protocol ShowPickerDelegate {
    func showImagePicker()
}

class PreviewViewController: UIViewController {
    
    let tableView = UITableView()
    var images: [UIImage] = []
    var imageAssets: [DKAsset] = []
    let cellID = "PreviewImageCell"

    var delegate: ShowPickerDelegate?
    
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
        tableView.reloadData()
    }
    
    
    // MARK: - Handlers
    
    @objc func handleBackTapped() {
        self.dismiss(animated: true, completion: nil)
        self.delegate?.showImagePicker()
    }
    
    @objc func handleNextTapped() {
        let vc = CreateTitleVC()
        self.definesPresentationContext = true
        self.providesPresentationContextTransitionStyle = true
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .coverVertical
        vc.imageAssets = imageAssets

        self.present(vc, animated: true, completion: nil)
    }
    
    func setNavBarAndTableView() {
        self.navigationItem.title = "Preview"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(handleBackTapped))
        navigationItem.leftBarButtonItem?.tintColor = UIColor.black
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(handleNextTapped))
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

extension PreviewViewController: UITableViewDataSource, UITableViewDelegate {
    
    func registerTable() {
        tableView.register(PreviewTableViewCell.self, forCellReuseIdentifier: cellID)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return images.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! PreviewTableViewCell
        let image = images[indexPath.item]
        cell.cellImageView.image = image
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let currentImage = images[indexPath.row]
        let imageCrop = currentImage.getCropRatio()
        return tableView.frame.width / imageCrop
    }
}

extension UIImage {
    func getCropRatio() -> CGFloat {
        let widthRatio = CGFloat(self.size.width / self.size.height)
        return widthRatio
    }
}

