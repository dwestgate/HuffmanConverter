//
//  BinaryFile.swift
//  HuffmanConverter
//
//  Created by David Westgate on 2/18/16.
//  Copyright © 2016 Refabricants. All rights reserved.
//

import Foundation

class BinaryFile {
  
  var filename: String
  var inputFile: Bool
  var file: NSFileHandle
  var position: UInt64
  var buffer: UInt8
  var bufferBits: UInt8
  var bitsRemaining: UInt8
  
  /**
   * Binary File constructor. Open a file for reading, or create
   * a file for writing. If we create a file, and a file already
   * exists with that name, the old file will be removed.
   * @param filename The name of the file to read from or write to
   * @param readOrWrite 'w' or 'W' for an output file (open for writing),
   * and 'r' or 'R' for an input file (open for reading)
   */
  init (filename: String, readOrWrite: Character) {
    
    self.filename = filename
    self.position = 0
    buffer = 0
    bufferBits = 0
    bitsRemaining = 0
    
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
  * cause the program to halt execution.
  * (This method should probably really throw an
  * exception instead of halting the program on an error, but I'm
  * trying to make your code a little simplier)
  * @return True if we are at the end of an input file, and false otherwise
  */
  func EndOfFile() -> Bool {
    
    var filesize: UInt64 = 0
    
    do {
      let attr: NSDictionary? = try NSFileManager.defaultManager().attributesOfItemAtPath(filename)
      if let _attr = attr {
        filesize = _attr.fileSize()
      }
    } catch {
      print("Error encountered checking for end of file")
    }
    print("position = \(position); filesize = \(filesize)")
    return position >= filesize
  }
  
  /**
   * Read in the next 8 bits to the input file, and interpret them as
   * a character.  This method is only valud for input files, and
   * will halt exection of called on an output file.
   * (This method should probably really throw an
   * exception instead of halting the program on an error, but I'm
   * trying to make your code a little simplier)
   * @return The next character from an input file
   */
  func readChar() -> Character {
    
    var byte = 0
    
    for (var i=0;i < 8;i++) {
      byte = byte << 1
      if (readBit()) {
        byte += 1
      }
    }
    return Character(UnicodeScalar(byte))
  }
  
  /**
   * Write a character to an output file. The 8 bits representing the character
   * are written one at a time to the file. This method is only valid for
   * output files, and will halt execution if called on an input file.
   * (This method should probably really throw an
   * exception instead of halting the program on an error, but I'm
   * trying to make your code a little simplier)
   * @param c The character to write to the output file.
   */
  func writeChar(c: Character) {
    
    // var charbuf: UInt8 = 0
    var charbuf = String(c).utf8.first
    /* for codeUnit in String(c).utf8 {
      charbuf = codeUnit
    }*/
    
    for (var i=0; i < 8; i++) {
      writeBit(charbuf! % 2 > 0)
      charbuf = charbuf! >> 1
    }
    
  }
  
  /**
   * Write a bit to an output file  This method is only valid for
   * output files, and will halt execution if called on an input file.
   * (This method should probably really throw an
   * exception instead of halting the program on an error, but I'm
   * trying to make your code a little simplier)
   * @param bit The bit to write.  false writes a 0 and true writes a 1.
   */
  func writeBit(bit: Bool) {
    // total_bits++
    var bit_: UInt8 = 0
    
    if (bit) {
      bit_ = 1
    } else {
      bit_ = 0
    }
    buffer |= (bit_ << (bufferBits++))
    print("\(String(buffer, radix: 2))")
    if (bufferBits == 8) {
      file.writeData(NSData(bytes: &buffer, length: 1))
      bufferBits = 0
      buffer = 0
    }
  }
  
  /**
   * Read a bit froman input file.  This method is only valid for
   * input files, and will halt exeuction if called on an output file.
   * (This method should probably really throw an
   * exception instead of halting the program on an error, but I'm
   * trying to make your code a little simplier)
   * @return The next bit in the input file -- false for 0 and true for 1.
   */
  func readBit() -> Bool {
    
    if (bitsRemaining == 0) {
      let fileData = file.readDataOfLength(1)
      var array: UInt8 = 0
      fileData.getBytes(&array, length:sizeof(UInt8))
      buffer = array
      bitsRemaining = 8
      position++
    }
    // bitsread++
    return (((buffer >> --bitsRemaining) & 0x01) > 0)
  }

  
  /**
   * Close the file (works for input and output files).  Output files will
   * not be properly written to disk if this method is not called.
   */
  func close() {
    if (!inputFile) {
      if (bufferBits != 0) {
        while (bufferBits < 8) {
          buffer |= (0 << (bufferBits++))
        }
        file.writeData(NSData(bytes: &buffer, length: 1))
      }
    }
    file.closeFile()
  }
  
}
