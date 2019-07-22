import XCTest

class ScreenBase {

    enum Match {
        case contains(String)
        case beginsWith(String)
        case endsWith(String)
        case like(String)
        case regex(String)
        func predicate(forKeyPath keyPath: String = "label") -> NSPredicate {
            switch self {
            case .contains(let label): return NSPredicate(format: "\(keyPath) CONTAINS[c] %@", label)
            case .beginsWith(let label): return NSPredicate(format: "\(keyPath) BEGINSWITH[c] %@", label)
            case .endsWith(let label): return NSPredicate(format: "\(keyPath) ENDSWITH[c] %@", label)
            case .like(let label): return NSPredicate(format: "\(keyPath) LIKE[c] %@", label)
            case .regex(let format): return NSPredicate(format: "\(keyPath) MATCHES %@", format)
            }
        }
    }

    enum ElementState: String {
        case enabled = "enabled == true"
        case notenabled = "enabled == false"
        case exists = "exists == true"
        case notexists = "exists == false"
        case hittable = "hittable == true"
        case nothittable = "hittable == false"
        case selected = "selected == true"
        case notselected = "selected == false"
        case keyboardFocus = "hasKeyboardFocus == true"
        case count = "self.count >= "
    }

    enum KeyPath: String {
        case label
        case value
        case identifier
    }

    enum MatchingCountStratagey {
        case all
        case count(Int)
    }

    func runApp(for seconds: TimeInterval) {
        RunLoop.main.run(until: Date().addingTimeInterval(seconds))
    }

    @discardableResult
    func tryWait(for element: XCUIElement, with state: ElementState, waiting timeout: TimeInterval = 15.0) -> Bool {
        guard state != .exists else {
            return element.waitForExistence(timeout: timeout)
        }

        let myPredicate = NSPredicate(format: state.rawValue)
        let testcase = XCTestCase()

        let myExpectation = testcase.expectation(for: myPredicate, evaluatedWith: element, handler: nil)
        return XCTWaiter().wait(for: [myExpectation], timeout: timeout) ==  XCTWaiter.Result.completed
    }

    func wait(for element: XCUIElement, with state: ElementState, waiting timeout: TimeInterval = 15.0) {
        XCTAssertTrue(tryWait(for: element, with: state, waiting: timeout), "Wait for \(element.description) with \(state.rawValue) failed with timout \(timeout)s")
    }

    func findElement(using query: XCUIElementQuery, matching type: Match, for key: KeyPath = .label, timeout time: TimeInterval = 15.0) -> XCUIElement {
        let elementQuery = query.matching(type.predicate(forKeyPath: key.rawValue))

        XCTAssertTrue(waitFor(count: 1, of: elementQuery, timeout: time), "XCUIElementQuery failed query \(String(describing: type.predicate))")
        return elementQuery.firstMatch
    }

    @discardableResult
    func waitFor(count: Int, of query: XCUIElementQuery, timeout time: TimeInterval = 15.0) -> Bool {
        let count = NSPredicate(format: ElementState.count.rawValue + String(count))
        let testcase = XCTestCase()

        let myExpectation = testcase.expectation(for: count, evaluatedWith: query, handler: nil)
        return XCTWaiter().wait(for: [myExpectation], timeout: time) == XCTWaiter.Result.completed
    }

    func typeInto(element: XCUIElement, withText input: String, andState state: ElementState = .exists, waiting timeout: TimeInterval = 10.0) {
        waitAndTap(element: element, withState: state, waiting: timeout)
        element.typeText(input)
    }

    func typeAt(element: XCUIElement, withText input: String, andState state: ElementState = .exists, waiting timeout: TimeInterval = 10.0) {
        waitAndTap(element: element, withState: state, waiting: timeout)
        XCUIApplication().typeText(input)
    }

    func clearAndType(into element: XCUIElement, with input: String, and state: ElementState = .exists, waiting timeout: TimeInterval = 10.0) {
        waitAndTap(element: element, withState: state, waiting: timeout)
        element.clearAndType(text: input)
    }

    func waitAndTap(element: XCUIElement, withState state: ElementState, waiting timeout: TimeInterval = 10.0) {
        tryWait(for: element, with: state, waiting: timeout)
        element.tap()
    }

    @discardableResult
    func tryWaitForAll(elements: [XCUIElement], withState state: ElementState, with strategy: MatchingCountStratagey, timeout time: TimeInterval = 15.0, handler: (([XCUIElement]) -> Void)? = nil) -> Bool {
        let myPredicate = NSPredicate(format: state.rawValue)
        var matchedElements: [XCUIElement]?
        var allExpectations: [XCTNSPredicateExpectation] = []
        var elementsMatched: [XCUIElement] = []

        allExpectations = elements.enumerated().map { (_, element) in
            return XCTNSPredicateExpectation(predicate: myPredicate, object: element).with {
                $0.handler = {
                    if matchedElements != nil { return true }
                    elementsMatched.append(element)
                    switch strategy {
                    case .all:
                        if elementsMatched.count == elements.count {
                            matchedElements = elements
                            allExpectations.forEach { $0.fulfill() }
                        }
                    case let .count(count):
                        if elementsMatched.count == count {
                            matchedElements = elements
                            allExpectations.forEach { $0.fulfill() }
                        }
                    }
                    return true
                }
            }
        }

        let result = XCTWaiter().wait(for: allExpectations, timeout: time, enforceOrder: false)
        if let matchedElements = matchedElements {
            handler?(matchedElements)
        }
        return result == .completed
    }

    @discardableResult
    func tryWaitFor(elements: [XCUIElement], withState state: ElementState, timeout: TimeInterval = 15.0, handler: ((XCUIElement) -> Void)? = nil) -> Bool {
        let myPredicate = NSPredicate(format: state.rawValue)
        var matchedElement: XCUIElement?

        var allExpectations: [XCTNSPredicateExpectation]!

        allExpectations = elements.map { (element) -> XCTNSPredicateExpectation in
            return XCTNSPredicateExpectation(predicate: myPredicate, object: element).with {
                $0.handler = {
                    if matchedElement != nil { return true }
                    matchedElement = element
                    allExpectations.forEach { $0.fulfill() }
                    return true
                }
            }
        }

        let result = XCTWaiter().wait(for: allExpectations, timeout: timeout, enforceOrder: false)
        if let matchedElement = matchedElement {
            handler?(matchedElement)
        }
        return result == .completed
    }
}

extension XCUIElement {
    func forceTap() {
        if self.isHittable {
            self.tap()
        } else {
            let coordinate: XCUICoordinate = self.coordinate(withNormalizedOffset: .zero)
            coordinate.tap()
        }
    }

    func clearAndType(text: String) {
        self.deleteText()
        self.typeText(text)
    }

    private func deleteText() {
        guard let stringValue = self.value as? String else {
            return
        }

        if let placeholderString = self.placeholderValue, placeholderString == stringValue {
            return
        }

        let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: stringValue.count)
        self.typeText(deleteString)
    }
}

extension NSObject : With {
}

/// Copied from https://github.com/devxoul/Then

public protocol With {}

extension With where Self: Any {
    /// Makes it available to set properties with closures just after initializing and copying the value types.
    ///
    ///     let label = UILabel().with {
    ///       $0.textAlignment = .center
    ///       $0.textColor = .black
    ///       $0.text = "Hello, World!"
    ///     }
    ///
    ///     let frame = CGRect().with {
    ///       $0.origin.x = 10
    ///       $0.size.width = 100
    ///     }
    @discardableResult public func with(_ block: (inout Self) throws -> Void) rethrows -> Self {
        var copy = self
        try block(&copy)
        return copy
    }

    /// Makes it available to execute something with closures.
    ///
    ///     UserDefaults.standard.do {
    ///       $0.set("jon", forKey: "username")
    ///       $0.set("jonsnow@westeros.com", forKey: "email")
    ///       $0.synchronize()
    ///     }
    public func `do`(_ block: (Self) throws -> Void) rethrows {
        try block(self)
    }
}
