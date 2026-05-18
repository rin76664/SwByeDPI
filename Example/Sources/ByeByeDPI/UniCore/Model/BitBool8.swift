//
//  BitBool8.swift
//  SwByeDPI
//
//  Created by Developer on 01.03.2026.
//

import Foundation

class BitBool8: Codable, ObservableObject
{
    @Published fileprivate var _bits: UInt8 = 0
    
    func setFlagPropertyValue(for index: Int, value: Bool)
    {
        var bit: UInt8 = 1
        if (index > 0)
        {
            for _ in 1 ... index
            {
                bit *= 2
            }
        }
        if (value == true)
        {
            _bits |= bit
        }
        else
        {
            bit = ~bit
            _bits &= bit
        }
    }
    
    func getFlagPropertyValue(for index: Int) -> Bool
    {
        let val = _bits >> index
        return val % 2 == 1
    }
    
    init(initVal: UInt8)
    {
        _bits = initVal
    }
}
