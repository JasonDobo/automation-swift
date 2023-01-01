#target 'ExampleUIUITests' do
#  project 'ExampleUI/ExampleUI.xcodeproj'
#  use_frameworks!
#
#  target 'xcuitest-exampleUITests' do
#    # Pods for testing
#    pod 'XCTest-Gherkin'
#  end
#end

# Uncomment the next line to define a global platform for your project
platform :ios, '16.1'

target 'ExampleUI' do
  project 'ExampleUI/ExampleUI.xcodeproj'
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  # Pods for xcuitest-example

  target 'ExampleUITests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'ExampleUIUITests' do
    # Pods for testing
    pod 'XCTest-Gherkin'
  end

end
