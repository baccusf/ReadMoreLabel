Pod::Spec.new do |spec|
  spec.name         = "ReadMoreLabel"
  spec.version      = "0.2.1"
  spec.summary      = "An expandable UILabel with read more functionality using TextKit"
  spec.description  = <<-DESC
    ReadMoreLabel is a custom UILabel subclass that provides expandable text functionality.
    When text exceeds the specified number of lines, it shows a customizable "read more" link
    that users can tap to expand and view the full content. Perfect for UITableViewCells and
    other space-constrained layouts.
    
    Features:
    - Customizable "read more" text with NSAttributedString support
    - Delegate pattern for state change notifications  
    - Programmatic expand/collapse control
    - Automatic layout invalidation and animation support
    - TextKit-based precise text measurement and truncation
    - Interface Builder support with @IBDesignable and @IBInspectable
    DESC

  spec.homepage     = "https://github.com/baccusf/ReadMoreLabel"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author       = { "SeungHo Choi" => "baccusf@gmail.com" }

  spec.platform     = :ios, "16.0"
  spec.ios.deployment_target = "16.0"

  spec.source       = { :git => "https://github.com/baccusf/ReadMoreLabel.git", :tag => "#{spec.version}" }
  spec.source_files = "Sources/ReadMoreLabel/**/*.{swift}"

  spec.framework    = "UIKit"
  spec.requires_arc = true
  spec.swift_version = "5.9"
end