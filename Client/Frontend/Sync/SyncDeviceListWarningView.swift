// Copyright 2021 The Brave Authors. All rights reserved.
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SwiftUI
import BraveUI

struct BasicSyncDevice: Identifiable {
    let id: String
    let title: String
    let type: DeviceType
    
    enum DeviceType {
        case mobile
        case desktop
    }
}

struct SyncDeviceListWarningView: View {
    var devices: [BasicSyncDevice]
    
    var onCancel: (() -> Void)?
    var onJoin: (() -> Void)?
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Text("List of Devices")
                    .font(.title3.weight(.medium))
                    .foregroundColor(Color(.bravePrimary))
                Spacer(minLength: 15.0)
                Button {
                    onCancel?()
                } label: {
                    Image(uiImage: #imageLiteral(resourceName: "close-medium"))
                }
            }
            .padding([.leading, .trailing, .top])
            Divider()
            Text("There are currently \(devices.count) devices in this sync chain. Please check that ALL of these devices belong to you.")
                .font(.subheadline)
                .foregroundColor(Color(.bravePrimary))
                .padding(.horizontal)
            List {
                ForEach(devices) { device in
                    DeviceView(title: device.title, isMobile: device.type == .mobile)
                        .padding([.vertical])
                }
            }
            .listStyle(PlainListStyle())
            HStack {
                Button(action: {
                    onCancel?()
                }) {
                    Text("Cancel")
                        .frame(maxWidth: .infinity)
                        .font(.body.weight(.medium))
                        .padding()
                }
                .foregroundColor(Color(.braveBlurple))
                
                Button(action: {
                    onJoin?()
                }) {
                    Text("Join")
                        .frame(maxWidth: .infinity)
                        .font(.body.weight(.medium))
                        .padding()
                }
                .background(Color(.braveBlurple))
                .foregroundColor(Color(.braveBackground))
            }
            .border(Color(.braveBlurple))
        }
        .frame(maxWidth: 450)
        .background(Color(.braveBackground))
    }
}

private struct DeviceView: View {
    let title: String
    let isMobile: Bool
    
    var body: some View {
        HStack(alignment: .center, spacing: 8.0) {
            Image(systemName: isMobile ? "apps.iphone" : "desktopcomputer")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 36.0, height: 36.0, alignment: .center)
            Text(title)
                .font(.body)
                .foregroundColor(Color(.bravePrimary))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct SyncDeviceListWarningView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ZStack {
                Rectangle()
                    .foregroundColor(.black)
                    .edgesIgnoringSafeArea(.all)
                
                SyncDeviceListWarningView(devices: [
                    BasicSyncDevice(id: UUID().uuidString, title: "Mobile", type: .mobile),
                    BasicSyncDevice(id: UUID().uuidString, title: "Desktop", type: .desktop),
                    BasicSyncDevice(id: UUID().uuidString, title: "Mobile", type: .mobile),
                    BasicSyncDevice(id: UUID().uuidString, title: "Desktop", type: .desktop)
                ])
            }
            .previewDevice("iPhone 12 Pro")
        }
    }
}
