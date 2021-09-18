//
//  SettingsVC.swift
//  LogInProgrammatic
//
//  Created by Mac on 5/17/21.
//  Copyright © 2021 Eric Park. All rights reserved.
//

import Firebase
import FirebaseAuth
import SnapKit
import UIKit

class SettingsVC: UIViewController {

    // MARK: - Properties

    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(SettingsCell.self, forCellReuseIdentifier: "SettingsCell")
        tableView.tableHeaderView = UIView()
        tableView.tableFooterView = UIView()
        return tableView
    }()
    
    var onPushNotif: (() -> Void)?
    
    // MARK: - Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        configureNavigationBar()
    }
    
    // MARK: - Functions
    
    private func setupViews() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(30)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }

    func configureNavigationBar() {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.backgroundColor = .white
        
        navigationItem.title = "Settings"
        navigationController?.navigationBar.tintColor = .black
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(handleClose))
    }
    
    @objc func handleClose() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func handleLogout() {
        // declare alert controller
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // add alert logout action
        alertController.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { (_) in
            self.proceedLogout()
        }))
        
        // add cancel action
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alertController, animated: true, completion: nil)
    }
    
    private func proceedLogout() {
        do {
            // attempt sign out
            try Auth.auth().signOut()
            print("Successfully logged out user")
            
            guard let tabBarController = presentingViewController as? MainTabVC else { return }
            self.dismiss(animated: true) {
                tabBarController.logout()
            }
        } catch {
            // handle error
            print("Failed to sign out")
            alert(title: "Error \(error.localizedDescription)", okayButtonTitle: "OK", withBlock: nil)
        }
    }
}

// MARK: - UITableViewDelegate

extension SettingsVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let section = indexPath.section
        if section == 0 {
            onPushNotif?()
        } else {
            handleLogout()
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let title = section == 0 ? "Preferences" : "Account"
        
        let header = UIView()
        header.backgroundColor = .white
        
        let label = UILabel()
        label.text = title
        label.font = .boldSystemFont(ofSize: 18)
        label.textColor = .black
        
        header.addSubview(label)
        label.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(16)
        }
        
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

// MARK: - UITableViewDataSource

extension SettingsVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = indexPath.section
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell") as! SettingsCell
        let sectionType = section == 0 ? "Push Notifications" : "Log out"
        cell.label.text = sectionType
        cell.sectionType = sectionType
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
}
