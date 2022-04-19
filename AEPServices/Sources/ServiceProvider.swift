/*
 Copyright 2020 Adobe. All rights reserved.
 This file is licensed to you under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License. You may obtain a copy
 of the License at http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software distributed under
 the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR REPRESENTATIONS
 OF ANY KIND, either express or implied. See the License for the specific language
 governing permissions and limitations under the License.
 */

import Foundation

public class ServiceProvider {
    public static let shared = ServiceProvider()

    /// MessagingDelegate which is used to listen for message visibility updates.
    public weak var messagingDelegate: MessagingDelegate?

    // Provide thread safety on the getters and setters
    private let queue = DispatchQueue(label: "ServiceProvider.barrierQueue")

    private var overrideSystemInfoService: SystemInfoService?
    private var defaultSystemInfoService = ApplicationSystemInfoService()
    private var overrideKeyValueService: NamedCollectionProcessing?
    private var defaultKeyValueService = UserDefaultsNamedCollection()
    private var overrideNetworkService: Networking?
    private var defaultNetworkService = NetworkService()
    private var defaultDataQueueService = DataQueueService()
    private var overrideCacheService: Caching?
    private var defaultCacheService = DiskCacheService()
    private var defaultLoggingService = LoggingService()

    // Don't allow init of ServiceProvider outside the class
    private init() {}

    /// The SystemInfoService, either set externally (override) or the default implementation
    public var systemInfoService: SystemInfoService {
        get {
            return queue.sync {
                return overrideSystemInfoService ?? defaultSystemInfoService
            }
        }
        set {
            queue.async {
                self.overrideSystemInfoService = newValue
            }
        }
    }

    public var namedKeyValueService: NamedCollectionProcessing {
        get {
            return queue.sync {
                return overrideKeyValueService ?? defaultKeyValueService
            }
        }
        set {
            queue.async {
                self.overrideKeyValueService = newValue
            }
        }
    }

    public var networkService: Networking {
        get {
            return queue.sync {
                return overrideNetworkService ?? defaultNetworkService
            }
        }
        set {
            queue.async {
                self.overrideNetworkService = newValue
            }
        }
    }

    public var dataQueueService: DataQueuing {
        return queue.sync {
            return defaultDataQueueService
        }
    }

    public var cacheService: Caching {
        get {
            return queue.sync {
                return overrideCacheService ?? defaultCacheService
            }
        }
        set {
            queue.async {
                self.overrideCacheService = newValue
            }
        }
    }

    public var loggingService: Logging {
        return queue.sync {
            return defaultLoggingService
        }
    }

    internal func reset() {
        queue.async {
            self.defaultSystemInfoService = ApplicationSystemInfoService()
            self.defaultKeyValueService = UserDefaultsNamedCollection()
            self.defaultNetworkService = NetworkService()
            self.defaultDataQueueService = DataQueueService()
            self.defaultCacheService = DiskCacheService()
            self.defaultLoggingService = LoggingService()

            self.overrideSystemInfoService = nil
            self.overrideKeyValueService = nil
            self.overrideNetworkService = nil
            self.overrideCacheService = nil
        }
    }
}

@available(iOSApplicationExtension, unavailable)
extension ServiceProvider {
    private struct Holder {
        static var overrideURLService: URLOpening?
        static var defaultURLService = URLService()
        static var overrideUIService: UIService?
        static var defaultUIService = AEPUIService()
    }

    public var urlService: URLOpening {
        get {
            return queue.sync {
                return Holder.overrideURLService ?? Holder.defaultURLService
            }
        }
        set {
            queue.async {
                Holder.overrideURLService = newValue
            }
        }
    }

    public var uiService: UIService {
        get {
            return queue.sync {
                return Holder.overrideUIService ?? Holder.defaultUIService
            }
        }
        set {
            queue.async {
                Holder.overrideUIService = newValue
            }
        }
    }

    internal func resetAppOnlyServices() {
        queue.async {
            Holder.defaultURLService = URLService()
            Holder.defaultUIService = AEPUIService()
            Holder.overrideURLService = nil
            Holder.overrideUIService = nil
        }
    }

}
