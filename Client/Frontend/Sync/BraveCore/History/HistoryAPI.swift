// Copyright 2021 The Brave Authors. All rights reserved.
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import Data
import BraveCore
import BraveShared
import CoreData
import Shared

extension BraveHistoryAPI {
    
    // MARK: Internal
    
    public func add(url: URL, title: String, dateAdded: Date, isURLTyped: Bool = true) {
        let historyNode = HistoryNode(url: url, title: title, dateAdded: dateAdded)
        addHistory(historyNode, isURLTyped: isURLTyped)
    }

//    public func frc() -> HistoryV2FetchResultsController? {
//        return Historyv2Fetcher(historyAPI: self)
//    }

    public func delete(_ historyNode: HistoryNode) {
        removeHistory(historyNode)
    }

    public func deleteAll(_ completion: @escaping () -> Void) {
        removeAll {
            completion()
        }
    }

    public func suffix(_ maxLength: Int, _ completion: @escaping ([HistoryNode]) -> Void) {
        search(withQuery: nil, maxCount: UInt(max(20, maxLength)), completion: { historyResults in
            completion(historyResults.map { $0 })
        })
    }

    public func byFrequency(query: String? = nil, _ completion: @escaping ([HistoryNode]) -> Void) {
        guard let query = query, !query.isEmpty else {
            return
        }

        search(withQuery: query, maxCount: 200, completion: { historyResults in
            completion(historyResults.map { $0 })
        })
    }

    public func update(_ historyNode: HistoryNode, customTitle: String?, dateAdded: Date?) {
        if let title = customTitle {
            historyNode.title = title
        }

        if let date = dateAdded {
            historyNode.dateAdded = date
        }
    }
    
    // MARK: Private
    
    //private var observer: HistoryServiceListener?
    
    private struct AssociatedObjectKeys {
        static var serviceStateListener: Int = 0
    }
    
    public var observer: HistoryServiceListener? {
        get { objc_getAssociatedObject(self, &AssociatedObjectKeys.serviceStateListener) as? HistoryServiceListener }
        set { objc_setAssociatedObject(self, &AssociatedObjectKeys.serviceStateListener, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
}

// MARK: Brave-Core Only

extension BraveHistoryAPI {
    
    public func waitForHistoryServiceLoaded(_ completion: @escaping () -> Void) {
        if isBackendLoaded {
            DispatchQueue.main.async {
                completion()
            }
        } else {
            observer = add(HistoryServiceStateObserver({ [weak self] in
                if case .serviceLoaded = $0 {
                    self?.observer?.destroy()
                    self?.observer = nil
                    
                    DispatchQueue.main.async {
                        completion()
                    }
                }
            }))
        }
    }
}