/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    Utilities to help with random numbers and string normalization.
*/

import Foundation

/// Simple random true/false generator
public func flipACoin() -> Bool {
    return arc4random_uniform(2) == 0
}

/// Convenience wrapper around DispatchQueue.main.after that waits for
/// `interval` seconds before executing the `work` block.
public func after(_ interval: TimeInterval, work: () -> ()) {
    let time: DispatchTime = DispatchTime.now() + .milliseconds(Int(interval * 1000.0))
    DispatchQueue.main.asyncAfter(deadline: time) {
        work()
    }
}

/// Generates a random time interval between `lowerBound` and `upperBound`.
public func randomInterval(lowerBound: TimeInterval, upperBound: TimeInterval) -> TimeInterval {
    let fixedPoint: TimeInterval = 1000
    let fixedLowerBound = Int(lowerBound * fixedPoint)
    let fixedUpperBound = Int(upperBound * fixedPoint)
    let delta = fixedUpperBound - fixedLowerBound
    let adjustment = Int(arc4random_uniform(UInt32(delta)))
    let result = lowerBound + TimeInterval(adjustment)/fixedPoint
    return result
}

/// Cleans up the text by converting to latin characters, lowercasing, stripping all
/// non alpha-numeric chars, then joining as a string separated by spaces.
///
/// This makes it easy to search for a phrase pattern in a typed message
public func normalize(text: String) -> String {
    return tokenize(text: convertToLatin(text: text)).joined(separator: " ")
}

/// Converts the string into lowercase keyword tokens
public func tokenize(text: String) -> [String] {
    let allowedCharacterSet = NSCharacterSet.alphanumerics.inverted
    let split: [String] = text.components(separatedBy: allowedCharacterSet)
    let nonEmpty: [String] = split.filter{$0 != ""}
    let lowercased: [String] = nonEmpty.map { w in w.lowercased() }
    return lowercased
}

/// Removes diacritics and converts to simple latin characters
public func convertToLatin(text: String) -> String {
    let mutableString = NSMutableString(string: text) as CFMutableString
    CFStringTransform(mutableString, nil, kCFStringTransformToLatin, false)
    CFStringTransform(mutableString, nil, kCFStringTransformStripCombiningMarks, false)
    let result = String(mutableString)
    return result
}
