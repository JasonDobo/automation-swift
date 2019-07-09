import XCTest

class SecondScreen: ScreenBase {

    private enum StaticText {
        static let title = "Second View"
    }

    private enum Button {
        static let tab = "Second"
    }

    func isDisplayd() -> Bool {
        let pageHeading = XCUIApplication().staticTexts[StaticText.title]
        return tryWait(for: pageHeading, with: .exists)
    }

    func select() {
        let tabBarsQuery = XCUIApplication().tabBars
        waitAndTap(element: tabBarsQuery.buttons[Button.tab], withState: .enabled)
    }
}
