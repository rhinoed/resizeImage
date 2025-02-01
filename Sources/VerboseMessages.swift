//
//  File 2.swift
//  resizeImage
//
//  Created by Mark Edmunds on 2/1/25.
//

import Foundation

struct Messanger {
	static var verbose: Bool = false
}

enum Message{
	case fileExists
	case gettingFile
	case loadingImage
	case calculatingSize
	case resizingImage
	case savingImage
	case done
	
	
	var action: (String) -> Void {
		switch self {
		case .fileExists:
			if Messanger.verbose {
				return{ path in print("checking if file exists: \(path)...")}
			}
		case .gettingFile:
			if Messanger.verbose {
				return { path in
					print("getting data for \(path)...")}
			}
		case .loadingImage:
			if Messanger.verbose {
				return { msg in
					print("loading image\(msg)")
				}
			}
		case .calculatingSize:
			if Messanger.verbose {
				return { msg in
					print("calculating target size\(msg)")
				}
			}
		case .resizingImage:
			if Messanger.verbose {
				return { msg in
					print(msg)
				}
			}
		case .savingImage:
			if Messanger.verbose {
				return { path in
					print("saving image to \(path)...")}
			}
		case .done:
			if Messanger.verbose {
				return { _ in
					print("done!")}
			}
		}
		return { _ in}
	}
}
