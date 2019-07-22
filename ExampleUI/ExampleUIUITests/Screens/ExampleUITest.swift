import XCTest

class ExampleUITest: BaseExampleTests {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        let tabBarsQuery = XCUIApplication().tabBars
        tryWait(for: tabBarsQuery.buttons["Second"], with: .exists)

        let firstButton = tabBarsQuery.buttons["First"]
        let secondButton = tabBarsQuery.buttons["Second"]
        tryWait(for: firstButton, with: .enabled)

        let title = XCUIApplication().staticTexts["First View"]
        wait(for: title, with: .hittable)

        secondButton.tap()
        firstButton.tap()
        secondButton.tap()
        firstButton.tap()
        tryWaitForAll(elements: [firstButton, secondButton], withState: .exists, with: .all)

        XCUIDevice.shared.orientation = .portrait
    }
}
