//
//  SearchVC.swift
//  LogInProgrammatic
//
//  Created by Mac on 9/14/20.
//  Copyright © 2020 Eric Park. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class SearchVC: UICollectionViewController, UICollectionViewDelegateFlowLayout,
                UISearchBarDelegate, SearchProfileCellDelegate {
    
    // MARK: - Properties
    
    var user: User?
    var users = [User]()
    var filteredUsers = [User]()
    var searchBar = UISearchBar()
    var inSearchMode = false
    var collectionViewEnabled = true
    var posts = [Post]()
    var currentKey: String?
    var userCurrentKey: String?
    
    private let reuseIdentifier = "SearchUserCell"
    
    // MARK: - Init
    
    deinit {
        print("SearchVC deallocated! ✅")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // configure search bar
        configureSearchBar()
        
        // configure collection view
        configureCollectionView()
        
        // configure refresh control
        configureRefreshControl()
        
        // fetch profiles
        fetchUsers()
        
    }
    
    // MARK: - UICollectionView
    
    func configureCollectionView() {
        collectionView?.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 24, right: 0)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.alwaysBounceVertical = true
        collectionView.backgroundColor = .white
        collectionView.showsVerticalScrollIndicator = false
        
        collectionView.register(SearchProfileCell.self, forCellWithReuseIdentifier: "SearchProfileCell")
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.frame.width - 2) / 2
        return CGSize(width: width, height: width)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var user: User!
        
        if inSearchMode {
            user = filteredUsers[indexPath.row]
        } else {
            user = users[indexPath.row]
        }
        
        // create instance of user profile vc
        let userProfileVC = UserProfileVC(collectionViewLayout: UICollectionViewFlowLayout())
        
        // passes user from searchVC to userProfileVC
        userProfileVC.user = user
        userProfileVC.fromTabBar = false
        
        // push view controller
        navigationController?.pushViewController(userProfileVC, animated: true)
        navigationItem.backBarButtonItem = UIBarButtonItem(
            title: "",
            style: .plain,
            target: self,
            action: #selector(popToPrevious)
        )
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        if users.count > 8 {
            if indexPath.item == users.count - 1 {
                fetchUsers()
            }
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return users.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SearchProfileCell", for: indexPath) as! SearchProfileCell
        cell.delegate = self
        cell.user = users[indexPath.item]
        
        return cell
    }
    
    // MARK: - Handlers
    
    @objc private func popToPrevious() {
        navigationController?.popViewController(animated: true)
    }
    
    func handleFollowTapped(for cell: SearchProfileCell) {
        guard let user = cell.user else { return }
        
        if user.isFollowed {
            // handle unfollow user
            user.unfollow()
        } else {
            // handle follow user
            user.follow()
        }
        cell.configureFollowButton()
    }
    
    func configureSearchBar() {
        searchBar.sizeToFit()
        searchBar.delegate = self
        navigationItem.titleView = searchBar
        searchBar.barTintColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
        searchBar.tintColor = .black
    }
    
    @objc func handleRefresh() {
        posts.removeAll(keepingCapacity: false)
        self.currentKey = nil
        fetchUsers()
        collectionView.reloadData()
    }
    
    func configureRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        self.collectionView.refreshControl = refreshControl
    }
    
    // MARK: - UISearchBar
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
        
        collectionView.isHidden = true
        collectionViewEnabled = false
        
        fetchUsers()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty || searchText == " " {
            inSearchMode = false
            collectionView.reloadData()
        } else {
            inSearchMode = true
            
            filteredUsers = users.filter({ (user) -> Bool in
                
                return (user.name?.contains(searchText) ?? true) || (user.occupation?.contains(searchText) ?? true)
                
            })
            collectionView.reloadData()
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        searchBar.showsCancelButton = false
        inSearchMode = false
        searchBar.text = nil
        
        collectionViewEnabled = true
        collectionView.isHidden = false
        collectionView.reloadData()
    }
    
    // MARK: - API
    
    func fetchUsers() {
        if userCurrentKey == nil {
            USER_REF.queryLimited(toLast: 12).observeSingleEvent(of: .value) { (snapshot) in
                
                guard let first = snapshot.children.allObjects.first as? DataSnapshot else { return }
                guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else { return }
                
                allObjects.forEach { (snapshot) in
                    let uid = snapshot.key
                    
                    Database.fetchUser(with: uid) { (user) in
                        guard let user = user else { return }
                        if user.uid != Auth.auth().currentUser?.uid {
                            self.users.append(user)
                        }
                        
                        self.collectionView.reloadData()
                    }
                }
                
                self.userCurrentKey = first.key
            }
        } else {
            USER_REF.queryOrderedByKey().queryEnding(atValue: userCurrentKey).queryLimited(toLast: 13).observeSingleEvent(of: .value) { (snapshot) in
                
                guard let first = snapshot.children.allObjects.first as? DataSnapshot else { return }
                guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else { return }
                
                allObjects.forEach { (snapshot) in
                    let uid = snapshot.key
                    
                    if uid != self.userCurrentKey {
                        Database.fetchUser(with: uid) { (user) in
                            guard let user = user else { return }
                            if user.uid != Auth.auth().currentUser?.uid {
                                self.users.append(user)
                            }
                            
                            self.collectionView.reloadData()
                        }
                    }
                }
                self.userCurrentKey = first.key
            }
        }
    }
}
