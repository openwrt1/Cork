import Foundation
let defaults = UserDefaults(suiteName: "eu.davidbures.cork")!
print("From suite: \(defaults.bool(forKey: "customHomebrewApiDomainEnabled"))")
print("From standard: \(UserDefaults.standard.bool(forKey: "customHomebrewApiDomainEnabled"))")
