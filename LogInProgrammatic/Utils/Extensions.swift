//
//  Extensions.swift
//  LogInProgrammatic
//
//  Created by Mac on 9/8/20.
//  Copyright © 2020 Eric Park. All rights reserved.
//

import UIKit
import FirebaseDatabase

extension UIColor {
    static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: 1)
    }
    
    static func colorWithRGBHex(_ hex: Int, alpha: Float = 1.0) -> UIColor {
        let r = Float((hex >> 16) & 0xFF)
        let g = Float((hex >> 8) & 0xFF)
        let b = Float((hex) & 0xFF)
        
        return UIColor(red: CGFloat(r / 255.0), green: CGFloat(g / 255.0), blue:CGFloat(b / 255.0), alpha: CGFloat(alpha))
    }
}

extension UIButton {
    
    func configure(didFollow: Bool) {
        
        if didFollow {
            
            // handle follow user
            self.setTitle("Following", for: .normal)
            self.setTitleColor(.black, for: .normal)
            self.layer.borderWidth = 0.5
            self.layer.borderColor = UIColor.lightGray.cgColor
            self.backgroundColor = .white
        } else {
            
            // handle unfollow user
            self.setTitle("Follow", for: .normal)
            self.setTitleColor(.white, for: .normal)
            self.layer.borderWidth = 0
            self.backgroundColor = UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)
        }
    }
}

extension Date {
    
    func timeAgoToDisplay() -> String {
        
        let secondsAgo = Int(Date().timeIntervalSince(self))
        
        let zero = 0
        let minute = 60
        let hour = 60 * minute
        let day = 24 * hour
        let week = 7 * day
        let year = 52 * week
        
        let quotient: Int
        let unit: String
        
        if secondsAgo == zero {
            quotient = 1
            unit = "s"
        } else if secondsAgo > zero && secondsAgo < minute {
            quotient = secondsAgo
            unit = "s"
        } else if secondsAgo < hour {
            quotient = secondsAgo / minute
            unit = "m"
        } else if secondsAgo < day {
            quotient = secondsAgo / hour
            unit = "h"
        } else if secondsAgo < week {
            quotient = secondsAgo / day
            unit = "d"
        } else if secondsAgo < year {
            quotient = secondsAgo / week
            unit = "w"
        } else {
            quotient = secondsAgo / year
            unit = "y"
        }
        
        return "• \(quotient)\(unit)"
    }
}

extension Date {
    
    func timeStampForComment() -> String {
        
        let secondsAgo = Int(Date().timeIntervalSince(self))
        
        let zero = 0
        let minute = 60
        let hour = 60 * minute
        let day = 24 * hour
        let week = 7 * day
        let year = 52 * week
        
        let quotient: Int
        let unit: String
        
        if secondsAgo == zero {
            quotient = 1
            unit = "s"
        } else if secondsAgo > zero && secondsAgo < minute {
            quotient = secondsAgo
            unit = "s"
        } else if secondsAgo < hour {
            quotient = secondsAgo / minute
            unit = "m"
        } else if secondsAgo < day {
            quotient = secondsAgo / hour
            unit = "h"
        } else if secondsAgo < week {
            quotient = secondsAgo / day
            unit = "d"
        } else if secondsAgo < year {
            quotient = secondsAgo / week
            unit = "w"
        } else {
            quotient = secondsAgo / year
            unit = "y"
        }
        
        return "\(quotient)\(unit)"
    }
}

extension Date {
    
    func timeOrDateToDisplay(from seconds: Date) -> String {
        
//        let numberOfSeconds = Int(Date().timeIntervalSince(seconds))
//        let day = 86400
                
        let calendar = Calendar.current
        let dateFormatter = DateFormatter()
        
        if calendar.isDateInToday(seconds) {
            dateFormatter.dateFormat = "hh:mm a"
            return dateFormatter.string(from: seconds)
        } else if calendar.isDateInYesterday(seconds) {
            return "Yesterday"
        } else if calendar.isDate(seconds, inSameDayAs: TWO_DAYS_AGO!) {
            dateFormatter.dateFormat = "EEEE"
            return dateFormatter.string(from: seconds)
        } else if calendar.isDate(seconds, inSameDayAs: THREE_DAYS_AGO!) {
            dateFormatter.dateFormat = "EEEE"
            return dateFormatter.string(from: seconds)
        } else if calendar.isDate(seconds, inSameDayAs: FOUR_DAYS_AGO!) {
            dateFormatter.dateFormat = "EEEE"
            return dateFormatter.string(from: seconds)
        } else if calendar.isDate(seconds, inSameDayAs: FIVE_DAYS_AGO!) {
            dateFormatter.dateFormat = "EEEE"
            return dateFormatter.string(from: seconds)
        } else if calendar.isDate(seconds, inSameDayAs: SIX_DAYS_AGO!) {
            dateFormatter.dateFormat = "EEEE"
            return dateFormatter.string(from: seconds)
        } else {
            dateFormatter.dateFormat = "MM/dd/YY"
            return dateFormatter.string(from: seconds)
        }
        
//        if calendar.isDateInToday(seconds) {
//            dateFormatter.dateFormat = "hh:mm a"
//            return dateFormatter.string(from: seconds)
//        } else if calendar.isDateInYesterday(seconds) {
//            return "Yesterday"
//        } else {
//            dateFormatter.dateFormat = "MM/dd/YY"
//            return dateFormatter.string(from: seconds)
//        }
        
        
//        if calendar.isDateInToday(seconds) {
//            dateFormatter.dateFormat = "EEEE"
//            return dateFormatter.string(from: seconds)
//        } else if calendar.isDateInYesterday(seconds) {
//            return "Yesterday"
//        } else {
//            dateFormatter.dateFormat = "MM/dd/YY"
//            return dateFormatter.string(from: seconds)
//        }
        
//        if numberOfSeconds < day {
//            dateFormatter.dateFormat = "hh:mm a"
//        } else {
//            dateFormatter.dateFormat = "MM/dd/YY"
//        }
//
//        return dateFormatter.string(from: seconds)
    }
}


extension UIView {
    
    func anchor(top: NSLayoutYAxisAnchor?, left: NSLayoutXAxisAnchor?, bottom: NSLayoutYAxisAnchor?, right: NSLayoutXAxisAnchor?, paddingTop: CGFloat, paddingLeft: CGFloat, paddingBottom: CGFloat, paddingRight: CGFloat, width: CGFloat, height: CGFloat) {
        
        translatesAutoresizingMaskIntoConstraints = false
        
        if let top = top {
            self.topAnchor.constraint(equalTo: top, constant: paddingTop).isActive = true
        }
        
        if let left = left {
            self.leftAnchor.constraint(equalTo: left, constant: paddingLeft).isActive = true
        }
        
        if let bottom = bottom {
            self.bottomAnchor.constraint(equalTo: bottom, constant: -paddingBottom).isActive = true
        }
        
        if let right = right {
            self.rightAnchor.constraint(equalTo: right, constant: -paddingRight).isActive = true
        }
        
        if width != 0 {
            widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        
        if height != 0 {
            heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }
}

extension Database {
    static func fetchUser(with uid: String, completion: @escaping(User?) -> ()) {
        USER_REF.child(uid).observeSingleEvent(of: .value) { (snapshot) in
            
            guard let dictionary = snapshot.value as? Dictionary<String, AnyObject> else {
                completion(nil)
                return
            }
            
            let user = User(uid: uid, dictionary: dictionary)
            
            completion(user)
        }
    }
    
    static func fetchUser(with uid: String, completion: @escaping(_ user: User?, _ isFollowing: Bool) -> ()) {
        USER_REF.child(uid).observeSingleEvent(of: .value) { (snapshot) in
            guard let dictionary = snapshot.value as? Dictionary<String, AnyObject> else {
                completion(nil, false)
                return
            }
            
            let user = User(uid: uid, dictionary: dictionary)
            user.checkIfUserIsFollowed { (followed) in
                completion(user, followed)
            }
        }
    }
    
    static func fetchPost(with postId: String, completion: @escaping(Post) -> ()) {
        
        POSTS_REF.child(postId).observeSingleEvent(of: .value) { (snapshot) in
            
            guard let dictionary = snapshot.value as? Dictionary<String, AnyObject> else { return }
            guard let ownerUid = dictionary["ownerUid"] as? String else { return }
            
            Database.fetchUser(with: ownerUid) { (user) in
                
                let post = Post(postId: postId, user: user, dictionary: dictionary)
                
                completion(post)
            }
        }
    }
}

// Animating the TabBar Dismiss
extension UITabBarController {
    func setTabBar( hidden: Bool, animated: Bool = true, along transitionCoordinator: UIViewControllerTransitionCoordinator? = nil) {
        guard isTabBarHidden != hidden else { return }

        let offsetY = hidden ? tabBar.frame.height : -tabBar.frame.height
        let endFrame = tabBar.frame.offsetBy(dx: 0, dy: offsetY)
        let vc: UIViewController? = viewControllers?[selectedIndex]
        var newInsets: UIEdgeInsets? = vc?.additionalSafeAreaInsets
        let originalInsets = newInsets
        newInsets?.bottom -= offsetY

        func set(childViewController cvc: UIViewController?, additionalSafeArea: UIEdgeInsets) {
            cvc?.additionalSafeAreaInsets = additionalSafeArea
            cvc?.view.setNeedsLayout()
        }

        // Update safe area insets for the current view controller before the animation takes place when hiding the bar.
        if hidden, let insets = newInsets { set(childViewController: vc, additionalSafeArea: insets) }

        guard animated else {
            tabBar.frame = endFrame
            return
        }

        // Perform animation with coordinato if one is given. Update safe area insets _after_ the animation is complete,
        // if we're showing the tab bar.
        weak var tabBarRef = self.tabBar
        if let tc = transitionCoordinator {
            tc.animateAlongsideTransition(in: self.view, animation: { _ in tabBarRef?.frame = endFrame }) { context in
                if !hidden, let insets = context.isCancelled ? originalInsets : newInsets {
                    set(childViewController: vc, additionalSafeArea: insets)
                }
            }
        } else {
            UIView.animate(withDuration: 0.3, animations: { tabBarRef?.frame = endFrame }) { didFinish in
                if !hidden, didFinish, let insets = newInsets {
                    set(childViewController: vc, additionalSafeArea: insets)
                }
            }
        }
    }

    /// `true` if the tab bar is currently hidden.
    var isTabBarHidden: Bool {
        return !tabBar.frame.intersects(view.frame)
    }
}

extension UIViewController {
    func setupClearNavBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.tintColor = .black
        navigationController?.navigationBar.barTintColor = .black
        //navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.barStyle = .black
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
    }
    
    func setupStatusBarColor() {
        
        if #available(iOS 13.0, *) {
         let app = UIApplication.shared
         let statusBarHeight: CGFloat = app.statusBarFrame.size.height
         
        //let height = view.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
        
        //let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        //let statusBarHeight = window?.windowScene?.statusBarManager?.statusBarFrame.size.height ?? 0
            
//            let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
//            let statusBarFrame = window?.windowScene?.statusBarManager?.statusBarFrame
//
//            let statusBarView = UIView(frame: statusBarFrame!)
//            self.view.addSubview(statusBarView)
//            statusBarView.backgroundColor = .white
            
            
         let statusbarView = UIView()
         statusbarView.backgroundColor = UIColor.white
         view.addSubview(statusbarView)

         statusbarView.translatesAutoresizingMaskIntoConstraints = false
         statusbarView.heightAnchor
         .constraint(equalToConstant: statusBarHeight).isActive = true
         statusbarView.widthAnchor
         .constraint(equalTo: view.widthAnchor, multiplier: 1.0).isActive = true
         statusbarView.topAnchor
         .constraint(equalTo: view.topAnchor).isActive = true
         statusbarView.centerXAnchor
         .constraint(equalTo: view.centerXAnchor).isActive = true
         
        } else {
            let statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView
            statusBar?.backgroundColor = UIColor.white
        }
    }
}
