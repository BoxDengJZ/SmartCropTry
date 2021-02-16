//
//  Array+shift.swift
//  CropView
//
//  Created by Никита Разумный on 2/3/18.
//

import Foundation

extension Array {
    func shifted(by shiftAmount: Int) -> [Element]{
        guard count > 0, (shiftAmount % count) != 0 else { return self }
        let moduloShiftAmount = shiftAmount % count
        let effectiveShiftAmount: Int
        if shiftAmount < 0{
            effectiveShiftAmount = moduloShiftAmount + count
        }
        else{
            effectiveShiftAmount = moduloShiftAmount
        }
        let shift: (Int) -> Int = {
            if $0 + effectiveShiftAmount >= count{
                return $0 + effectiveShiftAmount - count
            }
            else{
                return $0 + effectiveShiftAmount
            }
        }
        return enumerated().sorted(by: { shift($0.offset) < shift($1.offset) }).map { $0.element }
    }
}
