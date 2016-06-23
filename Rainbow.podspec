Pod::Spec.new do |s|

  s.name        = "Rainbow"
  s.version     = "0.1"
  s.summary     = "KMNavigationBarTransition in Swift."

  s.description = <<-DESC
                    A drop-in universal library makes transition animations smooth between different navigation bar styles while pushing or popping.
                   DESC

  s.homepage    = "https://github.com/Limon-O-O/Rainbow"

  s.license     = { :type => "MIT", :file => "LICENSE" }

  s.authors           = { "Limon" => "fengninglong@gmail.com" }
  s.social_media_url  = "https://twitter.com/Limon______"

  s.ios.deployment_target   = "8.0"
  # s.osx.deployment_target = "10.7"

  s.source          = { :git => "https://github.com/Limon-O-O/Rainbow.git", :tag => s.version }
  s.source_files    = "Rainbow/*.swift"
  s.requires_arc    = true

end
