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
    
    
    print("\nWriting text file\n")
    let bfw = BinaryFile(filename: arguments.outputFile, readOrWrite: "w")
    for c in message.characters {
      bfw.writeChar(c)
    }
    print("")
    bfw.close()
  } else {
    let bfr = BinaryFile(filename: arguments.inputFile, readOrWrite: "r")
    print("\nReading text file\n")
    while (!bfr.EndOfFile()) {
      message = message + String(bfr.readChar())
    }
    bfr.close()
    print("\nDone reading text file\n")
    print("\nWriting text file\n")
    let tfw = BinaryFile(filename: arguments.outputFile, readOrWrite: "w")
    for c in message.characters {
      tfw.writeChar(c)
    }
    print("")
    tfw.close()
  }
}
