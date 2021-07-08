//
//  SearchUtils.swift
//  LogInProgrammatic
//
//  Created by Glenn Posadas on 3/21/21.
//  Copyright © 2021 Eric Park. All rights reserved.
//

import Foundation

class SearchUtils {
    static func getRandomFirebaseIndex() -> String {
        let randomIndexArray = ["a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z","0","1","2","3","4","5","6","7","8","9"]
        let randomIndex = Int.random(in: 0..<randomIndexArray.endIndex)

        //In lexicographical order 'A' != 'a' so we use some clever logic to randomize the case of any letter that is chosen.
        //If a numeric character is chosen, .capitalized will fail silently.
        return (randomIndex % 2 == 0) ? randomIndexArray[randomIndex] : randomIndexArray[randomIndex].capitalized
    }
}
