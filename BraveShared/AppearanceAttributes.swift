// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit

extension UILabel {
    @objc public dynamic var appearanceTextColor: UIColor! {
        get { return self.textColor }
        set { self.textColor = newValue }
    }
}

extension UITableView {
    @objc public dynamic var appearanceSeparatorColor: UIColor? {
        get { return self.separatorColor }
        set { self.separatorColor = newValue }
    }
}

extension UITextView {
    @objc public dynamic var appearanceTextColor: UIColor? {
        get { return self.textColor }
        set { self.textColor = newValue }
    }
}

extension UIView {
    @objc public dynamic var appearanceBackgroundColor: UIColor? {
        get { return self.backgroundColor }
        set { self.backgroundColor = newValue }
    }
}

extension UITextField {
    @objc public dynamic var appearanceTextColor: UIColor? {
        get { return self.textColor }
        set { self.textColor = newValue }
    }
}

extension UISwitch {
    @objc public dynamic var appearanceOnTintColor: UIColor? {
        get { return self.onTintColor }
        set { self.onTintColor = newValue }
    }
}

extension UIView {
    @objc public dynamic var appearanceOverrideUserInterfaceStyle: UIUserInterfaceStyle {
        get { self.overrideUserInterfaceStyle }
        set { self.overrideUserInterfaceStyle = newValue }
    }
}

extension UINavigationBar {
    @objc public dynamic var appearanceBarTintColor: UIColor? {
        get { return self.barTintColor }
        set { self.barTintColor = newValue }
    }
}

extension UIToolbar {
    @objc public dynamic var appearanceBarTintColor: UIColor? {
        get { return self.barTintColor }
        set { self.barTintColor = newValue }
    }
}

extension UIButton {
    @objc public dynamic var appearanceTextColor: UIColor! {
        get { return self.titleColor(for: .normal) }
        set { self.setTitleColor(newValue, for: .normal) }
    }

    @objc public dynamic var appearanceTintColor: UIColor! {
        get { return self.tintColor }
        set { self.tintColor = newValue }
    }
}
