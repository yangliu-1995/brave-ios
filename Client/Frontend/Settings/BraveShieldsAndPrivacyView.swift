// Copyright 2021 The Brave Authors. All rights reserved.
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SwiftUI
import Shared
import BraveShared

struct BraveShieldsAndPrivacyView: View {
    var body: some View {
        Form {
            Group {
                ShieldsSection()
            }
            .listRowBackground(Color(Theme.of(nil).colors.header))
        }
        .foregroundColor(Color(Theme.of(nil).colors.tints.home))
        .accentColor(Color(BraveUX.braveOrange))
        .navigationBarTitle(Strings.braveShieldsAndPrivacy)
    }
    
    private struct ShieldsSection: View {
        @ObservedObject var blockAdsAndTracking = Preferences.Shields.blockAdsAndTracking
        @ObservedObject var httpsEverywhere = Preferences.Shields.httpsEverywhere
        @ObservedObject var blockPhishingAndMalware = Preferences.Shields.blockPhishingAndMalware
        @ObservedObject var blockScripts = Preferences.Shields.blockScripts
        
        var body: some View {
            Section(
                header: FormHeaderText(text: Strings.shieldsDefaults).padding(.top),
                footer: FormFooterText(text: Strings.shieldsDefaultsFooter)
            ) {
                Toggle(isOn: $blockAdsAndTracking.value) {
                    VStack(alignment: .leading) {
                        Text(verbatim: Strings.blockAdsAndTracking)
                        Text(verbatim: Strings.blockAdsAndTrackingDescription)
                            .font(.footnote)
                            .opacity(0.8)
                    }
                }
                Toggle(isOn: $httpsEverywhere.value) {
                    VStack(alignment: .leading) {
                        Text(verbatim: Strings.HTTPSEverywhere)
                        Text(verbatim: Strings.HTTPSEverywhereDescription)
                            .font(.footnote)
                            .opacity(0.8)
                    }
                }
                Toggle(isOn: $blockPhishingAndMalware.value) {
                    Text(verbatim: Strings.blockPhishingAndMalware)
                }
                Toggle(isOn: $blockScripts.value) {
                    VStack(alignment: .leading) {
                        Text(verbatim: Strings.blockScripts)
                        Text(verbatim: Strings.blockScriptsDescription)
                            .font(.footnote)
                            .opacity(0.8)
                    }
                }
                CookieToggle()
            }
        }
    }
    
    struct CookieToggle: View {
        @ObservedObject var blockAllCookies = Preferences.Privacy.blockAllCookies
        
        @State var isShowingCookieError = false
        @State var isShowingCookieAlert = false
        
        private func toggleCookieSetting(with status: Bool) {
            // Lock/Unlock Cookie Folder
            let completionBlock: (Bool) -> Void = { _ in
                let success = FileManager.default.setFolderAccess([
                    (.cookie, status),
                    (.webSiteData, status)
                ])
                if success {
                    blockAllCookies.value = status
                } else {
                    // Revert the changes. Not handling success here to avoid a loop.
                    FileManager.default.setFolderAccess([
                        (.cookie, false),
                        (.webSiteData, false)
                    ])
                    // Delay as the previous alert still may be animating out
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        isShowingCookieError = true
                    }
                }
            }
            // Save cookie to disk before purge for unblock load.
            status ? HTTPCookie.saveToDisk(completion: completionBlock) : completionBlock(true)
        }
        
        var blockCookieBinding: Binding<Bool> {
            Binding(
                get: { blockAllCookies.value },
                set: {
                    if $0 {
                        isShowingCookieAlert = true
                    } else {
                        toggleCookieSetting(with: $0)
                    }
                }
            )
        }
        
        var body: some View {
            Toggle(isOn: blockCookieBinding) {
                VStack(alignment: .leading) {
                    Text(verbatim: Strings.blockAllCookies)
                    Text(verbatim: Strings.blockCookiesDescription)
                        .font(.footnote)
                        .opacity(0.8)
                }
            }
            .background(Color.clear
            .alert(isPresented: $isShowingCookieError) {
                Alert(
                    title: Text(verbatim: Strings.blockAllCookiesFailedAlertMsg),
                    dismissButton: .default(Text(verbatim: Strings.OKString))
                )
            })
            .background(Color.clear
            .alert(isPresented: $isShowingCookieAlert) {
                Alert(
                    title: Text(verbatim: Strings.blockAllCookiesAlertTitle),
                    message: Text(verbatim: Strings.blockAllCookiesAlertInfo),
                    primaryButton: .destructive(Text(verbatim: Strings.blockAllCookiesAction), action: {
                        toggleCookieSetting(with: true)
                    }),
                    secondaryButton: .cancel()
                )
            })
        }
    }
}
