//
//  ResponsiveButton.swift
//  ResponsiveButton
//
//  Created by iMoe on 2019/7/2.
//  Copyright © 2019 imoe. All rights reserved.
//

import UIKit

open class ResponsiveButton: UIButton {
    
    /// Determine whether the button's intrinsic size is still the same, after turning
    /// into the busy state.
    @IBInspectable public var keepIntrinsicSize: Bool = true
    
    /// Determine whether the activity indicator is shown or not.
    ///
    /// If true, the button disappears and the indicator is shown.
    public var isBusy: Bool = false {
        didSet {
            if oldValue == true {
                hideActivityIndicator()
            } else {
                showActivityIndicator()
            }
        }
    }
    
    open override var intrinsicContentSize: CGSize {
        guard isBusy else { return super.intrinsicContentSize }
        
        if keepIntrinsicSize {
            return super.intrinsicContentSize
        } else {
            return activityIndicator.bounds.size
        }
    }

    open override var tintColor: UIColor! {
        didSet { tintColorBackup = tintColor }
    }
    
    open override var backgroundColor: UIColor? {
        didSet { backgroundColorBackup = backgroundColor }
    }
    
    /// Backup the tint color before hiding the button image.
    private var tintColorBackup: UIColor = .clear
    /// Backup the background color before hiding the button.
    private var backgroundColorBackup: UIColor?
    /// Backup the title color for each button state.
    private var titleColorBackupForState     : [ButtonState : UIColor?] = .init()
    /// Backup the background image for each button state.
    private var backgroundImageBackupForState: [ButtonState : UIImage?] = .init()
    /// The activity indicator shown at the center of the button.
    private weak var activityIndicator: UIActivityIndicatorView!
    
    open override func setTitleColor(_ color: UIColor?, for state: UIControl.State) {
        super.setTitleColor(color, for: state)
        backupTitleColor(color, for: state)
    }
    
    open override func setBackgroundImage(_ image: UIImage?, for state: UIControl.State) {
        super.setBackgroundImage(image, for: state)
        backupBackgroundImage(image, for: state)
    }
    
    convenience init() {
        self.init(frame: .zero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupInterface()
        tintColorBackup = tintColor
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupInterface()
        tintColorBackup = tintColor
    }
}


public extension ResponsiveButton {
    /// Hide the button content and show the activity indicator.
    func showActivityIndicator() {
        activityIndicator.startAnimating()
        toggleTitleHiddenState(true)
        toggleImageHiddenState(true)
        toggleBackgroundHiddenState(true)
        ButtonState.allCases.forEach {
            backupBackgroundImage(
                backgroundImage(for: $0.correspondControlState), for: $0.correspondControlState)
            setBackgroundImageWithoutBackup(nil, for: $0.correspondControlState)
        }
    }
    
    /// Hide the activity indicator.
    func hideActivityIndicator() {
        activityIndicator.stopAnimating()
        toggleTitleHiddenState(false)
        toggleImageHiddenState(false)
        toggleBackgroundHiddenState(false)
        ButtonState.allCases.forEach {
            setBackgroundImage(backgroundImageBackupForState[$0] ?? nil, for: $0.correspondControlState)
        }
    }
}


private extension ResponsiveButton {
    func setupInterface() {
        let activityIndicator = UIActivityIndicatorView(style: .gray)
        activityIndicator.hidesWhenStopped = true
        addSubview(activityIndicator)
        
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor)
            .isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor)
            .isActive = true
        self.activityIndicator = activityIndicator
    }
    
    func toggleImageHiddenState(_ shouldHide: Bool) {
        let originalTintColor = tintColorBackup
        if shouldHide {
            tintColor = .clear
            /// Prevent tintColorBackup from being clear:
            tintColorBackup = originalTintColor
        } else {  // Recover to original tint color
            tintColor = originalTintColor
        }
    }
    
    func toggleTitleHiddenState(_ shouldHide: Bool) {
        if shouldHide {
            ButtonState.allCases.forEach {
                backupTitleColor(titleColor(for: $0.correspondControlState),
                                 for: $0.correspondControlState)
                setTitleColorWithoutBackup(.clear, for: $0.correspondControlState)
            }
        } else {
            ButtonState.allCases.forEach {
                setTitleColorWithoutBackup(
                    titleColorBackupForState[$0] ?? tintColor, for: $0.correspondControlState)
            }
        }
    }
    
    func toggleBackgroundHiddenState(_ shouldHide: Bool) {
        let originalBackgroundColor = backgroundColorBackup
        if shouldHide {
            backgroundColor = .clear
            /// Prevent backgroundColorBackup from being clear:
            backgroundColorBackup = originalBackgroundColor
        } else {
            backgroundColor = originalBackgroundColor
        }
    }
    
    /// This method changes the title color, while not update the title color backup.
    func setTitleColorWithoutBackup(_ color: UIColor?, for state: UIControl.State) {
        super.setTitleColor(color, for: state)
    }
    
    /// This method updates the title color backup.
    func backupTitleColor(_ color: UIColor?, for state: UIControl.State) {
        guard let buttonState = ButtonState(state: state) else { return }
        titleColorBackupForState[buttonState] = color
    }
    
    /// This method changes the background image, while not update the background image backup.
    func setBackgroundImageWithoutBackup(_ image: UIImage?, for state: UIControl.State) {
        super.setBackgroundImage(image, for: state)
    }

    /// This method updates the background image backup.
    func backupBackgroundImage(_ image: UIImage?, for state: UIControl.State) {
        guard let buttonState = ButtonState(state: state) else { return }
        backgroundImageBackupForState[buttonState] = image
    }
}