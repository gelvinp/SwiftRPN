//
//  MathKeyboard+Layout.swift
//  SwiftRPN
//
//  Created by Patrick Gelvin on 11/26/23.
//

import UIKit

extension MathKeyboard {
    func layoutKeyboard() {
        autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        vstack.axis = .vertical
        vstack.alignment = .fill
        vstack.distribution = .fillEqually
        vstack.frame = bounds
        vstack.autoresizingMask = autoresizingMask
        addSubview(vstack)
        
        let row0 = UIStackView()
        row0.axis = .horizontal
        row0.alignment = .fill
        row0.distribution = .fillProportionally
        
        let row0Digits = makeRow(digits: [7, 8, 9])
        let row0Operators = makeRow(images: ["plus", "minus"], tags: [.Add, .Sub])
        
        row0.addArrangedSubview(row0Digits)
        row0.addArrangedSubview(row0Operators)
        
        let row1 = UIStackView()
        row1.axis = .horizontal
        row1.alignment = .fill
        row1.distribution = .fillProportionally
        
        let row1Digits = makeRow(digits: [4, 5, 6])
        let row1Operators = makeRow(images: ["multiply", "divide"], tags: [.Mul, .Div])
        
        row1.addArrangedSubview(row1Digits)
        row1.addArrangedSubview(row1Operators)
        
        let row2 = UIStackView()
        row2.axis = .horizontal
        row2.alignment = .fill
        row2.distribution = .fillProportionally
        
        let row2Digits = makeRow(digits: [1, 2, 3])
        let row2Operators = makeRow(images: ["plusminus", "character.cursor.ibeam"], tags: [.Neg, .Abc])
        row2Operators.arrangedSubviews[0].accessibilityLabel = "Negate"
        row2Operators.arrangedSubviews[0].accessibilityHint = "Negates the value in the scratchpad if one exists, or negates the top value in the stack."
        row2Operators.arrangedSubviews[1].accessibilityLabel = "Open Full Keyboard"
        row2Operators.arrangedSubviews[1].accessibilityHint = "Opens the standard keyboard for entering letters and special characters."
        
        row2.addArrangedSubview(row2Digits)
        row2.addArrangedSubview(row2Operators)
        
        let row3 = UIStackView()
        row3.axis = .horizontal
        row3.alignment = .fill
        row3.distribution = .fillProportionally
        
        let row3Digits = UIStackView()
        row3Digits.axis = .horizontal
        row3Digits.alignment = .fill
        row3Digits.distribution = .fillEqually
        
        row3Digits.addArrangedSubview(makeButton(imageName: "delete.left.fill", tag: .Del))
        row3Digits.addArrangedSubview(makeButton(digit: 0))
        row3Digits.addArrangedSubview(makeButton(text: ".", tag: .Dot))
        
        let row3Operator = makeButton(text: "Enter", tag: .Ret)
        
        row3.addArrangedSubview(row3Digits)
        row3.addArrangedSubview(row3Operator)
        
        vstack.addArrangedSubview(row0)
        vstack.addArrangedSubview(row1)
        vstack.addArrangedSubview(row2)
        vstack.addArrangedSubview(row3)
        
        row0Operators.arrangedSubviews[0].widthAnchor.constraint(equalTo: row0Digits.arrangedSubviews[0].widthAnchor).isActive = true
        row1Operators.arrangedSubviews[0].widthAnchor.constraint(equalTo: row1Digits.arrangedSubviews[0].widthAnchor).isActive = true
        row2Operators.arrangedSubviews[0].widthAnchor.constraint(equalTo: row2Digits.arrangedSubviews[0].widthAnchor).isActive = true
        
        row1Operators.widthAnchor.constraint(equalTo: row0Operators.widthAnchor, multiplier: 1).isActive = true
        row2Operators.widthAnchor.constraint(equalTo: row1Operators.widthAnchor, multiplier: 1).isActive = true
        row3Operator.widthAnchor.constraint(equalTo: row2Operators.widthAnchor, multiplier: 1).isActive = true
        
        let extraButtons = Settings.shared.extraButtonData
        if enableExtraButtons && extraButtons[0].count > 0 {
            let row0ExtraButtons = makeExtraButtons(assignments: extraButtons[0], firstTag: .Extra11)
            let row1ExtraButtons = makeExtraButtons(assignments: extraButtons[1], firstTag: .Extra21)
            let row2ExtraButtons = makeExtraButtons(assignments: extraButtons[2], firstTag: .Extra31)
            let row3ExtraButtons = makeExtraButtons(assignments: extraButtons[3], firstTag: .Extra41)
            
            row0.addArrangedSubview(row0ExtraButtons)
            row1.addArrangedSubview(row1ExtraButtons)
            row2.addArrangedSubview(row2ExtraButtons)
            row3.addArrangedSubview(row3ExtraButtons)
            
            row0ExtraButtons.widthAnchor.constraint(equalTo: row3Operator.widthAnchor).isActive = true
            row1ExtraButtons.widthAnchor.constraint(equalTo: row0ExtraButtons.widthAnchor, multiplier: 1).isActive = true
            row2ExtraButtons.widthAnchor.constraint(equalTo: row1ExtraButtons.widthAnchor, multiplier: 1).isActive = true
            row3ExtraButtons.widthAnchor.constraint(equalTo: row2ExtraButtons.widthAnchor, multiplier: 1).isActive = true
            
            for index in 0..<row0ExtraButtons.arrangedSubviews.count {
                makeColDivider(trailingUpper: row0ExtraButtons.arrangedSubviews[index], trailingLower: row3ExtraButtons.arrangedSubviews[index])
            }
        }
        
        makeRowDivider(upperRow: row0)
        makeRowDivider(upperRow: row1)
        makeRowDivider(upperRow: row2)
        
        makeColDivider(leadingUpper: row0Digits.arrangedSubviews[0], leadingLower: row3Digits.arrangedSubviews[0])
        makeColDivider(leadingUpper: row0Digits.arrangedSubviews[1], leadingLower: row3Digits.arrangedSubviews[1])
        makeColDivider(leadingUpper: row0Digits.arrangedSubviews[2], leadingLower: row3Digits.arrangedSubviews[2])
        makeColDivider(leadingUpper: row0Operators.arrangedSubviews[0], leadingLower: row2Operators.arrangedSubviews[0])
    }
    
    private func makeRow(digits: [Int]) -> UIStackView {
        let rowDigits = UIStackView()
        rowDigits.axis = .horizontal
        rowDigits.alignment = .fill
        rowDigits.distribution = .fillEqually
        
        for digit in digits {
            rowDigits.addArrangedSubview(makeButton(digit: digit))
        }
        
        rowDigits.translatesAutoresizingMaskIntoConstraints = false
        
        return rowDigits
    }
    
    private func makeRow(images: [String], tags: [OperatorTag]) -> UIStackView {
        let rowOperators = UIStackView()
        rowOperators.axis = .horizontal
        rowOperators.alignment = .fill
        rowOperators.distribution = .fillEqually
        
        for (image, tag) in zip(images, tags) {
            rowOperators.addArrangedSubview(makeButton(imageName: image, tag: tag))
        }
        
        return rowOperators
    }
    
    private func makeRowDivider(upperRow: UIView) {
        let rowDivider = UIView(frame: .zero)
        rowDivider.translatesAutoresizingMaskIntoConstraints = false
        rowDivider.backgroundColor = .mathKeyboardSeparator
        
        addSubview(rowDivider)
        
        rowDivider.heightAnchor.constraint(equalToConstant: 1 / (window?.windowScene?.screen.scale ?? 1.0)).isActive = true
        rowDivider.leadingAnchor.constraint(equalTo: upperRow.leadingAnchor).isActive = true
        rowDivider.trailingAnchor.constraint(equalTo: upperRow.trailingAnchor).isActive = true
        rowDivider.topAnchor.constraint(equalTo: upperRow.bottomAnchor).isActive = true
    }
    
    private func makeRowDivider(lowerRow: UIView) {
        let rowDivider = UIView(frame: .zero)
        rowDivider.translatesAutoresizingMaskIntoConstraints = false
        rowDivider.backgroundColor = .mathKeyboardSeparator
        
        addSubview(rowDivider)
        
        rowDivider.heightAnchor.constraint(equalToConstant: 1 / (window?.windowScene?.screen.scale ?? 1.0)).isActive = true
        rowDivider.leadingAnchor.constraint(equalTo: lowerRow.leadingAnchor).isActive = true
        rowDivider.trailingAnchor.constraint(equalTo: lowerRow.trailingAnchor).isActive = true
        rowDivider.bottomAnchor.constraint(equalTo: lowerRow.topAnchor).isActive = true
    }
    
    private func makeColDivider(leadingUpper: UIView, leadingLower: UIView) {
        let colDivider = UIView(frame: .zero)
        colDivider.translatesAutoresizingMaskIntoConstraints = false
        colDivider.backgroundColor = .mathKeyboardSeparator
        
        addSubview(colDivider)
        
        colDivider.widthAnchor.constraint(equalToConstant: 1 / (window?.windowScene?.screen.scale ?? 1.0)).isActive = true
        colDivider.topAnchor.constraint(equalTo: leadingUpper.topAnchor, constant: -1).isActive = true
        colDivider.bottomAnchor.constraint(equalTo: leadingLower.bottomAnchor, constant: 1).isActive = true
        colDivider.leadingAnchor.constraint(equalTo: leadingUpper.trailingAnchor).isActive = true
    }
    
    private func makeColDivider(trailingUpper: UIView, trailingLower: UIView) {
        let colDivider = UIView(frame: .zero)
        colDivider.translatesAutoresizingMaskIntoConstraints = false
        colDivider.backgroundColor = .mathKeyboardSeparator
        
        addSubview(colDivider)
        
        colDivider.widthAnchor.constraint(equalToConstant: 1 / (window?.windowScene?.screen.scale ?? 1.0)).isActive = true
        colDivider.topAnchor.constraint(equalTo: trailingUpper.topAnchor, constant: -1).isActive = true
        colDivider.bottomAnchor.constraint(equalTo: trailingLower.bottomAnchor, constant: 1).isActive = true
        colDivider.trailingAnchor.constraint(equalTo: trailingUpper.leadingAnchor).isActive = true
    }
}
