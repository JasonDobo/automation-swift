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
