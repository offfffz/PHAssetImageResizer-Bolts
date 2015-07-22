Pod::Spec.new do |s|

  s.name          = "PHAssetImageResizer-Bolts"
  s.version       = "0.1.0"
  s.summary       = "Image resizing base on PhotosKit for iOS8+ and Bolts."
  s.homepage      = "https://github.com/offfffz/PHAssetImageResizer-Bolts"
  s.license       = "MIT"

  s.author        = { "offz" => "offfffz@gmail.com" }

  s.platform      = :ios, "8.0"
  s.source        = { :git => "https://github.com/offfffz/PHAssetImageResizer-Bolts.git", :tag => "0.1.0" }
  s.source_files  = "ImageResizer.swift"
  s.framework     = "Photos"

  s.requires_arc = true

  s.dependency "FCFileManager", "~> 1.0.10"
  s.dependency "Bolts/Tasks", "~> 1.2.0"

end
