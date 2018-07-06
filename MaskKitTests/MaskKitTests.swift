//
//  MaskKitTests.swift
//  MaskKitTests
//
//  Created by Сергей Мельников on 06.07.2018.
//  Copyright © 2018 Сергей Мельников. All rights reserved.
//

import XCTest
@testable import MaskKit

class MaskKitTests: XCTestCase {
    
    var mask: MaskKit!
    var longlongMask =
        "7 [0] [00] [000] [0000] [00000] [0000] [000] [00] [0] [0] [00] [000] [0000] [00000] [0000] [000] [00] [0]" +
            "[0] [00] [000] [0000] [00000] [0000] [000] [00] [0][0] [00] [000] [0000] [00000] [0000] [000] [00] [0]" +
            "[0] [00] [000] [0000] [00000] [0000] [000] [00] [0][0] [00] [000] [0000] [00000] [0000] [000] [00] [0]" +
            "[0] [00] [000] [0000] [00000] [0000] [000] [00] [0][0] [00] [000] [0000] [00000] [0000] [000] [00] [0]" +
            "[0] [00] [000] [0000] [00000] [0000] [000] [00] [0][0] [00] [000] [0000] [00000] [0000] [000] [00] [0]" +
    "[0] [00] [000] [0000] [00000] [0000] [000] [00] [0][0] [00] [000] [0000] [00000] [0000] [000] [00] [0]"
    override func setUp() {
        super.setUp()
        mask = MaskKit("+7 [000] [000] [00] [00]", placeholderMask: "_")
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testclearAuxiliaryStructure() {
        mask.clearAuxiliaryStructure()
        for error in mask.auxiliaryStructure.enumerated() {
            switch error.offset {
            case 0:
                XCTAssert(error.element.currentValue == "___", "CurrentValue = \(error.element.currentValue)")
                XCTAssert(error.element.startIndex == 3, "StartIndex = \(error.element.startIndex)")
                XCTAssert(error.element.endIndex == 8, "EndIndex = \(error.element.endIndex)")
                XCTAssert(error.element.mask == "[000]", "Mask = \(error.element.mask)")
            case 1:
                XCTAssert(error.element.currentValue == "___", "CurrentValue = \(error.element.currentValue)")
                XCTAssert(error.element.startIndex == 9, "StartIndex = \(error.element.startIndex)")
                XCTAssert(error.element.endIndex == 14, "EndIndex = \(error.element.endIndex)")
                XCTAssert(error.element.mask == "[000]", "Mask = \(error.element.mask)")
            case 2:
                XCTAssert(error.element.currentValue == "__", "CurrentValue = \(error.element.currentValue)")
                XCTAssert(error.element.startIndex == 15, "StartIndex = \(error.element.startIndex)")
                XCTAssert(error.element.endIndex == 19, "EndIndex = \(error.element.endIndex)")
                XCTAssert(error.element.mask == "[00]", "Mask = \(error.element.mask)")
            case 3:
                XCTAssert(error.element.currentValue == "__", "CurrentValue = \(error.element.currentValue)")
                XCTAssert(error.element.startIndex == 20, "StartIndex = \(error.element.startIndex)")
                XCTAssert(error.element.endIndex == 24, "EndIndex = \(error.element.endIndex)")
                XCTAssert(error.element.mask == "[00]", "Mask = \(error.element.mask)")
            default:
                XCTAssert(false)
            }
        }
        
        mask.mask = "+7 "
        mask.clearAuxiliaryStructure()
        XCTAssert(mask.auxiliaryStructure.count == 0, "Count helpElement = \(mask.auxiliaryStructure.count)")
        
        mask.mask = "+7 [000] [000] [00] [00"
        mask.clearAuxiliaryStructure()
        XCTAssert(mask.auxiliaryStructure.count == 3, "Count helpElement = \(mask.auxiliaryStructure.count)")
        
        mask.placeholderMask = " "
        mask.clearAuxiliaryStructure()
        XCTAssert(mask.getResultText() == "+7            [00", "mask.getResultText() = \(mask.getResultText())")
        mask.placeholderMask = "_"
        
        mask.mask = "[AAA] [AA]"
        mask.clearAuxiliaryStructure()
        for error in mask.auxiliaryStructure.enumerated() {
            switch error.offset {
            case 0:
                XCTAssert(error.element.currentValue == "___", "CurrentValue = \(error.element.currentValue)")
                XCTAssert(error.element.startIndex == 0, "StartIndex = \(error.element.startIndex)")
                XCTAssert(error.element.endIndex == 5, "EndIndex = \(error.element.endIndex)")
                XCTAssert(error.element.mask == "[AAA]", "Mask = \(error.element.mask)")
            case 1:
                XCTAssert(error.element.currentValue == "__", "CurrentValue = \(error.element.currentValue)")
                XCTAssert(error.element.startIndex == 6, "StartIndex = \(error.element.startIndex)")
                XCTAssert(error.element.endIndex == 10, "EndIndex = \(error.element.endIndex)")
                XCTAssert(error.element.mask == "[AA]", "Mask = \(error.element.mask)")
            default:
                XCTAssert(false)
            }
        }
    }
    
    func testGetNewText() {
        mask.placeholderMask = "+"
        mask.clearAuxiliaryStructure()
        let tmp = mask.getResultText()
        XCTAssert(tmp == "+7 +++ +++ ++ ++", "NewText - \(tmp)")
    }
    
    func testaddToEndString() {
        mask.clearAuxiliaryStructure()
        var result = ""
        mask.addToEnd("999")
        result = mask.getResultText()
        XCTAssert(result == "+7 999 ___ __ __", "result = \(result)")
        
        mask.addToEnd("8")
        result = mask.getResultText()
        XCTAssert(result == "+7 999 8__ __ __", "result = \(result)")
        
        mask.addToEnd("403")
        result = mask.getResultText()
        XCTAssert(result == "+7 999 840 3_ __", "result = \(result)")
        
        mask.addToEnd("026")
        result = mask.getResultText()
        XCTAssert(result == "+7 999 840 30 26", "result = \(result)")
        
        mask.addToEnd("8")
        result = mask.getResultText()
        XCTAssert(result == "+7 999 840 30 26", "result = \(result)")
        
        mask.clearAuxiliaryStructure()
        mask.addToEnd("99984030267")
        XCTAssert(mask.getResultText() == "+7 999 840 30 26", "result = \(mask.getResultText())")
        
        mask.clearAuxiliaryStructure()
        mask.addToEnd("A")
        XCTAssert(mask.getResultText() == "+7 ___ ___ __ __", "result = \(mask.getResultText())")
        
        mask.mask = "[AA]"
        mask.clearAuxiliaryStructure()
        mask.addToEnd("1")
        XCTAssert(mask.getResultText() == "__", "result = \(mask.getResultText())")
        
        mask.mask = "[aa]"
        mask.clearAuxiliaryStructure()
        mask.addToEnd("EMP")
        XCTAssert(mask.getResultText() == "[aa]", "result = \(mask.getResultText())")
        
        mask.mask = "[UU]"
        mask.clearAuxiliaryStructure()
        mask.addToEnd("Emp")
        XCTAssert(mask.getResultText() == "E_", "result = \(mask.getResultText())")
        
        mask.mask = "[UU]"
        mask.clearAuxiliaryStructure()
        mask.addToEnd("EmP")
        XCTAssert(mask.getResultText() == "EP", "result = \(mask.getResultText())")
        
        mask.mask = "[LL]"
        mask.clearAuxiliaryStructure()
        mask.addToEnd("Emp")
        XCTAssert(mask.getResultText() == "mp", "result = \(mask.getResultText())")
        
        mask.mask = "[LL]"
        mask.clearAuxiliaryStructure()
        mask.addToEnd("eMp")
        XCTAssert(mask.getResultText() == "ep", "result = \(mask.getResultText())")
        
        mask.mask = "[***]"
        mask.clearAuxiliaryStructure()
        mask.addToEnd("3mp")
        XCTAssert(mask.getResultText() == "3mp", "result = \(mask.getResultText())")
        
        mask.mask = "[***]"
        mask.clearAuxiliaryStructure()
        mask.addToEnd("_24")
        XCTAssert(mask.getResultText() == "24_", "result = \(mask.getResultText())")
        
        mask.mask = "[0ULA*]"
        mask.clearAuxiliaryStructure()
        mask.addToEnd("1EmP❤️")
        XCTAssert(mask.getResultText() == "1EmP❤️", "result = \(mask.getResultText())")
        
        mask.mask = "[0ULA*]"
        mask.clearAuxiliaryStructure()
        mask.addToEnd("AEmP❤️")
        XCTAssert(mask.getResultText() == "_____", "result = \(mask.getResultText())")
        
        mask.mask = "+[0] 999 [000]_[00]_[00]"
        mask.clearAuxiliaryStructure()
        mask.addToEnd("7")
        XCTAssert(mask.getResultText() == "+7 999 _________", "result = \(mask.getResultText())")
        mask.addToEnd("8")
        XCTAssert(mask.getResultText() == "+7 999 8________", "result = \(mask.getResultText())")
        mask.addToEnd("403")
        XCTAssert(mask.getResultText() == "+7 999 840_3____", "result = \(mask.getResultText())")
        
    }
    
    func testCountRemove() {
        mask.clearAuxiliaryStructure()
        mask.addToEnd("9998403026")
        var text = mask.getResultText()
        var result = mask.countRemoveChapter(text.index(text.startIndex, offsetBy: 1))
        XCTAssert(result == 10, "Result = \(result)")
        
        result = mask.countRemoveChapter(text.index(text.startIndex, offsetBy: 3))
        XCTAssert(result == 10, "Result = \(result)")
        
        result = mask.countRemoveChapter(text.index(text.startIndex, offsetBy: 4))
        XCTAssert(result == 9, "Result = \(result)")
        
        result = mask.countRemoveChapter(text.index(text.startIndex, offsetBy: 6))
        XCTAssert(result == 7, "Result = \(result)")
        
        result = mask.countRemoveChapter(text.index(text.startIndex, offsetBy: 7))
        XCTAssert(result == 7, "Result = \(result)")
        
        result = mask.countRemoveChapter(text.endIndex)
        XCTAssert(result == 0, "Result = \(result)")
        
        mask.clearAuxiliaryStructure()
        mask.addToEnd("999")
        text = mask.getResultText()
        result = mask.countRemoveChapter(text.startIndex)
        XCTAssert(result == 3, "Result = \(result)")
        
        mask.mask = "-[0]-[00]"
        mask.clearAuxiliaryStructure()
        mask.addToEnd("87")
        text = mask.getResultText()
        result = mask.countRemoveChapter(text.index(text.startIndex, offsetBy: 2))
        XCTAssert(result == 1, "Result = \(result)")
    }
    
    func testAddToIndex() {
        mask.clearAuxiliaryStructure()
        mask.addToEnd("998403026")
        var result = mask.getResultText()
        XCTAssert(result == "+7 998 403 02 6_", "result = \(result)")
        
        mask.addTo(result.index(result.startIndex, offsetBy: 3), text: "99")
        result = mask.getResultText()
        XCTAssert(result == "+7 999 840 30 26", "result = \(result)")
        
        mask.clearAuxiliaryStructure()
        mask.addToEnd("998403026")
        result = mask.getResultText()
        XCTAssert(result == "+7 998 403 02 6_", "result = \(result)")
        
        mask.addTo(result.startIndex, text: "99")
        result = mask.getResultText()
        XCTAssert(result == "+7 999 840 30 26", "result = \(result)")
        
        mask.clearAuxiliaryStructure()
        mask.addToEnd("998403026")
        result = mask.getResultText()
        XCTAssert(result == "+7 998 403 02 6_", "result = \(result)")
        
        mask.addTo(result.endIndex, text: "99")
        result = mask.getResultText()
        XCTAssert(result == "+7 998 403 02 69", "result = \(result)")
        
    }
    
    func testDeleteLastCharacter() {
        mask.clearAuxiliaryStructure()
        mask.addToEnd("999")
        var result = mask.getResultText()
        XCTAssert(result == "+7 999 ___ __ __", "result = \(result)")
        
        _ = mask.deleteLastCharacter()
        result = mask.getResultText()
        XCTAssert(result == "+7 99_ ___ __ __", "result = \(result)")
        
        mask.addToEnd("99")
        result = mask.getResultText()
        XCTAssert(result == "+7 999 9__ __ __", "result = \(result)")
        
        _ = mask.deleteLastCharacter()
        result = mask.getResultText()
        XCTAssert(result == "+7 999 ___ __ __", "result = \(result)")
        
        mask.deleteLastCharacter()
        result = mask.getResultText()
        XCTAssert(result == "+7 99_ ___ __ __", "result = \(result)")
        
        mask.deleteLastCharacter()
        result = mask.getResultText()
        XCTAssert(result == "+7 9__ ___ __ __", "result = \(result)")
        
        mask.deleteLastCharacter()
        result = mask.getResultText()
        XCTAssert(result == "+7 ___ ___ __ __", "result = \(result)")
        
        mask.deleteLastCharacter()
        result = mask.getResultText()
        XCTAssert(result == "+7 ___ ___ __ __", "result = \(result)")
        
        mask.mask = "+[0] 999 [000]_[00]_[00]"
        mask.clearAuxiliaryStructure()
        mask.addToEnd("78403")
        XCTAssert(mask.getResultText() == "+7 999 840_3____", "result = \(mask.getResultText())")
        mask.deleteLastCharacter()
        XCTAssert(mask.getResultText() == "+7 999 840______", "result = \(mask.getResultText())")
        mask.deleteLastCharacter()
        XCTAssert(mask.getResultText() == "+7 999 84_______", "result = \(mask.getResultText())")
        mask.deleteLastCharacter()
        XCTAssert(mask.getResultText() == "+7 999 8________", "result = \(mask.getResultText())")
        mask.deleteLastCharacter()
        XCTAssert(mask.getResultText() == "+7 999 _________", "result = \(mask.getResultText())")
        mask.deleteLastCharacter()
        XCTAssert(mask.getResultText() == "+_ 999 _________", "result = \(mask.getResultText())")
        
        mask.mask = "-[0]-[00]"
        mask.clearAuxiliaryStructure()
        mask.addToEnd("987")
        mask.deleteLastCharacter()
        result = mask.getResultText()
        XCTAssert(result == "-9-8_", "result = \(result)")
        
    }
    
    func testDeleteChapter() {
        var result: String
        
        mask.mask = "-[0]-[00]"
        mask.clearAuxiliaryStructure()
        mask.addToEnd("987")
        result = mask.getResultText()
        XCTAssert(result == "-9-87", "result = \(result)")
        mask.delete(result.startIndex)
        XCTAssert(result == "-9-87", "result = \(result)")
        
        mask.mask = "-[0]-[00]"
        mask.clearAuxiliaryStructure()
        mask.addToEnd("987")
        result = mask.getResultText()
        XCTAssert(result == "-9-87", "result = \(result)")
        mask.delete(result.index(result.startIndex, offsetBy: 1))
        result = mask.getResultText()
        XCTAssert(result == "-8-7_", "result = \(result)")
        
        mask.mask = "-[0]-[00]"
        mask.clearAuxiliaryStructure()
        mask.addToEnd("987")
        result = mask.getResultText()
        XCTAssert(result == "-9-87", "result = \(result)")
        mask.delete(result.index(result.startIndex, offsetBy: 2))
        result = mask.getResultText()
        XCTAssert(result == "-8-7_", "result = \(result)")
        
        mask.mask = "-[0]-[00]"
        mask.clearAuxiliaryStructure()
        mask.addToEnd("987")
        result = mask.getResultText()
        XCTAssert(result == "-9-87", "result = \(result)")
        mask.delete(result.index(result.startIndex, offsetBy: 3))
        result = mask.getResultText()
        XCTAssert(result == "-9-7_", "result = \(result)")
        
        mask.mask = "-[0]-[00]"
        mask.clearAuxiliaryStructure()
        mask.addToEnd("987")
        result = mask.getResultText()
        XCTAssert(result == "-9-87", "result = \(result)")
        mask.delete(result.index(result.startIndex, offsetBy: 4))
        result = mask.getResultText()
        XCTAssert(result == "-9-8_", "result = \(result)")
    }
    
    func testGetIndex() {
        mask.mask = "-[0]-[00]"
        mask.clearAuxiliaryStructure()
        mask.addToEnd("987")
        var text = mask.getResultText()
        var result: String.Index?
        result = mask.getTryIndexForDelete(text.startIndex)
        XCTAssert(result == nil, "Result = \(result!.encodedOffset)")
        
        result = mask.getTryIndexForDelete(text.index(text.startIndex, offsetBy: 1))
        XCTAssert(result?.encodedOffset == 1, "Result = \(result?.encodedOffset ?? -1)")
        
        result = mask.getTryIndexForDelete(text.index(text.startIndex, offsetBy: 2))
        XCTAssert(result?.encodedOffset == 1, "Result = \(result?.encodedOffset ?? -1)")
        
        result = mask.getTryIndexForDelete(text.index(text.startIndex, offsetBy: 3))
        XCTAssert(result?.encodedOffset == 3, "Result = \(result?.encodedOffset ?? -1)")
        
        result = mask.getTryIndexForDelete(text.index(text.startIndex, offsetBy: 4))
        XCTAssert(result?.encodedOffset == 4, "Result = \(result?.encodedOffset ?? -1)")
        
        mask.mask = "-[0]-[00]-[0]"
        mask.clearAuxiliaryStructure()
        mask.addToEnd("9876")
        text = mask.getResultText()
        result = mask.getTryIndexForDelete(text.index(text.startIndex, offsetBy: 6))
        XCTAssert(result?.encodedOffset == 6, "Result = \(result?.encodedOffset ?? -1)")
    }
    
    func testGetIndexLastCharapter() {
        var result = 0
        mask.mask = "-[0]-[00]-"
        mask.clearAuxiliaryStructure()
        
        result = mask.getIndexFree()?.encodedOffset ?? -1
        XCTAssert(result == 1, "Result = \(result)")
        
        mask.addToEnd("1")
        result = mask.getIndexFree()?.encodedOffset ?? -1
        XCTAssert(result == 3, "Result = \(result)")
        
        mask.addToEnd("1")
        result = mask.getIndexFree()?.encodedOffset ?? -1
        XCTAssert(result == 4, "Result = \(result)")
        
        mask.addToEnd("1")
        result = mask.getIndexFree()?.encodedOffset ?? -1
        XCTAssert(result == -1, "Result = \(result)")
    }
    
    func testPerformanceClearAuxiliaryStructure() {
        mask.mask = longlongMask
        mask.clearAuxiliaryStructure()
        self.measure {
            mask.clearAuxiliaryStructure()
        }
    }
    
    func testPerformanceGetResultText() {
        mask.mask = longlongMask
        mask.clearAuxiliaryStructure()
        self.measure {
            _ = mask.getResultText()
        }
    }
    
    func testPerformanceDeleteLastElement() {
        mask.mask = longlongMask
        mask.clearAuxiliaryStructure()
        mask.addToEnd("1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890")
        self.measure {
            for _ in 0..<10 {
                mask.deleteLastCharacter()
            }
        }
    }
    
    func testPerformanceAddToIndex() {
        mask.mask = longlongMask
        mask.clearAuxiliaryStructure()
        mask.addToEnd("12345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890")
        let text = mask.getResultText()
        self.measure {
            mask.addTo(text.index(text.startIndex, offsetBy: 5), text: "3445")
        }
    }
    
}
