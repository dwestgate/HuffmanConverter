//
//  Arguments.swift
//  HuffmanConverter
//
//  Created by David Westgate on 2/15/16.
//  Copyright © 2016 Refabricants. All rights reserved.
//

import Foundation

class Arguments {
  
  let fileManager = NSFileManager.defaultManager()
  
  var forceCompression = false
  var verbose = false
  var valid = true
  var compressing = false
  var decompressing = false
  var inputFile = ""
  var outputFile = ""
  
  init(arguments: [String]) {
    var errorMessage = ""
    
    if ((arguments.count > 2) && (arguments.count < 6)) {
      
      if (arguments[1].caseInsensitiveCompare("-c") == NSComparisonResult.OrderedSame) {
        compressing = true
        decompressing = false
      } else if (arguments[1].caseInsensitiveCompare("-u") == NSComparisonResult.OrderedSame) {
        decompressing = true
        compressing = false
      } else {
        errorMessage = "Error: incorrect usage: missing -c or -u flag"
      }
      
      if (errorMessage == "") {
        inputFile = fileManager.currentDirectoryPath.stringByAppendingString("/\(arguments[arguments.count - 2])")
        outputFile = fileManager.currentDirectoryPath.stringByAppendingString("/\(arguments[arguments.count - 1])")

/* Test Code
        let file = "testwrite.txt" //this is the file. we will write to and read from it
        let text = "some text" //just a text
        
        let path  = fileManager.currentDirectoryPath.stringByAppendingString("/\(file)")
          print("\(path)")
          //writing
          do {
            try text.writeToFile(path, atomically: false, encoding: NSUTF8StringEncoding)
          }
          catch {/* error handling here */}
          
          //reading
          do {
            let text2 = try NSString(contentsOfFile: path, encoding: NSUTF8StringEncoding)
            print("\(text2)")
          }
          catch {/* error handling here */}
 End Test Code */
        
        if !fileManager.isReadableFileAtPath(inputFile) {
          errorMessage = "Error: unable to read input file"
        } else if (fileManager.fileExistsAtPath(outputFile)) {
          errorMessage = "Error: output file already exists"
        }
        
        /*
        if (!Files.isReadable(Paths.get(inputFile))) {
        errorMessage = "Error: unable to read input file"
        }  else if (Files.exists(Paths.get(outputFile))) {
        errorMessage = "Error: output file already exists"
        } else if (decompressing) {
        var magicNumber = ""
        
        BinaryFile bf = new BinaryFile(inputFile, 'r')
        
        var i = 0
        while ((!bf.EndOfFile() && (i < 16))) {
        magicNumber = magicNumber + Integer.toString((bf.readBit()) ? 1 : 0)
        i++
        }*/
        // bf.close()
        
        /* if (magicNumber != "0100100001000110") {
        errorMessage = "Error: file to uncompress is not Huffman coded"
        }*/
        // }
      }
      
      var i = 1
      while ((errorMessage == "") && (i < arguments.count - 3)) {
        if (arguments[i].caseInsensitiveCompare("-v") == NSComparisonResult.OrderedSame) {
          verbose = true
        } else if (arguments[i].caseInsensitiveCompare("-f") == NSComparisonResult.OrderedSame) {
          forceCompression = true
        } else {
          errorMessage = "Error: unknown flag"
        }
        i++
      }
    } else {
      errorMessage = "Error: incorrect command-line parameters"
    }
    
    if (errorMessage != "") {
      print("\n\(errorMessage)\n\n")
      valid = false
    }
  }
  
  func showUsage() {
    print("Usage:")
    print("  $ HuffmanConverter (-c|-u) [-v] [-f]  infile outfile")
    print("where:")
    print("  (-c|-u) stands for either '-c' (for encode), or '-u' (for uncompress)")
    print("  [-v] stands for an optional '-v' flag (for verbose)")
    print("  [-f] stands for an optional '-f' flag, that forces compression even if the compressed file will be larger than the original file")
    print("  infile is the input file")
    print("  outfile is the output file\n")
    print("The flags -f and -v can be in either order. Examples:\n")
    print("  HuffmanConverter -c test test.huff")
    print("  HuffmanConverter -c -v myTestFile myCompressedFile")
    print("  HuffmanConverter -c -f -v test test.huff")
    print("  HuffmanConverter -u -f test1.huff test2")
    print("  HuffmanConverter -u -f -v test1.huff test2\n")
  }
  
}