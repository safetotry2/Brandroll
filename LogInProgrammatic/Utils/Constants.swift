//
//  Constants.swift
//  LogInProgrammatic
//
//  Created by Mac on 9/18/20.
//  Copyright © 2020 Eric Park. All rights reserved.
//

import Firebase
import FirebaseDatabase

// MARK: - Root References

let DB_REF = Database.database().reference()
let STORAGE_REF = Storage.storage().reference()

// MARK: - Database References

let USER_REF = DB_REF.child("users")
let USER_FOLLOWER_REF = DB_REF.child("user-followers")
let USER_FOLLOWING_REF = DB_REF.child("user-following")
