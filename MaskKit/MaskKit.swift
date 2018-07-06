//
//  MaskKit.swift
//  MaskKit
//
//  Created by Сергей Мельников on 06.07.2018.
//  Copyright © 2018 Сергей Мельников. All rights reserved.
//

import Foundation

public class MaskKit {
    /// Вспомогательная структура хранящая информацию о парсинге маски
    typealias AuxiliaryStructureForParsing = (startIndex: Int, endIndex: Int, mask: String, currentValue: String)
    
    public init(_ mask: String, placeholderMask: Character = " ") {
        self.mask = mask
        self.placeholderMask = placeholderMask
    }
    
    public var mask: String
    public var placeholderMask: Character
    var auxiliaryStructure: [AuxiliaryStructureForParsing] = []
    
    public func getIndexFree() -> String.Index? {
        let text = getResultText()
        guard let index = text.index(of: placeholderMask) else { return nil }
        return index
    }
    
    /// Очищает существующую вспомогательную структуру, если она была и создает новую на основе маски
    public func clearAuxiliaryStructure() {
        do {
            let regExp = try NSRegularExpression(pattern: "\\[[0AUL\\*]{1,}\\]", options: [.dotMatchesLineSeparators])
            let checkingResult = regExp.matches(in: mask, options: [], range: NSMakeRange(0, mask.count))
            var result = Array.init(repeating: AuxiliaryStructureForParsing(0,0,"",""), count: checkingResult.count)
            checkingResult.enumerated().forEach {
                let start = $0.element.range.location
                let end = $0.element.range.length
                let startIndex = mask.index(mask.startIndex, offsetBy: start)
                let endIndex = mask.index(startIndex, offsetBy: end)
                let tmpMask = String(mask[startIndex..<endIndex])
                result[$0.offset] = AuxiliaryStructureForParsing(start,
                                                                 start + end,
                                                                 tmpMask,
                                                                 String(repeating: placeholderMask, count: tmpMask.count - 2))
                
            }
            auxiliaryStructure = result
        }
        catch {
            fatalError()
        }
    }
    
    /// Добавить текст в конец
    ///
    /// - Parameter text: Добавляемый текст
    public func addToEnd(_ text: String) {
        var tmpText = text
        for item in auxiliaryStructure.enumerated() where item.element.currentValue.contains(placeholderMask) {
            var newCurrentValue = item.element.currentValue
            var range = newCurrentValue.range(of: String(placeholderMask))
            while range != nil && tmpText.count > 0 {
                let tryIndex = item.element.mask.index(range!.lowerBound, offsetBy: 1)
                guard let newChapter = tmpText.first else { break }
                tmpText.remove(at: tmpText.startIndex)
                if reg(String(item.element.mask[tryIndex]), str: String(newChapter)) {
                    newCurrentValue.replaceSubrange(range!, with: String(newChapter))
                    range = newCurrentValue.range(of: String(placeholderMask))
                }
            }
            auxiliaryStructure[item.offset].currentValue = newCurrentValue
        }
    }
    
    public func addTo(_ index: String.Index, text: String) {
        var tmpText = text
        let countFreeCharapter = getCountFreeCharapter()
        let countRemove = countRemoveChapter(index)
        var tmp: [Character] = Array<Character>(repeating: "0", count: countRemove)
        for i in 0..<countRemove {
            guard let character = deleteLastCharacter() else { break }
            tmp[i] = character
        }
        let maxCharacters = countFreeCharapter > text.count ? text.count : countFreeCharapter
        for _ in 0..<maxCharacters {
            addToEnd(String(tmpText.removeFirst()))
        }
        while let character = tmp.popLast() {
            addToEnd(String(character))
        }
    }
    
    func countRemoveChapter(_ index: String.Index) -> Int {
        var countRemove = 0
        for item in auxiliaryStructure.enumerated() where index.encodedOffset < item.element.endIndex - item.offset * 2 - 2 {
            var currentIndex = index.encodedOffset - item.element.startIndex + item.offset * 2
            currentIndex = currentIndex > 0 ? currentIndex : 0
            if item.element.currentValue.contains(placeholderMask) {
                countRemove = item.element.currentValue.index(of: placeholderMask)!.encodedOffset - currentIndex
                return countRemove > 0 ? countRemove : 0
            }
            countRemove = item.element.currentValue.count - currentIndex
            for i in item.offset + 1 ..< auxiliaryStructure.count {
                if auxiliaryStructure[i].currentValue.contains(placeholderMask) {
                    countRemove += auxiliaryStructure[i].currentValue.index(of: placeholderMask)!.encodedOffset
                    break
                }
                countRemove += auxiliaryStructure[i].currentValue.count
            }
            break
        }
        return countRemove
    }
    
    @discardableResult
    public func deleteLastCharacter() -> Character? {
        var result: Character?
        for item in auxiliaryStructure.enumerated() where item.element.currentValue.contains(placeholderMask) {
            var newCurrentValue = item.element.currentValue
            guard let index = newCurrentValue.index(of: placeholderMask) else { fatalError() }
            if index == item.element.currentValue.startIndex && item.offset == 0 {
                return nil
            } else if index == item.element.currentValue.startIndex {
                newCurrentValue = auxiliaryStructure[item.offset - 1].currentValue
                result = newCurrentValue.removeLast()
                newCurrentValue.append(placeholderMask)
                auxiliaryStructure[item.offset - 1].currentValue = newCurrentValue
            } else {
                result = newCurrentValue[newCurrentValue.index(index, offsetBy: -1) ..< index].first
                newCurrentValue.replaceSubrange(newCurrentValue.index(index, offsetBy: -1) ..< index, with: String(placeholderMask))
                auxiliaryStructure[item.offset].currentValue = newCurrentValue
            }
            break
        }
        if result == nil {
            guard var newCurrentValue = auxiliaryStructure.last?.currentValue else { return result }
            result = newCurrentValue.removeLast()
            newCurrentValue.append(placeholderMask)
            auxiliaryStructure[auxiliaryStructure.count - 1].currentValue = newCurrentValue
        }
        return result
    }
    
    func getTryIndexForDelete(_ index: String.Index) -> String.Index? {
        var result: String.Index?
        for (offset, item) in auxiliaryStructure.enumerated() where item.endIndex - 2 * offset - 2 > index.encodedOffset {
            if item.startIndex - 2 * offset <= index.encodedOffset {
                result = index
                break
            } else {
                if offset > 0 {
                    result = getResultText().index(getResultText().startIndex, offsetBy: auxiliaryStructure[offset - 1].endIndex - 2 * (offset - 1) - 3)
                }
                break
            }
        }
        return result
    }
    
    @discardableResult
    public func delete(_ index: String.Index) -> Character? {
        var result: Character?
        guard let tryIndex = getTryIndexForDelete(index) else { return nil }
        let countRemove = countRemoveChapter(tryIndex)
        var tmp: [Character] = Array<Character>(repeating: "0", count: countRemove)
        for i in 0..<countRemove {
            guard let character = deleteLastCharacter() else { break }
            tmp[i] = character
        }
        result = tmp.popLast()
        while let character = tmp.popLast() {
            addToEnd(String(character))
        }
        return result
    }
    
    public func getResultText() -> String {
        var result = mask
        var offset = 0
        for item in auxiliaryStructure.enumerated() {
            let range = result.index(result.startIndex, offsetBy: item.element.startIndex - offset) ..< result.index(result.startIndex, offsetBy: item.element.endIndex - offset)
            result.replaceSubrange(range, with: item.element.currentValue)
            offset += 2
        }
        return result
    }
    
    // MARK: - Private
    private func reg(_ mask: String, str: String) -> Bool {
        switch mask {
        case "0":
            do {
                let regExp = try NSRegularExpression(pattern: "^[0-9]{1}$", options: [.dotMatchesLineSeparators])
                return regExp.matches(in: str, options: [], range: NSMakeRange(0, 1)).count > 0
            } catch {
                fatalError()
            }
        case "A":
            do {
                let regExp = try NSRegularExpression(pattern: "^[а-яА-ЯA-Za-z]{1}$", options: [.dotMatchesLineSeparators])
                return regExp.matches(in: str, options: [], range: NSMakeRange(0, 1)).count > 0
            } catch {
                fatalError()
            }
        case "U":
            do {
                let regExp = try NSRegularExpression(pattern: "^[А-ЯA-Z]{1}$", options: [.dotMatchesLineSeparators])
                return regExp.matches(in: str, options: [], range: NSMakeRange(0, 1)).count > 0
            } catch {
                fatalError()
            }
        case "L":
            do {
                let regExp = try NSRegularExpression(pattern: "^[а-яa-z]{1}$", options: [.dotMatchesLineSeparators])
                return regExp.matches(in: str, options: [], range: NSMakeRange(0, 1)).count > 0
            } catch {
                fatalError()
            }
        case "*":
            do {
                let regExp = try NSRegularExpression(pattern: "^.{1}$", options: [.dotMatchesLineSeparators])
                return regExp.matches(in: str, options: [], range: NSMakeRange(0, 1)).count > 0
            } catch {
                fatalError()
            }
        default:
            return false
        }
    }
    
    private func getCountFreeCharapter() -> Int {
        var countFreeCharapter = 0
        for item in auxiliaryStructure where item.currentValue.contains(placeholderMask) {
            for charapter in item.currentValue where charapter == placeholderMask{
                countFreeCharapter += 1
            }
        }
        return countFreeCharapter
    }
}
