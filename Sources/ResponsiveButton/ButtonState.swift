//
//  ButtonState.swift
//  ResponsiveButton
//
//  Created by iMoe on 2019/7/2.
//  Copyright © 2019 imoe. All rights reserved.
//

import UIKit

public enum ButtonState: CaseIterable {
    case normal
    case selected
    case highlighted
    case disabled
    
    init?(state: UIControl.State) {
        switch state {
        case .normal:
            self = .normal
        case .highlighted:
            self = .highlighted
        case .selected:
            self = .selected
        case .disabled:
            self = .disabled
        default:
            return nil
        }
    }
    
    var correspondControlState: UIControl.State {
        switch self {
        case .normal:
            return .normal
        case .selected:
            return .selected
        case .highlighted:
            return .highlighted
        case .disabled:
            return .disabled
        }
    }
}
