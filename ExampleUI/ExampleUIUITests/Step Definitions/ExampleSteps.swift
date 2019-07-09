import XCTest
import XCTest_Gherkin

class ExampleSteps: StepDefiner {

    override func defineSteps() {

        step("I tap on the \"(Second|First)\" button") { (button: String) in
            switch button.lowercased() {
            case "first":
                FirstScreen().select()
            case "second":
                SecondScreen().select()
            default:
                XCTFail("Inavalid button \(button) specified")
            }

        }

        step("the second tab is displayed") {
            XCTAssertTrue(SecondScreen().isDisplayd())
        }

        step("the first tab is displayed") {
            XCTAssertTrue(FirstScreen().isDisplayd())
        }
    }
}
