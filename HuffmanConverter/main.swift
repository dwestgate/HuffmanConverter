//
//  main.swift
//  HuffmanConverter
//
//  Created by David Westgate on 2/15/16.
//  Copyright © 2016 Refabricants. All rights reserved.
//

import Foundation

var arguments = Arguments(arguments: Process.arguments)

if (!arguments.valid) {
  arguments.showUsage()
} else {
  var message = ""
  
  if arguments.compressing {
    let tfr = TextFile(filename: arguments.inputFile, readOrWrite: "r")
    print("\nReading text file\n")
    while (!tfr.EndOfFile()) {
      message = message + String(tfr.readChar())
    }
    tfr.close()
    print("\nDone reading text file\n")
    
    var huffCode = HuffmanCode(text: message, verbose: arguments.verbose, inputType: "ascii")
    
    if ((huffCode.getEncodedSize() < huffCode.getUnencodedSize() || arguments.forceCompression)) {
      print("\nWriting compressed file\n")
      
      let compressedMessage = huffCode.encode()
      
      
      let bfw = BinaryFile(filename: arguments.outputFile, readOrWrite: "w")
      for c in compressedMessage.characters {
        bfw.writeBit(c == "1" ? true: false)
      }
      print("")
      bfw.close()
      
    } else {
      print("")
      print("Compression aborted: unable to reduce file size. To force compression regardless, use the -f flag.")
    }
  } else {
    let bfr = BinaryFile(filename: arguments.inputFile, readOrWrite: "r")
    print("\nReading binary file\n")
    
    // Argument verification has already confirmed the first two characters are 'HF'
    for (var i = 0; i < 16; i++) {
      bfr.readBit()
    }
    
    while (!bfr.EndOfFile()) {
      message = message + String(bfr.readBit() ? 1: 0)
    }
    bfr.close()

    var huffCode = HuffmanCode(text: message, verbose: arguments.verbose, inputType: "binary")
    
    var decompressedMessage = huffCode.decode()
    print(decompressedMessage)
    
    print("\nWriting text file\n")
    let tfw = TextFile(filename: arguments.outputFile, readOrWrite: "w")
    for c in decompressedMessage.characters {
      tfw.writeChar(c)
    }
    print("")
    tfw.close()
  }
}
