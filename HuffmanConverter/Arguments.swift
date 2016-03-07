//
//  Arguments.swift
//  HuffmanConverter
//
//  Created by David Westgate on 2/15/16.
//  Copyright © 2016 David Westgate. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions: The above copyright
//  notice and this permission notice shall be included in all copies or
//  substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE

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
        
        if !fileManager.isReadableFileAtPath(inputFile) {
          errorMessage = "Error: unable to read input file"
        } else if (fileManager.fileExistsAtPath(outputFile)) {
          errorMessage = "Error: output file already exists"
        } else if (decompressing) {
          var magicNumber = ""
          
          let bfr = BinaryFile(filename: inputFile, readOrWrite: "r")
          
          var i = 0
          while ((!bfr.EndOfFile() && (i < 16))) {
            magicNumber = magicNumber + String((bfr.readBit()) ? 1 : 0)
            i++
          }
          bfr.close()
          
          if (magicNumber != "0100100001000110") {
            errorMessage = "Error: file to uncompress is not Huffman coded"
          }
        }
      }
      
      var i = 2
      while ((errorMessage == "") && (i < arguments.count - 2)) {
        print("\(arguments.count - 2)")
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
  
  
  /**
    Outputs usage information to the command line. This function is called when input parameters are incorrect.
   */
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