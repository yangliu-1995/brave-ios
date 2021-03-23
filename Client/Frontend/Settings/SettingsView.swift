// Copyright 2021 The Brave Authors. All rights reserved.
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import SwiftUI
import BraveRewards
import Shared
import BraveShared
import LocalAuthentication

struct UIKitController: UIViewControllerRepresentable {
    var make: (Context) -> UIViewController
    func makeUIViewController(context: Context) -> UIViewController {
        make(context)
    }
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
    }
}

struct FormHeaderText: View {
    var text: String
    var body: some View {
        if #available(iOS 14.0, *) {
            Text(verbatim: text)
                .padding([.leading, .trailing], 20)
        } else {
            Text(verbatim: text.uppercased())
        }
    }
}

struct FormFooterText: View {
    var text: String
    var body: some View {
        if #available(iOS 14.0, *) {
            Text(verbatim: text)
                .padding([.leading, .trailing], 20)
        } else {
            Text(verbatim: text)
        }
    }
}

struct SettingsView: View {
    enum Action {
        case openURLs(_ urls: [URL])
        case pushViewController(_ viewController: UIViewController)
    }
    
    @ObservedObject private var saveLogins = Preferences.General.saveLogins
    @ObservedObject private var tabBarVisibility = Preferences.General.tabBarVisibility
    @ObservedObject private var showBookmarkToolbarShortcut = Preferences.General.showBookmarkToolbarShortcut
    @ObservedObject private var hideRewardsIcon = Preferences.Rewards.hideRewardsIcon
    @ObservedObject private var themeNormalMode = Preferences.General.themeNormalMode
    
    private let profile: Profile
    private let tabManager: TabManager
    private let rewards: BraveRewards?
    private let legacyWallet: BraveLedger?
    private let feedDataSource: FeedDataSource
    private var actionHandler: (Action) -> Void
    
    init(profile: Profile, tabManager: TabManager, feedDataSource: FeedDataSource, rewards: BraveRewards? = nil, legacyWallet: BraveLedger? = nil, actionHandler: @escaping (Action) -> Void) {
        self.profile = profile
        self.tabManager = tabManager
        self.feedDataSource = feedDataSource
        self.rewards = rewards
        self.legacyWallet = legacyWallet
        self.actionHandler = actionHandler
    }
    
    var body: some View {
        Form {
            Group {
                featuresSection
                generalSection
                displaySection
                securitySection
                supportSection
                aboutSection
            }
            .listRowBackground(Color(Theme.of(nil).colors.header))
        }
        .foregroundColor(Color(Theme.of(nil).colors.tints.home))
        .accentColor(Color(BraveUX.braveOrange))
        .navigationBarTitle(Strings.settings)
    }
    
    var featuresSection: some View {
        Section(
            header: FormHeaderText(text: Strings.features)
                .padding(.top) // Needed for better spacing at the top of the table
        ) {
            NavigationLink(destination: BraveShieldsAndPrivacyView()) {
                Image(uiImage: #imageLiteral(resourceName: "settings-shields"))
                Text(verbatim: Strings.braveShieldsAndPrivacy)
            }
            if BraveRewards.isAvailable, let rewards = rewards {
                NavigationLink(destination: EmptyView()) {
                    Image(uiImage: #imageLiteral(resourceName: "settings-brave-rewards"))
                    Text(verbatim: Strings.braveRewardsTitle)
                }
            }
            #if !NO_BRAVE_TODAY
            NavigationLink(destination: EmptyView()) {
                Image(uiImage: #imageLiteral(resourceName: "settings-brave-today").template)
                Text(verbatim: Strings.BraveToday.braveToday)
            }
            .contentShape(Rectangle())
            .onTapGesture {
                let vc = BraveTodaySettingsViewController(dataSource: self.feedDataSource)
                actionHandler(.pushViewController(vc))
            }
            #endif
            vpnRow
        }
    }
    
    var vpnRow: some View {
        let (text, color) = { () -> (String, UIColor) in
            switch BraveVPN.vpnState {
            case .notPurchased, .purchased:
                return ("", UIColor.black)
            case .installed(let enabled):
                if enabled {
                    return (Strings.VPN.settingsVPNEnabled, #colorLiteral(red: 0.1607843137, green: 0.737254902, blue: 0.5647058824, alpha: 1))
                } else {
                    return (Strings.VPN.settingsVPNDisabled, BraveUX.red)
                }
            case .expired:
                return (Strings.VPN.settingsVPNExpired, BraveUX.red)
            }
        }()
        func destination(for state: BraveVPN.State) -> UIViewController? {
            switch state {
            case .notPurchased, .purchased, .expired:
                return BraveVPN.vpnState.enableVPNDestinationVC
            case .installed:
                let vc = BraveVPNSettingsViewController()
                vc.faqButtonTapped = {
                    actionHandler(.openURLs([BraveUX.braveVPNFaqURL]))
                }
                return vc
            }
        }
        return NavigationLink(destination: EmptyView()) {
            Text(verbatim: Strings.VPN.vpnName)
            Spacer()
            Text(verbatim: text)
                .foregroundColor(Color(color))
        }
        .contentShape(Rectangle())
        .onTapGesture {
            if let vc = destination(for: BraveVPN.vpnState) {
                actionHandler(.pushViewController(vc))
            }
        }
    }
    
    var generalSection: some View {
        Section(
            header: FormHeaderText(text: Strings.settingsGeneralSectionTitle)
        ) {
            NavigationLink(destination: EmptyView()) {
                Image(uiImage: #imageLiteral(resourceName: "settings-search").template)
                Text(verbatim: Strings.searchEngines)
            }
            NavigationLink(destination: EmptyView()) {
                Image(uiImage: #imageLiteral(resourceName: "settings-sync").template)
                Text(verbatim: Strings.sync)
            }
            if AppConstants.iOSVersionGreaterThanOrEqual(to: 14) {
                Button(action: {
                    guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                        return
                    }
                    UIApplication.shared.open(settingsUrl)
                }) {
                    Text(verbatim: Strings.setDefaultBrowserSettingsCell)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(Color(BraveUX.braveOrange))
                }
            }
        }
    }
    
    var displaySection: some View {
        return Section(
            header: FormHeaderText(text: Strings.displaySettingsSection)
        ) {
            Picker(
                selection: $themeNormalMode.value,
                label: HStack {
                    Image(uiImage: #imageLiteral(resourceName: "settings-appearance").template)
                    Text(verbatim: Strings.themesDisplayBrightness)
                }) {
                ForEach(Theme.DefaultTheme.normalThemesOptions, id: \.rawValue) {
                    Text(verbatim: $0.displayString).tag($0.rawValue)
                }
            }
            NavigationLink(destination: EmptyView()) {
                Image(uiImage: #imageLiteral(resourceName: "settings-ntp").template)
                Text(verbatim: Strings.NTP.settingsTitle)
            }
            if UIDevice.current.userInterfaceIdiom == .pad {
                Toggle(isOn: .constant(true)) {
                    Image(uiImage: #imageLiteral(resourceName: "settings-show-tab-bar").template)
                    Text(verbatim: Strings.showTabsBar)
                }
            } else {
                Picker(selection: $tabBarVisibility.value, label: HStack {
                    Image(uiImage: #imageLiteral(resourceName: "settings-show-tab-bar").template)
                    Text(verbatim: Strings.showTabsBar)
                }) {
                    ForEach(TabBarVisibility.allCases, id: \.self) {
                        Text(verbatim: $0.displayString).tag($0.rawValue)
                    }
                }
            }
            Toggle(isOn: $showBookmarkToolbarShortcut.value) {
                Image(uiImage: #imageLiteral(resourceName: "settings-bookmarks-shortcut").template)
                Text(verbatim: Strings.showBookmarkButtonInTopToolbar)
            }
            Toggle(isOn: $hideRewardsIcon.value) {
                Image(uiImage: #imageLiteral(resourceName: "settings-rewards-icon").template)
                Text(verbatim: Strings.hideRewardsIcon)
            }
        }
    }
    
    var securitySection: some View {
        let passcodeTitle: String = {
            let localAuthContext = LAContext()
            if localAuthContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) {
                if localAuthContext.biometryType == .faceID {
                    return Strings.authenticationFaceIDPasscodeSetting
                } else {
                    return Strings.authenticationTouchIDPasscodeSetting
                }
            } else {
                return Strings.authenticationPasscode
            }
        }()
        return Section(
            header: FormHeaderText(text: Strings.security)
        ) {
            NavigationLink(destination: EmptyView()) {
                Image(uiImage: #imageLiteral(resourceName: "settings-passcode").template)
                Text(verbatim: passcodeTitle)
            }
            Toggle(isOn: $saveLogins.value) {
                Image(uiImage: #imageLiteral(resourceName: "settings-save-logins").template)
                Text(verbatim: Strings.saveLogins)
            }
        }
    }
    
    var supportSection: some View {
        Section(
            header: FormHeaderText(text: Strings.support)
        ) {
            Button(action: { self.actionHandler(.openURLs([BraveUX.braveCommunityURL])) }) {
                HStack {
                    Image(uiImage: #imageLiteral(resourceName: "settings-report-bug").template)
                    Text(verbatim: Strings.reportABug)
                }
            }
            Button(action: { self.actionHandler(.openURLs([BraveUX.braveCommunityURL])) }) {
                HStack {
                    Image(uiImage: #imageLiteral(resourceName: "settings-rate").template)
                    Text(verbatim: Strings.rateBrave)
                }
            }
        }
    }
    
    @State private var isShowingVersionPrompt: Bool = false
    var aboutSection: some View {
        let version = String(format: Strings.versionTemplate,
                             Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "",
                             Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "")
        return Section(
            header: FormHeaderText(text: Strings.about)
        ) {
            Button(action: { self.isShowingVersionPrompt = true }) {
                Text(verbatim: version)
            }
            .actionSheet(isPresented: $isShowingVersionPrompt) {
                ActionSheet(
                    title: Text(""),
                    message: nil,
                    buttons: [
                        .default(Text(verbatim: Strings.copyAppInfoToClipboard), action: {
                            let device = UIDevice.current
                            let iOSVersion = "\(device.systemName) \(UIDevice.current.systemVersion)"
                            let deviceModel = String(format: Strings.deviceTemplate, device.modelName, iOSVersion)
                            UIPasteboard.general.strings = [version, deviceModel]
                        }),
                        .cancel()
                    ]
                )
            }
            Button(action: { }) {
                Text(verbatim: Strings.privacyPolicy)
                    .foregroundColor(Color(BraveUX.braveOrange))
            }
            Button(action: { }) {
                Text(verbatim: Strings.termsOfUse)
                    .foregroundColor(Color(BraveUX.braveOrange))
            }
            NavigationLink(destination: EmptyView()) {
                Text(verbatim: Strings.settingsLicenses)
            }
        }
    }
}
