// The Swift Programming Language
// https://docs.swift.org/swift-book
//
// Swift Argument Parser
// https://swiftpackageindex.com/apple/swift-argument-parser/documentation

import AppKit
import Foundation
import ArgumentParser


@main
struct resizeImage: ParsableCommand {
	// configuration
	static let configuration: CommandConfiguration = CommandConfiguration(commandName: "resizeImage", abstract: "A simple command-line tool to resize image(s).", usage: "resizeImage [options] <file path>", discussion: "Visit https://github.com/rhinoed/resizeImage for more information.", version: "1.0", aliases: ["rsi"])
	// arguments
	@Argument(help: "The file path to input image(s).") var input: [String]
	// Flags
	@Flag(name: .shortAndLong, help: "Enable verbose output.") var verbose: Bool = false
	@Flag(name: .shortAndLong, help: "Delete input file after resizing") var delete: Bool = false
	// Options
	@Option(name: .shortAndLong, help: "Image format (png, jpeg, gif)") var format: String = "png"
	@Option(name: .shortAndLong, help: "output file path (full path) default: input file path") var output: String?
	@Option(name: .shortAndLong, help: "The scale factor to apply") var scale: Float = 1.0
	@Option(name: [.customShort("H"), .customLong("height")], help: "resized image height") var height: Int?
	@Option(name: [.customShort("W"), .customLong("width")], help: "resized image width") var width: Int?
	
	
	
	
	mutating func run() throws {
		
		for path in input {
			// check if path exists in the file system
			if verbose {
				print("checking if file exists: \(path)...")
			}
			guard FileManager.default.fileExists(atPath: path) else {
				print("error: file not found: \(path)")
				continue
			}
			// create url from path
			let inputURL = URL(fileURLWithPath: path)
			let fileName = inputURL.deletingPathExtension().lastPathComponent
			let parentDirectoryURL = inputURL.deletingLastPathComponent()
			
			// create image data
			if verbose {
				print("getting data for \(path)...")
			}
			let data = try Data(contentsOf: URL(fileURLWithPath: path))
			if verbose {
				print("loading image...")
			}
			guard let image = NSImage(data: data)else{
				print("error: cannot load image")
				continue
			}
			// calculate image size
			if verbose {
				print("calculating target size...")
			}
			let targetSize = getTargetSize(width: width, height: height, imageSize: image.size)
			// resize image
			if verbose {
				print("calculation complete image will ber resized from \(image.size) to \(targetSize)")
				print("resizing image...")
			}
			let resizedImage = resizeImage(image: image ,to: targetSize)
			// set output path
			var outputPath: URL
			if #available(macOS 13.0, *) {
				outputPath = URL(filePath: output ?? parentDirectoryURL.relativePath + "/" + fileName + "-resized.\(format)")
			} else {
				outputPath = URL(fileURLWithPath: output ?? parentDirectoryURL.relativePath + "/" + fileName + "-resized.\(format)")
			}
			// writing image
			if verbose {
				print("output will be written to \(outputPath)")
				print("attempting to write output...")
			}
			do {
				try writeImage(resizedImage, to: outputPath)
				print("write successful to: \(outputPath)")
			} catch {
				print("error: \(error)")
				return
			}
			// delete if true
			if delete && verbose {
				print("deleting input file...")
				deleteInputFiles()
			}
		}
	}
	
	func deleteInputFiles() {
		for path in input {
			do {
				try FileManager.default.removeItem(atPath: path)
				if verbose {
					print("\(path) was deleted")
				}
			} catch {
				print("error: \(error)")
			}
		}
	}
	
	
	
	func writeImage(_ image: NSImage, to url: URL) throws {
		var filtType: NSBitmapImageRep.FileType;
		switch format {
		case "jpeg":
			filtType = .jpeg
		case "gif":
			filtType = .gif
		case "png":
			filtType = .png
		default:
			print("error: unsupported format: \(format)")
			throw NSError(domain: "", code: 1, userInfo: nil)
		}
		guard let imgRep = image.tiffRepresentation,
			  let btm = NSBitmapImageRep(data: imgRep),
			  let imgData = btm.representation(using: filtType, properties: [:])
		else {
			print("error: cannot convert image to PNG data")
			throw NSError(domain: "", code: 1, userInfo: nil)
		}
		
		try imgData.write(to: url)
		
	}
	
	func resizeImage(image: NSImage, to size: NSSize) -> NSImage {
		let newImage = NSImage(size: size, flipped: false){ rect in
			image.draw(in: rect, from: NSRect(origin: .zero, size: image.size), operation: .copy, fraction: 1.0)
			return true
		}
		return newImage
	}
	
	func getTargetSize(width: Int?, height: Int?, imageSize: NSSize) -> NSSize {
		if let width = width, let height = height {
			return NSSize(width: CGFloat(width), height: CGFloat(height))
		} else if let width = width {
			let scaleFactor = CGFloat(width) / imageSize.width
			return NSSize(width: CGFloat(width), height: CGFloat(imageSize.height * scaleFactor))
		} else if let height = height {
			let scaleFactor = CGFloat(height) / imageSize.height
			return NSSize(width: CGFloat(imageSize.width * scaleFactor), height: CGFloat(height))
		}
		return NSSize(width: imageSize.width * CGFloat(scale), height: imageSize.height * CGFloat(scale))
	}
}
