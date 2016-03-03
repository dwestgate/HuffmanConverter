//
//  TextFile.swift
//  HuffmanConverter
//
//  Created by David Westgate on 2/21/16.
//  Copyright © 2016 Refabricants. All rights reserved.
//

import Foundation

class TextFile {
  
  var filename: String
  var inputFile: Bool
  var file: NSFileHandle
  var position: UInt64
  
  /**
  * Text File constructor.  Open a file for reading, or create
  * a file for writing.  If we create a file, and a file already
  * exists with that name, the old file will be removed.
  * @param filename The name of the file to read from or write to
  * @param readOrWrite 'w' or 'W' for an output file (open for writing),
  * and 'r' or 'R' for an input file (open for reading)
  */
  init (filename: String, readOrWrite: Character) {
    
    self.filename = filename
    self.position = 0
    
    if (readOrWrite == "w" || readOrWrite == "W") {
      inputFile = false
      NSFileManager.defaultManager().createFileAtPath(filename, contents: nil, attributes: nil)
      self.file = NSFileHandle(forWritingAtPath: filename)!
    } else {
      inputFile = true
      self.file = NSFileHandle(forReadingAtPath: filename)!
    }
  }
  
  
  /**
  * Checks to see if we are at the end of a file.  This method is only
  * valid for input files, calling EndOfFile on an output fill will
  * cause the program to exit.  (This method should probably really throw an
  * exception instead of halting the program on an error, but I'm
  * trying to make your code a little simplier)
  * @return True if we are at the end of an input file, and false otherwise
  */
  func EndOfFile() -> Bool  {
    
    var filesize: UInt64 = 0
    
    do {
      let attr: NSDictionary? = try NSFileManager.defaultManager().attributesOfItemAtPath(filename)
      if let _attr = attr {
        filesize = _attr.fileSize()
      }
    } catch {
      print("Error encountered checking for end of file")
    }
    // print("position = \(position); filesize = \(filesize)")
    return position >= filesize
  }
  
  
  /**
  * Read in the next character from the input file
  * This method is only valud for input files, and
  * will throw an halt program execution if called on an outpt file.
  * (This method should probably really throw an
  * exception instead of halting the program on an error, but I'm
  * trying to make your code a little simplier)
  * This method will also halt execution if you try to read past the
  * end of a file.
  * @return The next character from an input file
  */
  func readChar() -> Character {
    
    position++
    
    let fileData = file.readDataOfLength(1)
    var byte: UInt8 = 0
    fileData.getBytes(&byte, length:sizeof(UInt8))
    
    return Character(UnicodeScalar(byte))
  }
  
  
  /**
  * Write a character to an output file.   This method is only valid for
  * output files, and will halt execution if called on an input file.
  * (This method should probably really throw an
  * exception instead of halting the program on an error, but I'm
  * trying to make your code a little simplier)
  * @param c The character to write to the output file.
  */
  func writeChar(c: Character) {
    
    var byte = String(c).dataUsingEncoding(NSUTF8StringEncoding)!
    
    file.writeData(NSData(bytes: &byte, length: 1))
    
  }
  
  
  /**
  * Close the file (works for input and output files).  Output files will
  * not be properly written to disk if this method is not called.
  */
  func close() {
    file.closeFile()
  }
  
  
  /**
  * Rewind the input file to the beginning, so we can reread
  * the file.  Only valid for input files.
  */
  func rewind() {
    // Assert.notFalse(inputFile,"Can only rewind input files!")
    file.seekToFileOffset(0)
    position = 0
  }

}