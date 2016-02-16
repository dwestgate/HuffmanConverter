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
    print("\nReading text file\n")
    print("\nDone reading text file\n")
  } else {
    print("%nReading binary file%n")
    print("Writing text file\n")
  }
}
