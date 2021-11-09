// Copyright 2021 The Brave Authors. All rights reserved.
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SwiftUI
import BraveUI

struct PageZoomView: View {
    @State private var minValue = 0.5
    @State private var maxValue = 3.0
    @State private var currentValue = 1.0 {
        didSet {
            pageZoomUpdated(currentValue)
        }
    }
    private var defaultValue = 1.0
    
    let pageZoomUpdated: ((Double) -> Void)
    
    let steps: [Double] = [0.5, 0.75, 0.85, 1.0, 1.15, 1.25, 1.5, 1.75, 2.0, 2.5, 3.0]
    
    init(pageZoomUpdated: @escaping ((Double) -> Void)) {
        self.pageZoomUpdated = pageZoomUpdated
    }
    
    var body: some View {
        ZStack {
            HStack {
                Text("Zoom")
                Spacer()
            }
            customStepper
            HStack {
                Spacer()
                Button("x") {
                }
            }
        }
        .background(Color(.braveBackground))
        .padding()
    }
    
    var customStepper: some View {
        HStack {
            Button("-") { decrement() }
            .disabled(currentValue == minValue)
            .accentColor(Color(.braveLabel))
            .padding(.leading)
            Divider()
                .frame(height: 16)
            Button(percentDisplay(for: currentValue)) {
                currentValue = defaultValue
            }
            .accentColor(Color(.braveLabel))
            Divider()
                .frame(height: 16)
            Button("+") { increment() }
            .disabled(currentValue == maxValue)
            .accentColor(Color(.braveLabel))
            .padding(.trailing)
        }
        .padding(.vertical, 4)
        .background(Color(.secondaryBraveBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
    
    private func increment() {
        if currentValue == maxValue { return }
        guard let index = steps.firstIndex(of: currentValue) else { return }
        currentValue = steps[index.advanced(by: 1)]
    }
    
    private func decrement() {
        if currentValue == minValue { return }
        guard let index = steps.firstIndex(of: currentValue) else { return }
        currentValue = steps[index.advanced(by: -1)]
    }
    
    private func percentDisplay(for value: Double) -> String {
        let str = "\(Int((value * 100).rounded()))%"
        
        return str.count < 4 ? str + " " : str
    }
}

struct PageZoomView_Previews: PreviewProvider {
    static var previews: some View {
        PageZoomView(pageZoomUpdated: { _ in })
    }
}
