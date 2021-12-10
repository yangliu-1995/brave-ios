// Copyright 2021 The Brave Authors. All rights reserved.
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import CrashReporter

class CrashHelper {
    private static var crashReporter: PLCrashReporter!
    
    static func setup() {
        let config = PLCrashReporterConfig(signalHandlerType: .mach, symbolicationStrategy: .all)
        crashReporter = PLCrashReporter(configuration: config)
        
        guard let crashReporter = CrashHelper.crashReporter else {
            NSException(name: .genericException, reason: "Error: Could not create an instance of PLCrashReporter", userInfo: nil).raise()
            return
        }

        // Enable the Crash Reporter.
        do {
            try crashReporter.enableAndReturnError()
        } catch let error {
            NSException(name: .genericException, reason: "Error: Could not enable crash reporter: \(error)", userInfo: nil).raise()
        }
        return
    }
    
    static func displayCrash(on controller: UIViewController) {
        guard let crashReporter = CrashHelper.crashReporter else {
            NSException(name: .genericException, reason: "Error: Could not create an instance of PLCrashReporter", userInfo: nil).raise()
            return
        }
        
        if crashReporter.hasPendingCrashReport() {
            do {
                let data = try crashReporter.loadPendingCrashReportDataAndReturnError()
                let report = try PLCrashReport(data: data)
                if let text = PLCrashReportTextFormatter.stringValue(for: report, with: PLCrashReportTextFormatiOS) {
                    
                    let alert = UIAlertController(title: "Error - Crash Report", message: text, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: { _ in
                        
                    }))
                    controller.present(alert, animated: true)
                } else {
                    NSException(name: .genericException, reason: "CrashReporter: can't convert report to text", userInfo: nil).raise()
                }
            } catch let error {
                NSException(name: .genericException, reason: "CrashReporter failed to load and parse with error: \(error)", userInfo: nil).raise()
            }
        }
        
        crashReporter.purgePendingCrashReport()
    }
}
