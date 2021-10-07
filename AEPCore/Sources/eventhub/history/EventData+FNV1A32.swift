/*
 Copyright 2021 Adobe. All rights reserved.
 This file is licensed to you under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License. You may obtain a copy
 of the License at http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software distributed under
 the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR REPRESENTATIONS
 OF ANY KIND, either express or implied. See the License for the specific language
 governing permissions and limitations under the License.
 */

import Foundation
import AEPServices

extension Dictionary where Key == String, Value == Any {
    /// Flattens the dictionary then calls `fnv1a32_inner`.
    ///
    /// The `mask`, if provided, determines which key-value pairs in the dictionary will be used
    /// to generate the hash.
    /// If `mask` is `nil`, all key-value pairs in the dictionary will be used.
    ///
    /// The method for generating the hash does not recurse through the dictionary,
    /// so flattening the dictionary first will ensure there are no nested containers as values.
    ///
    /// - Parameter mask: an array of `String`s that will be used to determine which KVPs are in the hash.
    /// - Returns an unsigned integer hash that represents the requested data in the dictionary.
    func fnv1a32(mask: [String]? = nil) -> UInt32 {
        return self.flattening().fnv1a32_inner(mask: mask)
    }

    /// processes the flattened dictionary
    private func fnv1a32_inner(mask: [String]? = nil) -> UInt32 {
        var alphabeticalKeys: [String]
        // if a mask is provided, only use keys in the provided mask and alphabetize their order
        if let mask = mask {
            alphabeticalKeys = self.keys.filter({ mask.contains($0) }).sorted()
        } else {
            alphabeticalKeys = self.keys.sorted()
        }

        var hash: UInt32 = 0
        for i in 0..<alphabeticalKeys.count {
            let key = alphabeticalKeys[i]
            var valueAsString = ""
            if let value = self[key] {
                if let anyCodable = value as? AnyCodable, let codableValue = anyCodable.value {
                    valueAsString = String(describing: codableValue)
                } else {
                    valueAsString = String(describing: value)
                }
            }
            let kvpString = key + ":" + valueAsString
            hash = kvpString.fnv1a32(hash)
        }

        return hash
    }
}
