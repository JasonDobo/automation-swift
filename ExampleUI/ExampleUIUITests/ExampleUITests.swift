//
//  ExampleUIUITests.swift
//  ExampleUIUITests
//
//  Created by Jason Dobo on 08/07/2019.
//  Copyright © 2019 Jason Dobo. All rights reserved.
//

import XCTest

class ExampleUITests: BaseExampleTests {

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
        tryWait(for: firstButton, with: .enabled)

        let secondButton = XCUIApplication().staticTexts["First View"]
        wait(for: secondButton, with: .hittable)

        secondButton.tap()
        firstButton.tap()
        secondButton.tap()
        firstButton.tap()

         XCUIDevice().orientation = .portrait
    }
}
