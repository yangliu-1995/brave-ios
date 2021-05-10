// Copyright 2021 The Brave Authors. All rights reserved.
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import Data
import BraveRewards
import BraveShared
import CoreData
import Shared

private let log = Logger.browserLogger

struct Historyv2Section {
    var title: String
    
    var numberOfObjects: Int
}

// A Lightweight wrapper around BraveCore history
// with the same layout/interface as `History (from CoreData)`
class Historyv2: WebsitePresentable {
    
    /// Sections in History List to be displayed
    enum Section: Int, CaseIterable {
        /// History happened Today
        case today
        /// History happened Yesterday
        case yesterday
        /// History happened between yesterday and end of this week
        case lastWeek
        /// History happaned
        case thisMonth
        
        /// The list of titles time period
        var title: String {
            switch self {
                case .today:
                     return Strings.today
                case .yesterday:
                     return Strings.yesterday
                case .lastWeek:
                     return Strings.lastWeek
                case .thisMonth:
                     return Strings.lastMonth
            }
        }
    }
    
    // MARK: Lifecycle
    
    init(with node: HistoryNode) {
        self.historyNode = node
    }
    
    // MARK: Internal
    
    public var url: String? {
        historyNode.url.absoluteString
    }
    
    public var title: String? {
        historyNode.title
    }
    
    public var created: Date? {
        get {
            return historyNode.dateAdded
        }
        
        set {
            historyNode.dateAdded = newValue ?? Date()
        }
    }
    
    public var domain: String? {
        historyNode.url.domainURL.absoluteString
    }
    
    public var sectionID: Section? {
        fetchHistoryTimePeriod(visited: created)
    }
    
    // MARK: Private
    
    private let historyNode: HistoryNode
    private static let historyAPI = BraveHistoryAPI()
    
    private func fetchHistoryTimePeriod(visited: Date?) -> Section? {
        let todayOffset = 0
        let yesterdayOffset = -1
        let thisWeekOffset = -7
        let thisMonthOffset = -31
        
        if created?.compare(getDate(todayOffset)) == ComparisonResult.orderedDescending {
            return .today
        } else if created?.compare(getDate(yesterdayOffset)) == ComparisonResult.orderedDescending {
            return .yesterday
        } else if created?.compare(getDate(thisWeekOffset)) == ComparisonResult.orderedDescending {
            return .lastWeek
        } else if created?.compare(getDate(thisMonthOffset))  == ComparisonResult.orderedDescending {
            return .thisMonth
        }
        
        return nil
    }
    
    private func getDate(_ dayOffset: Int) -> Date {
        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        let nowComponents = calendar.dateComponents(
            [Calendar.Component.year, Calendar.Component.month, Calendar.Component.day], from: Date())
        
        guard let today = calendar.date(from: nowComponents) else {
            return Date()
        }
        
        return (calendar as NSCalendar).date(
            byAdding: NSCalendar.Unit.day, value: dayOffset, to: today, options: []) ?? Date()
    }
}

// MARK: History Fetching

extension Historyv2 {

    public class func add(url: URL, title: String, dateAdded: Date) {
        Historyv2.historyAPI.addHistory(HistoryNode(url: url, title: title, dateAdded: dateAdded))
    }
    
    public static func frc() -> HistoryV2FetchResultsController? {
        return Historyv2Fetcher(historyAPI: Historyv2.historyAPI)
    }
    
    public func delete() {
        Historyv2.historyAPI.removeHistory(historyNode)
    }
    
    public class func deleteAll(_ completion: @escaping () -> Void) {
        Historyv2.historyAPI.removeAll {
            completion()
        }
    }
    
    public class func suffix(_ maxLength: Int, _ completion: @escaping ([Historyv2]) -> Void) {
        Historyv2.historyAPI.search(withQuery: nil, maxCount: UInt(max(20, maxLength)), completion: { historyResults in
            completion(historyResults.map { Historyv2(with: $0) })
        })
    }

    public static func byFrequency(query: String? = nil, _ completion: @escaping ([WebsitePresentable]) -> Void) {
        guard let query = query, !query.isEmpty else { return }
        
        Historyv2.historyAPI.search(withQuery: nil, maxCount: 200, completion: { historyResults in
            completion(historyResults.map { Historyv2(with: $0) })
        })
    }
    
    public func update(customTitle: String?, dateAdded: Date?) {
        if let title = customTitle {
            historyNode.title = title
        }
        
        if let date = dateAdded {
            historyNode.dateAdded = date
        }
    }
}

// MARK: Brave-Core Only

extension Historyv2 {
    
    public static func waitForHistoryServiceLoaded(_ completion: @escaping () -> Void) {
        if historyAPI.isLoaded {
            DispatchQueue.main.async {
                completion()
            }
        } else {
            var observer: HistoryServiceListener?
            observer = Historyv2.historyAPI.add(HistoryServiceStateObserver({
                if case .serviceLoaded = $0 {
                    observer?.destroy()
                    observer = nil
                    
                    DispatchQueue.main.async {
                        completion()
                    }
                }
            }))
        }
    }
}
