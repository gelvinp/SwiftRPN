//
//  Colors.swift
//  SwiftRPN
//
//  Created by Patrick Gelvin on 11/14/23.
//

import UIKit


enum StackColor : Int {
    case Red
    case Orange
    case Yellow
    case Green
    case Blue
    case Purple
    case White
    case Pink
    case LightBlue
    case Brown
    case Black
    case Gray
    
    
    static func foreground(with index: Int) -> UIColor {
        let index = index % StackColor.Gray.rawValue
        let color = StackColor(rawValue: index)!
        return UIColor.fromStackColor(color)
    }
    
    static func background(with index: Int, style: UIUserInterfaceStyle) -> UIColor {
        let index = index % StackColor.Gray.rawValue
        if (style == .light && index == StackColor.Yellow.rawValue) ||
            (style == .light && index == StackColor.White.rawValue) ||
            (style == .light && index == StackColor.LightBlue.rawValue) ||
            (style == .dark && index >= StackColor.Brown.rawValue) {
            return UIColor.fromStackColor(.Gray)
        }
        return .clear
    }
}


extension UIColor {
    static func fromStackColor(_ stackColor: StackColor) -> UIColor {
        switch stackColor {
        case .Red:
            return UIColor.rcalcRed
        case .Orange:
            return UIColor.rcalcOrange
        case .Yellow:
            return UIColor.rcalcYellow
        case .Green:
            return UIColor.rcalcGreen
        case .Blue:
            return UIColor.rcalcBlue
        case .Purple:
            return UIColor.rcalcPurple
        case .White:
            return UIColor.rcalcWhite
        case .Pink:
            return UIColor.rcalcPink
        case .LightBlue:
            return UIColor.rcalcLightBlue
        case .Brown:
            return UIColor.rcalcBrown
        case .Black:
            return UIColor.rcalcBlack
        case .Gray:
            return UIColor.rcalcGray
        }
    }
}
