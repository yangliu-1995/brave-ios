// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import BraveShared
import Foundation
import Shared

extension ShieldsViewController {
    class View: UIView, Themeable {

        private let scrollView = UIScrollView().then {
            $0.delaysContentTouches = false
        }

        var contentView: UIView? {
            didSet {
                oldValue?.removeFromSuperview()
                if let view = contentView {
                    scrollView.addSubview(view)
                    view.snp.makeConstraints {
                        $0.edges.equalToSuperview()
                    }
                }
            }
        }

        let stackView = UIStackView().then {
            $0.axis = .vertical
            $0.isLayoutMarginsRelativeArrangement = true
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        let simpleShieldView = SimpleShieldsView()
        let advancedControlsBar = AdvancedControlsBarView()
        let advancedShieldView = AdvancedShieldsView().then {
            $0.isHidden = true
        }

        let reportBrokenSiteView = ReportBrokenSiteView()
        let siteReportedView = SiteReportedView()

        override init(frame: CGRect) {
            super.init(frame: frame)

            stackView.addArrangedSubview(simpleShieldView)
            stackView.addArrangedSubview(advancedControlsBar)
            stackView.addArrangedSubview(advancedShieldView)

            addSubview(scrollView)
            scrollView.addSubview(stackView)

            scrollView.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }

            scrollView.contentLayoutGuide.snp.makeConstraints {
                $0.left.right.equalTo(self)
            }

            stackView.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }

            contentView = stackView
        }

        func applyTheme(_ theme: Theme) {
            simpleShieldView.applyTheme(theme)
            advancedControlsBar.applyTheme(theme)
            advancedShieldView.applyTheme(theme)
            reportBrokenSiteView.applyTheme(theme)
            siteReportedView.applyTheme(theme)

            backgroundColor = theme.isDark ? BraveUX.popoverDarkBackground : UIColor.white
        }

        @available(*, unavailable)
        required init(coder: NSCoder) {
            fatalError()
        }
    }
}

extension ShieldsViewController {

    var closeActionAccessibilityLabel: String {
        return Strings.Popover.closeShieldsMenu
    }
}
