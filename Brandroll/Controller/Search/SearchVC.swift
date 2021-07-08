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

typealias UserAndFollowedTuple = (user: User?, followed: Bool)

class SearchVC: UICollectionViewController, UICollectionViewDelegateFlowLayout,
                UISearchBarDelegate, SearchProfileCellDelegate {
    
    // MARK: - Properties
    
    var user: User?
    var users =  [UserAndFollowedTuple]()
    var filteredUsers = [UserAndFollowedTuple]()
    var searchBar = UISearchBar()
    var inSearchMode = false
    var collectionViewEnabled = true
    
    var userCurrentKey: String?
    var userCurrentKeyForBackwards: String?
    var lastUserKeyOnFirebase: String?
    var firstUserKeyFetched: String?
    
    var search_userCurrentKey: String?
    var search_searchText: String?
    
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.setValue(true, forKey: "hidesShadow")
        self.navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if users.isEmpty || users.count == 0 {
            // fetch profiles
            fetchUsers()
        }
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
            user = filteredUsers[indexPath.row].user
        } else {
            user = users[indexPath.row].user
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
        if inSearchMode {
            if filteredUsers.count >= 4 {
                if indexPath.item == filteredUsers.count - 1 {
                    searchForUsers()
                    return
                }
            }
        } else {
            if users.count >= 3 {
                if indexPath.item == users.count - 1 {
                    fetchUsers()
                    return
                }
            }
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return inSearchMode ? filteredUsers.count : users.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SearchProfileCell", for: indexPath) as! SearchProfileCell
        cell.indexPath = indexPath
        cell.delegate = self
        
        if inSearchMode {
            cell.userAndFollowed = filteredUsers[indexPath.item]
        } else {
            cell.userAndFollowed = users[indexPath.item]
        }
        
        return cell
    }
    
    // MARK: - Handlers
    
    @objc private func popToPrevious() {
        navigationController?.popViewController(animated: true)
    }
    
    func handleFollowTapped(for cell: SearchProfileCell, indexPath: IndexPath?) {
        guard let user = cell.userAndFollowed?.user,
              let indexPath = indexPath  else {
            return
        }
        
        weak var weakSelf = self
        
        func reload() {
            print("INDEXPATH: \(indexPath.item) Follow/Unfollow: 🔥 - Reloading Data... | USER.isFollowed: \(String(describing: user.isFollowed)) | self.user.isfollowed: \((String(describing: self.users[indexPath.item].user?.isFollowed)))")
            UIView.setAnimationsEnabled(false)
            weakSelf?.collectionView.reloadSections(IndexSet.init(integer: 0))
            UIView.setAnimationsEnabled(true)
        }
        
        if user.isFollowed {
            // handle unfollow user
            print("INDEXPATH: \(indexPath.item) Follow/Unfollow: 🔥 - user is followed: unfollowing... | USER.isFollowed: \(String(describing: user.isFollowed)) | self.user.isfollowed: \((String(describing: self.users[indexPath.item].user?.isFollowed)))")
            user.unfollow {
                if weakSelf?.inSearchMode == true {
                    weakSelf?.filteredUsers[indexPath.item].followed = false
                } else {
                    weakSelf?.users[indexPath.item].followed = false
                }
                reload()
            }
        } else {
            // handle follow user
            print("INDEXPATH: \(indexPath.item) Follow/Unfollow: 🔥 - user is NOT followed: following... | USER.isFollowed: \(String(describing: user.isFollowed)) | self.user.isfollowed: \((String(describing: self.users[indexPath.item].user?.isFollowed)))")
            user.follow {
                if weakSelf?.inSearchMode == true {
                    weakSelf?.filteredUsers[indexPath.item].followed = true
                } else {
                    weakSelf?.users[indexPath.item].followed = true
                }
                reload()
            }
        }
    }
    
    func configureSearchBar() {
        searchBar.sizeToFit()
        searchBar.delegate = self
        navigationItem.titleView = searchBar
        searchBar.barTintColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
        searchBar.tintColor = .black
    }
    
    @objc func handleRefresh() {
        users.removeAll(keepingCapacity: false)
        
        userCurrentKey = nil
        userCurrentKeyForBackwards = nil
        lastUserKeyOnFirebase = nil
        firstUserKeyFetched = nil
        fetchUsers()
        
        UIView.setAnimationsEnabled(false)
        collectionView.reloadData()
        UIView.setAnimationsEnabled(true)
    }
    
    private func clearSearchData() {
        filteredUsers.removeAll()
        search_searchText = nil
        search_userCurrentKey = nil
    }
    
    func configureRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        self.collectionView.refreshControl = refreshControl
    }
    
    // MARK: - UISearchBar
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
        searchForUsers()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        clearSearchData()
        
        if searchText.isEmpty || searchText == " " {
            inSearchMode = false
            self.collectionView.refreshControl?.isEnabled = true
        } else {
            self.collectionView.refreshControl?.isEnabled = false
            search_searchText = searchText
            inSearchMode = true
            searchForUsers()
        }
        
        UIView.setAnimationsEnabled(false)
        collectionView.reloadData()
        UIView.setAnimationsEnabled(true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        clearSearchData()
        
        searchBar.endEditing(true)
        searchBar.showsCancelButton = false
        inSearchMode = false
        searchBar.text = nil
        
        collectionViewEnabled = true
        collectionView.isHidden = false
      
        UIView.setAnimationsEnabled(false)
        collectionView.reloadSections(IndexSet.init(integer: 0))
        UIView.setAnimationsEnabled(true)
    }
    
    // MARK: - API
    
    public typealias LastUserKeyCallBack = ((_ lastUserKey: String) -> Void)
    private func getLastUserKey(completion: @escaping LastUserKeyCallBack) {
        USER_REF
            .queryOrderedByKey()
            .queryLimited(toLast: 1)
            .observeSingleEvent(of: .value, with: { (snapshot) in
                let val = snapshot.value as? [String : Any]
                let key = val?.keys.first ?? ""
                completion(key)
            }, withCancel: { (error) in
                print("Error: \(error.localizedDescription)")
            })
    }
    
    private func handleUsersAllObjects(_ allObjects: [DataSnapshot], shouldReload: Bool = false) {
        let group = DispatchGroup()
        
        allObjects.forEach { (snapshot) in
            group.enter()
            
            let uid = snapshot.key
            
            Database.fetchUser(with: uid) { (user, followed) in
                guard let user = user else { return }
                
                group.leave()
                let tuple = (user, followed)
                self.addNewUser(tuple)
            }
        }
        
        group.notify(queue: .main) { [self] in
            UIView.setAnimationsEnabled(false)
            self.collectionView?.reloadSections(IndexSet.init(integer: 0))
            UIView.setAnimationsEnabled(true)
        }
    }
    
    // TODO: Refactor firebase calls.
    private func fetchUsers() {
        func continueFetchingUsers(_ lastUserKey: String) {
            if self.userCurrentKey == nil {
                // Once, first-time fetching.
                USER_REF
                    .queryOrderedByKey()
                    .queryEnding(atValue: SearchUtils.getRandomFirebaseIndex())
                    .queryLimited(toLast: 5)
                    .observeSingleEvent(of: .value) { (snapshot) in
                        
                        self.collectionView.refreshControl?.endRefreshing()
                        
                        guard let first = snapshot.children.allObjects.first as? DataSnapshot,
                              let last = snapshot.children.allObjects.last as? DataSnapshot,
                              let allObjects = snapshot.children.allObjects as? [DataSnapshot] else {
                            
                            if self.users.isEmpty || self.users.count < 4 {
                                self.handleRefresh()
                            }
                            
                            return
                        }
                        
                        self.firstUserKeyFetched = first.key
                        self.printDebugAllObjects(allObjects, from: "First fetch 🍏")
                        
                        self.handleUsersAllObjects(allObjects)
                        
                        self.userCurrentKey = last.key
                    }
            } else if (self.userCurrentKey != self.lastUserKeyOnFirebase) && self.userCurrentKeyForBackwards == nil {
                // If we haven't reached the end yet.
                USER_REF
                    .queryOrderedByKey()
                    .queryStarting(atValue: self.userCurrentKey)
                    .queryLimited(toFirst: 6)
                    .observeSingleEvent(of: .value) { (snapshot) in
                        
                        guard let last = snapshot.children.allObjects.last as? DataSnapshot,
                              var allObjects = snapshot.children.allObjects as? [DataSnapshot] else {
                            return
                        }
                        // Exclude the last one.
                        allObjects.remove(at: 0)
                        
                        self.printDebugAllObjects(allObjects, from: "HAVEN'T REACHED THE END YET 🍎")
                        
                        self.handleUsersAllObjects(allObjects)
                        self.userCurrentKey = last.key
                    }
            } else {
                // And if we've reached the end
                // Then fetch backwards starting from the `firstUserKeyFetched`.
                
                if self.userCurrentKeyForBackwards != nil {
                    // The second-time and future fetch from backwards.
                    USER_REF
                        .queryOrderedByKey()
                        .queryEnding(atValue: self.userCurrentKeyForBackwards)
                        .queryLimited(toLast: 6)
                        .observeSingleEvent(of: .value) { (snapshot) in
                            
                            guard let first = snapshot.children.allObjects.first as? DataSnapshot,
                                  let allObjects = snapshot.children.allObjects as? [DataSnapshot] else {
                                return
                            }
                            
                            self.printDebugAllObjects(allObjects, from: "SECOND-TIME GOING BACKWARDS 🍊")
                            
                            self.handleUsersAllObjects(allObjects)
                            self.userCurrentKeyForBackwards = first.key
                        }
                } else {
                    // The first-time fetch from backwards.
                    USER_REF
                        .queryOrderedByKey()
                        .queryEnding(atValue: self.firstUserKeyFetched)
                        .queryLimited(toLast: 6)
                        .observeSingleEvent(of: .value) { (snapshot) in
                            
                            guard let first = snapshot.children.allObjects.first as? DataSnapshot,
                                  let allObjects = snapshot.children.allObjects as? [DataSnapshot] else {
                                return
                            }
                            
                            self.printDebugAllObjects(allObjects, from: "FIRST-TIME - GOING BACKWARDS 🍐")
                            
                            self.handleUsersAllObjects(allObjects)
                            self.userCurrentKeyForBackwards = first.key
                        }
                }
            }
        }
        
        if lastUserKeyOnFirebase == nil {
            getLastUserKey { (lastUserKey) in
                self.lastUserKeyOnFirebase = lastUserKey
                continueFetchingUsers(lastUserKey)
            }
        } else if let lastUserKey = self.lastUserKeyOnFirebase {
            continueFetchingUsers(lastUserKey)
        } else {
            assert(true)
        }
    }
    
    private func searchForUsers()  {
        guard let text = self.search_searchText else { return }
        
        if search_userCurrentKey == nil {
            // First search
            USER_REF
                .queryOrdered(byChild: "name")
                .queryStarting(atValue: text, childKey: "name")
                .queryEnding(atValue: text+"\u{f8ff}", childKey: "name")
                .queryLimited(toFirst: 4)
                .observeSingleEvent(of: .value) { (snapshot) in
                    
                    guard let last = snapshot.children.allObjects.last as? DataSnapshot else { return }
                    guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else { return }
                    self.printDebugAllObjects(allObjects, from: "SEARCHING")
                    
                    self.handleUsersAllObjects(allObjects)
                    self.search_userCurrentKey = last.key
                }
        } else {
            // Pagination
            // Ref: https://dev.srdanstanic.com/2017/10/14/firebase-realtime-database-lists-sorting-pagination-filtering/
            USER_REF
                .queryOrdered(byChild: "name")
                .queryStarting(atValue: self.search_userCurrentKey, childKey: "name")
                .queryEnding(atValue: text+"\u{f8ff}", childKey: "name")
                .queryLimited(toFirst: 4)
                .observeSingleEvent(of: .value) { (snapshot) in
                    guard let last = snapshot.children.allObjects.last as? DataSnapshot else { return }
                    guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else { return }
                    self.printDebugAllObjects(allObjects, from: "SEARCHING -- SECOND PAGE")
                    
                    self.handleUsersAllObjects(allObjects)
                    self.search_userCurrentKey = last.key
                }
        }
    }
    
    private func addNewUser(_ tuple: UserAndFollowedTuple) {
        guard let user = tuple.user else { return }
        if user.uid != Auth.auth().currentUser?.uid {
            if inSearchMode {
                if !filteredUsers.contains(where: { (u) -> Bool in
                    return u.user?.uid == user.uid
                }) {
                    filteredUsers.append(tuple)
                }
            } else {
                if !users.contains(where: { (u) -> Bool in
                    return u.user?.uid == user.uid
                }) {
                    users.append(tuple)
                }
            }
        }
    }
    
    private func printDebugAllObjects(_ allObjects: Array<DataSnapshot>, from: String) {
        if allObjects.count == 0 { return }
        let tuple: [String] = allObjects.map({
            if let val = $0.value as? [String : Any],
               let testKey = val["testKey"] as? Int {
                return "\(testKey)"
            } else {
                return $0.key
            }
        })
        print("========= FROM: \(from) ==========")
        print(tuple)
    }
}
