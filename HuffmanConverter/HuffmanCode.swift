//
//  HuffmanCode.swift
//  HuffmanConverter
//
//  Created by David Westgate on 2/25/16.
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

class HuffmanCode {
  
  var text: String = ""
  var verbose: Bool
  var uniqueCharacters: Int = 0
  var encodingScheme = [Character: String]()
  var root: Node?
  var huffmanTree: String = ""
  var asciiCount: [Int] = []
  var decodingIndex: Int = 0
  
  /**
    - Parameters:
      - text: The text to be coded or decoded using Huffman coding
      - verbose: Indicates whether the application is running in "verbose" mode or not. Verbose mode is triggered when the -v command line parameter has been provided
      - inputType: Indicates whether the text provided is in binary or ascii format
   */
  init(text: String, verbose: Bool, inputType: String) {
    self.text = text
    self.verbose = verbose
    self.uniqueCharacters = 0
    self.root = Node()
    self.huffmanTree = ""
    self.asciiCount = [Int](count: 256, repeatedValue: 0)
    self.decodingIndex = 0
    
    if (inputType == "ascii") {
      countChars()
      
      if (verbose) {
        printAsciiCount()
      }
      
      createEncoding()
      
      if (verbose) {
        printCompressionReport()
      }
    } else {
      readEncoding()
      if (verbose) {
        printTree()
      }
    }
  }
  
  /**
    Encodes the provided ascii text using Huffman coding
   
    - Returns: The Huffman code of the provided ascii text
   */
  func encode() -> String {
    var code: String
    var compressedMessage = characterToASCIIBinary("H") + characterToASCIIBinary("F")
    
    compressedMessage = compressedMessage + huffmanTree
    
    for char in text.characters {
      code = encodingScheme[char]!
      compressedMessage = compressedMessage + code
    }
    
    return compressedMessage
  }
  
  /**
    Decodes a Huffman coded binary string to ascii
   
    - Returns: The ascii code of the provided Huffman coded binary string
   */
  func decode() -> String {
    var decompressedMessage = ""
    var decodingScheme = [String: Character]()
    var possibleCode = ""
    
    let messageText = text.substringFromIndex(text.startIndex.advancedBy(decodingIndex))
    
    for key in encodingScheme.keys {
      decodingScheme[encodingScheme[key]!] = key
    }
    
    for digit in messageText.characters {
      possibleCode += String(digit)
      if let char = decodingScheme[possibleCode] {
        decompressedMessage = decompressedMessage + String(char)
        possibleCode = ""
      }
    }
    
    return decompressedMessage
  }
  
  /**
    - Returns: The size of the string when saved as an ascii text file
   */
  func getUnencodedSize() -> Int {
    print("text.characters.count = \(text.characters.count)")
    return text.characters.count * 8
  }
  
  /**
    - Returns: The size of the string when saved as a Huffman coded binary file
   */
  func getEncodedSize() -> Int {
    var size = 32 + 16 + huffmanTree.characters.count

    for (var i = 0; i < 256; i++) {
      if let code = encodingScheme[decimalToASCIICharacter(UInt8(i))] {
        size = size + asciiCount[i] * code.characters.count
      }
    }
    
    return size
  }
  
  /**
    Counts the number of occurrences of each ascii character in the ascii string by populating a simple array where the array indexes represent the ascii values of characters in the file.
   */
  func countChars() {
    for char in text.characters {
      if (asciiCount[Int(characterToASCIIDecimal(char))] == 0) {
        uniqueCharacters++
      }
      asciiCount[Int(characterToASCIIDecimal(char))]++
    }
  }
  
  /**
    Builds a Huffman tree and then uses the tree to determine the Huffman codes for each character in the string
  */
  func createEncoding() {
    var asciiFrequencies = asciiCount
    var sorted = [Int](count: uniqueCharacters, repeatedValue: 0)
    let nodeTemplate = Node()
    var sortedNodes = [Node?](count: uniqueCharacters, repeatedValue: nodeTemplate)
    var max = 0

    for (var i = uniqueCharacters - 1; i >= 0; i--) {
      max = 0
      for (var j = 0; j < asciiFrequencies.count; j++) {
        if (asciiFrequencies[j] > max) {
          max = asciiFrequencies[j]
          sorted[i] = j
        }
      }
      sortedNodes[i] = Node()
      sortedNodes[i]!.character = decimalToASCIICharacter(UInt8(sorted[i]))
      sortedNodes[i]!.frequency = asciiCount[sorted[i]]
      asciiFrequencies[sorted[i]] = 0
    }
    
    formTree(sortedNodes, index: 0)
    createCodes(&root, code: "")

    if (verbose) {
      printTree()
      printCodes()
    }
  }

  /**
    Reads a binary string representing a Huffman tree, builds the Huffman tree described, and then uses the tree to determine the Huffman codes to be used in decoding a string
   */
  func readEncoding() {
    readTree(root!)
    createCodes(&root, code: "")
  }

  /**
    Recursive method that builds a Huffman tree from a binary string description of that tree
    
    - Parameters:
      - node: A node in the Huffman tree
   */
  func readTree(node: Node) {
    if (text.substringWithRange(Range(start: text.startIndex.advancedBy(decodingIndex), end: text.startIndex.advancedBy(decodingIndex + 1))) == "0") {
      
      let binaryWord = text.substringWithRange(Range(start: text.startIndex.advancedBy(decodingIndex + 1), end: text.startIndex.advancedBy(decodingIndex + 9)))
      let number = Int(binaryWord, radix: 2)
      node.character = decimalToASCIICharacter(UInt8(number!))
      decodingIndex = decodingIndex + 9
      uniqueCharacters++
    } else {
      decodingIndex++
      node.left = Node()
      readTree(node.left!)
      node.right = Node()
      readTree(node.right!)
    }
  }

  /**
    Recursive method that builds a Huffman tree from an array of unassociated nodes
   
    - Parameters:
      - nodes: An array of nodes, each containing a character found in the string along with the frequency with which it appears in the string
      - index: The index usd to traverse the array of nodes
   */
  func formTree(var nodes: [Node?], index: Int) {
    if (index >= nodes.count - 1) {
      root = nodes[index]!
    } else if (nodes[index]!.frequency > nodes[index + 1]!.frequency) {
      var i = index
      while ((i + 1 < nodes.count) && (nodes[index]!.frequency > nodes[i + 1]!.frequency)) {
        i++
      }
      let tmp = nodes[index]
      nodes[index] = nodes[i]
      nodes[i] = tmp
      formTree(nodes, index: index)
    } else if (nodes[index]!.frequency <= nodes[index + 1]!.frequency) {
      let tmp = Node(left: nodes[index]!, right: nodes[index + 1]!, frequency: nodes[index]!.frequency + nodes[index + 1]!.frequency)
      nodes[index + 1] = tmp
      nodes[index] = nil
      formTree(nodes, index: index + 1)
    }
  }

  /**
    - Given the root of a Huffman tree, traverses the tree to build a table of Huffman codes
   
    - Parameters:
      - root:  The root of the Huffman tree
      - code:  The Huffman codes
  */
  func createCodes(inout root: Node?, var code: String) {
    if (root != nil) {
      root!.huffCode = code
      if let char = root!.character {
        if (code == "") {
          code = "0"
        }
        encodingScheme[char] = code
        huffmanTree = huffmanTree + "0" + root!.asciiBinary()
      } else {
        huffmanTree = huffmanTree + "1"
      }
      createCodes(&root!.left, code: code + "0")
      createCodes(&root!.right, code: code + "1")
    }
  }
  
  /**
    Used to output the Huffman tree. Outputs the tree both visually and as a binary string.
  */
  func printTree() {
    print("")
    print("                 Huffman Tree - Tree Format")
    print("  {charcter}:{number of occurrences - always 0 when decoding}")
    print("")
    printTreeNode(&root, indent: "  ")
    print("")
    print("      Huffman Tree - Print as String")
    print("  A single bit with value 1 for each internal node")
    print("  A single bit with value 0, followed by an 8-bit character for each leaf")
    print("")
    print(huffmanTree)
    print("")
  }
  
  /**
    Called by PrintTree, recursively prints Huffman tree nodes

    - Parameters:
      - node: A node in the Huffman tree
      - indent: The indentation used when outputting the node
   */
  func printTreeNode(inout node: Node?, var indent: String) {
    if (node != nil) {
      if let char = node!.character {
        print("\(indent)\(char): \(node!.frequency)")
      } else {
        print("\(indent) : \(node!.frequency)")
      }
      
      indent = indent + "      "
      printTreeNode(&node!.left, indent: indent)
      printTreeNode(&node!.right, indent: indent)
    }
  }
  
  /**
    Outputs a table showing the frequencies of occurrence of each ascii character in the string
   */
  func printAsciiCount() {
    print("  ┌───────────────────────────────────────────────────────────────┐")
    print("  │                Input File Character Frequency                 │")
    print("  │                                                               │")
    print("  │   Char      Decimal   Hex       Binary            Frequency   │")
    print("  ├───────────────────────────────────────────────────────────────┤")
    for (var i = 0; i < 256; i++) {
      if (asciiCount[i] > 0) {
        var character: Character = " "
        
        if (i > 31) {
          character = decimalToASCIICharacter(UInt8(i))
        }
        print(String(format: "  │     %1@         %3d    %4x      %8@ %19d   │", String(character), i, i, String(intToBinary(i)), asciiCount[i]))
      }
    }
    print("  ├───────────────────────────────────────────────────────────────┤")
    print("  │  Total characters:\t\(text.characters.count)                                        │" )
    print("  │  Unique characters:\t\(uniqueCharacters)                                        │" )
    print("  └───────────────────────────────────────────────────────────────┘")
    
  }
  
  
  // TODO: replace iterations with map/reduce
  /**
    Outputs a table showing each ascii character in the string and the Huffman code that has been assigned to it
   */
  func printCodes() {
    print("  ┌───────────────────────────────────────────────────────────────┐")
    print("  │                      Huffman Codes                            │")
    print("  │                                                               │")
    print("  │   Char    Decimal   Hex      Binary              Encoding     │")
    print("  ├───────────────────────────────────────────────────────────────┤")
    
    let keys = encodingScheme.keys.sort()
    
    for k in keys {
      var char = k
      let ascii = Int(characterToASCIIDecimal(k))
      let code = encodingScheme[k]
      if (ascii < 32) {
        char = " "
      }
      
      var spaces  = " "
      
      for (var i = 0; i < 22 - code!.characters.count; i++) {
        spaces += " "
      }
      
      print(String(format: "  │     %@       %3d    %4x     %8@%@%@   │", String(char), ascii, ascii, intToBinary(ascii), spaces, code!))
    }
    print("  └───────────────────────────────────────────────────────────────┘")
  }
  
  
  /**
    Returns the ASCII decimal value of a Character value represented as an 8-bit binary value and padded with zeroes as needed
   
    - Parameters:
      - char: The Character
   
    - Returns: The ASCII value of the Character, as a UInt8
   */
  func characterToASCIIDecimal(char: Character) -> UInt8 {
    
    let value = String(char).utf8.first
    
    return UTF8.CodeUnit(value!)
  }
  
  
  /**
    Converts an ASCII decimal value into a Character
   
    - Parameters:
      - char: The Character to be converted to binary
   
    - Returns: A string representing the Character's decimal ASCII value, in binary
   */
  func decimalToASCIICharacter(value: UInt8) -> Character {
    return Character(UnicodeScalar(value))
  }
  
  
  /**
    Converts a Character into a String representation of that Character's ASCII value represented as an 8-bit binary value and padded with zeroes as needed
   
    - Parameters:
      - char: The Character to be converted to binary
   
    - Returns: A string representing the Character's decimal ASCII value, in binary
   */
  func characterToASCIIBinary(char: Character) -> String {
    var returnValue = String(characterToASCIIDecimal(char), radix: 2)
    
    while (returnValue.characters.count < 8) {
      returnValue = "0" + returnValue
    }
    return returnValue
  }
  
  
  /**
    Converts an int into a String representation of that int's 8-bit binary value, padding with zeroes as needed
   
    - Parameters:
      - number: The int to be converted to binary
   
    - Returns: A string representing the binary value of the number
   */
  func intToBinary(number: Int) -> String {
    var returnValue = String(number, radix: 2)
    
    while (returnValue.characters.count < 8) {
      returnValue = "0" + returnValue
    }
    return returnValue
  }
  
  
  func intToHex(number: Int) -> String {
    return String(format: "%x", number)
  }
  
  
  /**
    Outputs the compressed and uncompressed size of the string
   */
  func printCompressionReport() {
    let uncompressed = getUnencodedSize()
    let uncompressedBytes = Int(ceil(Double(uncompressed) / 8.0))
    let compressed = getEncodedSize()
    let compressedBytes = Int(ceil(Double(compressed) / 8.0))
    
    print("  ┌───────────────────────────────────────────────────────────────┐")
    print("  │                      Compression Report                       │")
    print("  │                                                               │")
    print("  │ Uncompressed size: \(uncompressed) bits \(uncompressedBytes) bytes         │")
    print("  │ Compressed size  : \(compressed) bits \(compressedBytes) bytes         │")
    print("  └───────────────────────────────────────────────────────────────┘")
  }
  
  /**
    Huffman tree Node element, used to build the Huffman tree
   */
  class Node {
    
    var left: Node?
    var right: Node?
    var character: Character?
    var frequency : Int
    var huffCode: String
    
    /**
      Constructor for the Node class: called from createEncoding(), it allows population of frequency as the array of unassociated leaf nodes is first assembled
     
      - Parameters:
        - character: A character found int he string
        - frequency: The frequency with which the character appears in the string
     */
    init(character: Character, frequency: Int) {
      self.left = nil
      self.right = nil
      self.character = character
      self.frequency = frequency
      self.huffCode = ""
    }
    
    /**
      Constructor for the Node class: called from formTree(), it is used to create inner nodes
     
      - Parameters:
        - left: Left child of the node
        - right: Right child of the node
        - frequency: The combined frequency of this node's child nodes
     */
    init(left: Node, right: Node, frequency: Int) {
      self.left = left
      self.right = right
      self.frequency = frequency
      self.huffCode = ""
    }
    
    /**
      Constructor for the Node class: called from readTree(), it is used when building up a tree from a binary string representation of a Huffman tree and allows the creation of blank nodes
     */
    init() {
      self.left = nil
      self.right = nil
      self.frequency = 0
      self.huffCode = ""
    }
    
    /**
      - Returns: The decimal value of the ascii character which the node represents
     */
    func asciiDecimal() -> UInt8 {
      
      let value = String(self.character!).utf8.first
      
      return UTF8.CodeUnit(value!)
    }
    
    /**
      - Returns: The binary representation of the ascii character which the node represents
     */
    func asciiBinary() -> String {
      var returnValue = String(asciiDecimal(), radix: 2)
      
      while (returnValue.characters.count < 8) {
        returnValue = "0" + returnValue
      }
      return returnValue
    }
    
    /**
      - Returns: The hexidecimal value of the ascii character which the node represents
     */
    func asciiHex() -> String {
      return String(asciiDecimal(), radix: 16)
    }
  }
  
}