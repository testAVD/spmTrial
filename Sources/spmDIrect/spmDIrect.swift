import UIKit
import Foundation

public func testString(){
    print("Accessible to all script")
}
public extension String {
    var isEmail: Bool {
        let dataDetector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)

        let firstMatch = dataDetector?.firstMatch(in: self, options: NSRegularExpression.MatchingOptions.reportCompletion, range: NSRange(location: 0, length: self.count))

        return (firstMatch?.range.location != NSNotFound && firstMatch?.url?.scheme == "mailto")
    }
    var htmlToAttributedString: NSMutableAttributedString? {
        guard let data = data(using: .utf8) else { return nil }
        do {
            return try NSMutableAttributedString(data: data,
                                                 options: [.documentType: NSMutableAttributedString.DocumentType.html,
                                                           .characterEncoding: String.Encoding.utf8.rawValue],
                                                 documentAttributes: nil)
        } catch _ as NSError {
            return  nil
        }
    }
    // retun localised string
    var localisedString: String {
        return NSLocalizedString(self, comment: "")
    }
    
    var decodeEmoji: String {
        let data = self.data(using: String.Encoding.utf8)
        let decodedStr = NSString(data: data!, encoding: String.Encoding.nonLossyASCII.rawValue)
        if let str = decodedStr {
            return str as String
        }
        return self
    }
    // message to the server
    var encodeEmoji: String {
        if let encodeStr = NSString(cString: self.cString(using: .nonLossyASCII)!, encoding: String.Encoding.utf8.rawValue) {
            return encodeStr as String
        }
        return self
    }
    
    // for convert json
    func toJSON() -> Any? {
        guard let data = self.data(using: .utf8, allowLossyConversion: false) else { return nil }
        return try? JSONSerialization.jsonObject(with: data, options: .mutableContainers)
    }
    
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        
        return ceil(boundingBox.height)
    }
    
    func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        
        return ceil(boundingBox.width)
    }
    
    func lines(font: UIFont, width: CGFloat) -> Int {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        return Int(boundingBox.height / font.lineHeight)
    }
    
    func stringByStrippingHTML() -> String {
        return self.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
    }
    
    func isEmpty() -> Bool {
        let trimmed = self.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        return trimmed.isEmpty
    }
    
    func boolValue() -> Bool {
        if self.isEmpty() {
            return false
        }
        switch self {
        case "True", "true", "yes", "1", "Y", "y":
            return true
        case "False", "false", "no", "0":
            return false
        default:
            return false
        }
    }
    
//    func integerValue() -> Int {
//        if let doubleValue = Double(self) {
//            return doubleValue.isInt ? Int(ceil(doubleValue)) : 0
//        }
//        return 0
//    }
    
    func doubleValue() -> Double {
        if let doubleValue = Double(self) {
            return doubleValue
        }
        return 0.0
    }
    
    func floatValues() -> Float {
        let stringValue = self
        
        if let doubleValue = Float(stringValue.replacingOccurrences(of: ",", with: "")) {
            let divisor = pow(10.0, Float(2))
            return (doubleValue * divisor).rounded() / divisor
        }
        return 0.0
    }
    
    func poundValues() -> Float {
        if let doubleValue = Float(self) {
            return doubleValue
        }
        return 0.0
    }
    
    func isImage() -> Bool {
        // Add here your image formats.
        let imageFormats = ["jpg", "jpeg", "png", "gif"]
        
        if let ext = self.getExtension() {
            return imageFormats.contains(ext)
        }
        
        return false
    }
    
    func getExtension() -> String? {
        let ext = (self as NSString).pathExtension
        if ext.isEmpty {
            return nil
        }
        
        return ext
    }
    
    func generatePDF417Barcode() -> UIImage? {
        let data = self.data(using: String.Encoding.ascii)
        
        if let filter = CIFilter(name: "CIPDF417BarcodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 3, y: 3)
            
            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }
        
        return nil
    }
    
    func isURL() -> Bool {
        return URL(string: self) != nil
    }
    
    func UTCToLocal() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        guard let dt = dateFormatter.date(from: self) else { return "00/00/0000" }
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = "dd/MM/yyyy hh:mm a"
        return dateFormatter.string(from: dt)
    }
    
    func rightJustified(width: Int, truncate: Bool = false) -> String {
        guard width > count else {
            return truncate ? String(suffix(width)) : self
        }
        return String(repeating: " ", count: width - count) + self
    }
    
    func leftJustified(width: Int, truncate: Bool = false) -> String {
        guard width > count else {
            return truncate ? String(prefix(width)) : self
        }
        return self + String(repeating: " ", count: width - count)
    }
    
    func isNumberOnly() -> Bool {
        if self.isEmpty {
            return !self.isEmpty
        }
        let aSet = NSCharacterSet(charactersIn: "0123456789").inverted
        let compSepByCharInSet = self.components(separatedBy: aSet)
        let numberFiltered = compSepByCharInSet.joined(separator: "")
        return self == numberFiltered
    }
    
    func isStringOnly(spaceAllow: Bool) -> Bool {
        if self.isEmpty {
            return !self.isEmpty
        }
        do {
            let space = (spaceAllow == true) ? " " : ""
            let regex = try NSRegularExpression(pattern: ".*[^A-Za-z\(space)].*", options: [])
            if regex.firstMatch(in: self, options: [], range: NSRange(location: 0, length: self.count)) != nil {
                return false
            } else {
                return true
            }
        } catch {
            return false
        }
    }
    
    func isStrongPassword() -> Bool {
        var lowerCaseLetter: Bool = false
        var upperCaseLetter: Bool = false
        var digit: Bool = false
        var specialCharacter: Bool = false
        
        if self.count >= 8 {
            for char in self.unicodeScalars {
                if !lowerCaseLetter {
                    lowerCaseLetter = CharacterSet.lowercaseLetters.contains(char)
                }
                if !upperCaseLetter {
                    upperCaseLetter = CharacterSet.uppercaseLetters.contains(char)
                }
                if !digit {
                    digit = CharacterSet.decimalDigits.contains(char)
                }
                if !specialCharacter {
                    specialCharacter = CharacterSet.punctuationCharacters.contains(char)
                }
            }
            if specialCharacter || (digit && lowerCaseLetter && upperCaseLetter) {
                return true
            } else {
                return false
            }
        }
        return false
    }
    
    func date(format: String, timeZone: TimeZone = .current) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.timeZone = timeZone
        let date = dateFormatter.date(from: self)
        return date
    }
    
    func UTCdate(format: String, timeZone: TimeZone = TimeZone(abbreviation: "UTC") ?? .current) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.timeZone = timeZone
        let date = dateFormatter.date(from: self)
        return date
    }
    
//    func convertDateString(currentFormat: String, currentTimeZone: TimeZone  = .current, extepectedFormat: String, expectedTimeZone: TimeZone = .current) -> String {
//        return self.date(format: currentFormat, timeZone: currentTimeZone)?.dateString(format: extepectedFormat, timeZone: expectedTimeZone) ?? self
//    }
    
//    func currentTimeFromUTC(currentFormat: String, extepectedFormat: String) -> String {
//        return self.convertDateString(currentFormat: currentFormat, currentTimeZone: TimeZone(abbreviation: "UTC") ?? .current, extepectedFormat: extepectedFormat) // expected default
//    }
    
    func getAttributedTextWithLineOfHeight(_ height: CGFloat) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: self)
        
        // *** Create instance of `NSMutableParagraphStyle`
        let paragraphStyle = NSMutableParagraphStyle()
        
        // *** Set Alignment Center ***
        paragraphStyle.alignment = .center
        
        // *** set LineSpacing property in points ***
        paragraphStyle.lineSpacing = 2 // Whatever line spacing you want in points
        
        // *** Apply attribute to string ***
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedString.length))
        
        // *** Final Attributed String ***
        
        return attributedString
    }
    
    func isValidDecimal() -> Bool {
        let regex1: String = "^\\d+(\\.\\d{1,2})?$"
        let test1: NSPredicate = NSPredicate.init(format: "SELF MATCHES %@", regex1)
        return test1.evaluate(with: self)
    }
    
//    func findDateDiff(secondDate: String, currentForamt: String = "hh:mm a", expectedFormat: String = "hh:mm a") -> String {
//        let timeformatter = DateFormatter()
//        timeformatter.dateFormat = currentForamt
//
//        guard // let time1 = timeformatter.date(from: self),
//            let time2 = timeformatter.date(from: secondDate) else { return "" }
//
//        //You can directly use from here if you have two dates
//
//        // let interval = time2.timeIntervalSince(time1)
//        //        let hour = interval / 3600;
//        //        let minute = interval.truncatingRemainder(dividingBy: 3600) / 60
//        //        let intervalInt = Int(interval)
//        return time2.dateString(format: expectedFormat) ?? ""
//    }
    
    func isValidEmail() -> Bool {
        let regex1: String = "\\A[A-Za-z0-9]+([-._][a-z0-9]+)*@([a-z0-9]+(-[a-z0-9]+)*\\.)+[a-z]{2,64}\\z"
        let regex2: String = "^(?=.{1,64}@.{4,64}$)(?=.{6,100}$).*"
        let test1: NSPredicate = NSPredicate.init(format: "SELF MATCHES %@", regex1)
        let test2: NSPredicate = NSPredicate.init(format: "SELF MATCHES %@", regex2)
        return test1.evaluate(with: self) && test2.evaluate(with: self)
    }
    
    func strikeThrough() -> NSAttributedString {
        let attributeString = NSMutableAttributedString(string: self)
        attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(location: 0, length: attributeString.length))
        return attributeString
    }

      func startsWith(string: String) -> Bool {
         guard let range = range(of: string, options: [.caseInsensitive]) else {
               return false
           }
        return range.lowerBound == startIndex
      }

    func substring(from: Int?, to: Int?) -> String {
        if let start = from {
            guard start < self.count else {
                return ""
            }
        }
        
        if let end = to {
            guard end >= 0 else {
                return ""
            }
        }
        
        if let start = from, let end = to {
            guard end - start >= 0 else {
                return ""
            }
        }
        
        let startIndex: String.Index
        if let start = from, start >= 0 {
            startIndex = self.index(self.startIndex, offsetBy: start)
        } else {
            startIndex = self.startIndex
        }
        
        let endIndex: String.Index
        if let end = to, end >= 0, end < self.count {
            endIndex = self.index(self.startIndex, offsetBy: end + 1)
        } else {
            endIndex = self.endIndex
        }
        
        return String(self[startIndex ..< endIndex])
    }
    
    func substring(from: Int) -> String {
        return self.substring(from: from, to: nil)
    }
    
    func substring(to: Int) -> String {
        return self.substring(from: nil, to: to)
    }
    
    func substring(from: Int?, length: Int) -> String {
        guard length > 0 else {
            return ""
        }
        
        let end: Int
        if let start = from, start > 0 {
            end = start + length - 1
        } else {
            end = length - 1
        }
        
        return self.substring(from: from, to: end)
    }
    
    func substring(length: Int, to: Int?) -> String {
        guard let end = to, end > 0, length > 0 else {
            return ""
        }
        
        let start: Int
        if let end = to, end - length > 0 {
            start = end - length + 1
        } else {
            start = 0
        }
        
        return self.substring(from: start, to: to)
    }
}
