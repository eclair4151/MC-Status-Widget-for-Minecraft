import SwiftUI

#if os(macOS)
public typealias UniversalImage = NSImage
#else
public typealias UniversalImage = UIImage
#endif
