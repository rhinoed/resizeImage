// The Swift Programming Language
// https://docs.swift.org/swift-book
//
// Swift Argument Parser
// https://swiftpackageindex.com/apple/swift-argument-parser/documentation

import Foundation
import ImageSizer
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
		//Messanger.verbose = verbose
		for path in input {
			
			// check if path exists in the file system
			Message.fileExists.action(path)
			
			guard FileManager.default.fileExists(atPath: path) else {
				print("error: file not found: \(path)")
				continue
			}
			// create url from path
			let inputURL = URL(fileURLWithPath: path)
			let fileName = inputURL.deletingPathExtension().lastPathComponent
			let parentDirectoryURL = inputURL.deletingLastPathComponent()
			
			// create image data
			Message.gettingFile.action(path)
			
			let imageLoader = ImageLoader()
			Message.loadingImage.action("...")
			guard let image = imageLoader.cgLoadImage(from: inputURL) else{
				print("error: cannot load image")
				continue
			}
			// calculate image size
			Message.calculatingSize.action("...")
			let targetSize: (Int,Int) = ImageSizer.getTargetSize(width: width, height: height, image: image)
			print(targetSize)
			let imageSizer = ImageSizer(image: image, targetWidth: targetSize.0, targetHeight: targetSize.1)
			
			Message.savingImage.action("calculation complete image will ber resized from \(image.width.description),x\(image.height.description)to \(imageSizer.targetWidth),x\(imageSizer.targetHeight)\nresizing image...")
			
			var outputPath: URL
			if #available(macOS 13.0, *) {
				outputPath = URL(filePath: output ?? parentDirectoryURL.relativePath + "/" + fileName + "-resized.\(format)")
			} else {
				outputPath = URL(fileURLWithPath: output ?? parentDirectoryURL.relativePath + "/" + fileName + "-resized.\(format)")
			}
			imageSizer.resize(image: image, to: outputPath)
			//Message.done.action("")
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
		
}
