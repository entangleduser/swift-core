import Colors
import SwiftUI

//struct Avatar {
//	var palette: [NativeColor] = [
//		.random(),
//		.random(),
//		.random()
//	]
//	var grid: (width: Int, height: Int) = (5, 5)
//	var seed: [Int32] = []
//	init(
//		using palette: [NativeColor]? = .none,
//		grid: (width: Int, height: Int)? = .none
//	) {
//		if let palette = palette {
//			self.palette = palette
//		}
//		if let grid = grid {
//			self.grid = grid
//		}
//		generateSeed()
//	}
//}
//
//extension Avatar {
//	mutating func generateSeed() {
//		let sample = palette.map(\.intValue)
//		seed = [1..<(grid.height*grid.width)]
//			.compactMap({ _ in sample.randomElement() })
//	}
//	func image(with scale: CGFloat) -> NativeImage {
//		let width = grid.width
//		let height = grid.height
//		var copy = seed
//		let cgImage =
//			copy.withUnsafeMutableBytes {  ptr -> CGImage in
//				let context =
//					CGContext(
//						data: ptr.baseAddress,
//						width: width,
//						height: height,
//						bitsPerComponent: 8,
//						bytesPerRow: 4*width,
//						space: CGColorSpace(name: CGColorSpace.sRGB)!,
//						bitmapInfo:
//							CGBitmapInfo
//							.byteOrder32Little.rawValue +
//							CGImageAlphaInfo
//							.premultipliedFirst.rawValue
//					)
//				return (context?.makeImage())!
//			}
//		#if os(iOS)
//		return
//			NativeImage(
//				cgImage: cgImage,
//				scale: scale,
//				orientation: .down
//			)
//		#elseif os(macOS)
//		let size =
//			NSSize(
//				width: CGFloat(width)*scale,
//				height: CGFloat(height)*scale
//			)
//		let nativeImage =
//			NativeImage(
//				cgImage: cgImage,
//				size: .init(width: width, height: height)
//			)
//		let frame =
//			NSRect(origin: .zero, size: size)
//		guard
//			let representation =
//				nativeImage.bestRepresentation(for: frame, context: nil, hints: nil)
//		else { return nativeImage }
//		return
//			NativeImage(size: size, flipped: false) { _ in
//				return representation.draw(in: frame)
//			}
//		#endif
//	}
//}
