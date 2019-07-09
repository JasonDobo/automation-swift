import XCTest
import XCTest_Gherkin

class ExampleGherkinTest: BaseExampleTests {

    override func setUp() {
        continueAfterFailure = false
        XCUIApplication().launch()
    }

    func testGherkin() {
        Given("the first tab is displayed")
        When("I tap on the \"Second\" button")
        Then("the second tab is displayed")
        When("I tap on the \"First\" button")
        Then("the first tab is displayed")
    }
}
