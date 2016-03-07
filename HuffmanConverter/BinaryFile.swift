//
//  BinaryFile.swift
//  HuffmanConverter
//
//  Created by David Westgate on 2/18/16.
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

class BinaryFile {
  
  var filename: String
  var inputFile: Bool
  var file: NSFileHandle
  var position: UInt32
  var buffer: UInt8
  var bufferBits: UInt8
  var bitsRemaining: UInt8
  var sizeInBits: UInt32
  
  
  /**
    Binary File constructor. Open a file for reading, or create a file for writing. If we create a file, and a file already exists with that name, the old file will be removed.
   
    - Parameters:
      - filename: The name of the file to read from or write to
      - readOrWrite: 'w' or 'W' for an output file (open for writing) and 'r' or 'R' for an input file (open for reading)
   */
  init (filename: String, readOrWrite: Character) {
    self.filename = filename
    self.position = 0
    self.sizeInBits = 0
    buffer = 0
    bufferBits = 0
    bitsRemaining = 0
    
    if (readOrWrite == "w" || readOrWrite == "W") {
      inputFile = false
      NSFileManager.defaultManager().createFileAtPath(filename, contents: nil, attributes: nil)
      self.file = NSFileHandle(forWritingAtPath: filename)!
      file.writeData(NSData(bytes: &sizeInBits, length: sizeof(UInt32)))
    } else {
      inputFile = true
      self.file = NSFileHandle(forReadingAtPath: filename)!
      
      let fileData = file.readDataOfLength(sizeof(UInt32))
      fileData.getBytes(&sizeInBits, length: sizeof(UInt32))
      position = position + UInt32(sizeof(UInt32) * 8)
    }
  }
  
  
  /**
    Checks to see if we are at the end of a file.  This method is only valid for input files, calling EndOfFile on an output fill will cause the program to halt execution.
  
    - Returns: **true** if we are at the end of an input file, **false** otherwise
   */
  func EndOfFile() -> Bool {
    return position >= sizeInBits
  }
  
  
  /**
    Read the next 8 bits of the input file and interpret them as a character. This method is only valid for input files and will halt exection if called on an output file.
   
    - Returns: The next character in an input file
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
    Write a character to an output file. The 8 bits representing the character are written one at a time to the file. This method is only valid for output files, and will halt execution if called on an input file.
   
    - Parameters:
      - c: The character to write to the output file
   */
  func writeChar(c: Character) {
    var charbuf = String(c).utf8.first
    for (var i=0; i < 8; i++) {
      writeBit(charbuf! % 2 > 0)
      charbuf = charbuf! >> 1
    }
  }
  
  
  /**
   Write a bit to an output file. This method is only valid for output files, and will halt execution if called on an input file.

   - Parameters:
      - bit: The bit to write.  false writes a 0 and true writes a 1.
   */
  func writeBit(bit: Bool) {
    var bit_: UInt8 = 0

    position++
    bit_ = bit == true ? 1 : 0
    buffer |= (bit_ << (bufferBits++))
    
    if (bufferBits == 8) {
      file.writeData(NSData(bytes: &buffer, length: sizeof(UInt8)))
      bufferBits = 0
      buffer = 0
    }
  }
  
  
  /**
   Read a bit froman input file.  This method is only valid for input files, and will halt exeuction if called on an output file.

   - Returns: The next bit in the input file -- false for 0 and true for 1
   */
  func readBit() -> Bool {
    if (bitsRemaining == 0) {
      let fileData = file.readDataOfLength(sizeof(UInt8))
      var array: UInt8 = 0
      fileData.getBytes(&array, length: sizeof(UInt8))
      buffer = array
      bitsRemaining = 8
    }
    position++
    return ((buffer >> (8 - bitsRemaining--) & 0x01) > 0)
  }
  
  
  /**
    Close the file (works for input and output files).  Output files will not be properly written to disk if this method is not called.
   */
  func close() {
    if (!inputFile) {
      
      sizeInBits = position
      
      if (bufferBits != 0) {
        while (bufferBits < 8) {
          buffer |= (0 << (bufferBits++))
        }
        file.writeData(NSData(bytes: &buffer, length: sizeof(UInt8)))
      }
      file.seekToFileOffset(0)
      file.writeData(NSData(bytes: &sizeInBits, length: sizeof(UInt32)))
    }
    file.closeFile()
  }
  
}