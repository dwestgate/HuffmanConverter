 //
//  HuffmanCode.swift
//  HuffmanConverter
//
//  Created by David Westgate on 2/25/16.
//  Copyright © 2016 Refabricants. All rights reserved.
//

import Foundation

class HuffmanCode {
  
  var text: String = ""
  var verbose: Bool
  var uniqueCharacters: Int = 0
  var encodingScheme: [Character: String]?
  var root: Node
  var huffmanTree: String = ""
  var asciiCount: [Int] = []
  var decodingIndex: Int = 0
  
  /**
   * @param text      The text to be coded or decoded using Huffman coding
   * @param verbose   Indicates whether the application is running in "verbose" mode or not. Verbose mode is
   *                  triggered when the -v command line parameter has been provided
   * @param inputType Indicates whether the text provided is in binary or ascii format
   */
  init(text: String, verbose: Bool, inputType: String) {
    self.text = text
    self.verbose = verbose
    self.uniqueCharacters = 0
    self.encodingScheme = [Character: String]()
    self.encodingScheme = nil
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
      // readEncoding()
      if (verbose) {
        printTree()
      }
    }
  }
  
  /**
   * Encodes the provided ascii text using Huffman coding
   * @return  The Huffman code of the provided ascii text
   */
  func encode() -> String {
    var code: String
    var compressedMessage = characterToASCIIBinary("H") + characterToASCIIBinary("F")
    
    compressedMessage = compressedMessage + huffmanTree
    
    for char in text.characters {
      code = encodingScheme![char]!
      compressedMessage = compressedMessage + code
    }
    /*
    for (var i = 0; i < text.characters.count; i++) {
    code = encodingScheme.get(text.charAt(i))
    compressedMessage = compressedMessage + code
    }*/
    
    return compressedMessage
  }
  
  /**
   * Decodes a Huffman coded binary string to ascii
   * @return  The ascii code of the provided Huffman coded binary string
   */
  /*func decode() -> String {
    var decompressedMessage = ""
    var code: String
    
    var found = false
    
    while (decodingIndex < text.characters.count) {
      var i = 0
      for char in encodingScheme {
        code = encodingScheme
        if (decodingIndex + code.characters.count <= text.characters.count) {
          var a = text.substring(decodingIndex, decodingIndex + code.length())
          if (code.equals(text.substring(decodingIndex, decodingIndex + code.length()))) {
            decodingIndex = decodingIndex + code.length()
            decompressedMessage = decompressedMessage + character
            break
          }
        }
      }
    }
    
    return decompressedMessage
  }*/
  
  /**
   *
   * @return  The size of the string when saved as an ascii text file
   */
  func getUnencodedSize() -> Int {
    return text.characters.count * 8
  }
  
  /**
   *
   * @return  The size of the string when saved as a Huffman coded binary file
   */
  /*func getEncodedSize() -> Int {
    var size = 32 + 16 + huffmanTree.length()
    
    for (var i = 0; i < 256; i++) {
      var code: String = encodingScheme.get((char) i)
      if (code != nil) {
        size = size + asciiCount[i] * encodingScheme.get((char) i).length()
      }
    }
    
    return size
  }*/
  
  /**
   * Counts the number of occurrences of each ascii character in the ascii string by populating a simple array
   * where the array indexes represent the ascii values of characters in the file.
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
   * Builds a Huffman tree and then uses the tree to determine the Huffman codes for each character in the string
   */
  func createEncoding() {
    var asciiFrequencies = asciiCount
    var sorted = [Int](count: uniqueCharacters, repeatedValue: 0)
    let nodeTemplate = Node()
    var sortedNodes = [Node](count: uniqueCharacters, repeatedValue: nodeTemplate)
    var max = 0
    
    for (var i = uniqueCharacters - 1; i >= 0; i--) {
      max = 0
      for (var j = 0; j < asciiFrequencies.count; j++) {
        if (asciiFrequencies[j] > max) {
          max = asciiFrequencies[j]
          sorted[i] = j
        }
      }
      let temp = UInt8(sorted[i])
      sortedNodes[i].character = decimalToASCIICharacter(temp) as Character
      sortedNodes[i].frequency = 0
      asciiFrequencies[sorted[i]] = 0
    }
    
    // formTree(sortedNodes, 0)
    
    // createCodes(root, "")
    
    if (verbose) {
      printTree()
      printCodes()
    }
  }
  
  /**
   * Reads a binary string representing a Huffman tree, builds the Huffman tree described, and then uses the
   * tree to determine the Huffman codes to be used in decoding a string
   */
  /*func readEncoding() {
    var root: Node()
    readTree(root)
    createCodes(root, "")
  }*/
  
  /**
   * Recursive method that builds a Huffman tree from a binary string description of that tree
   * @param node  A node in the Huffman tree
   */
  /*func readTree(node: Node) {
    if (text.charAt(decodingIndex) == '0') {
      node.character = (char) Integer.parseInt(text.substring(decodingIndex + 1, decodingIndex + 9), 2)
      decodingIndex = decodingIndex + 9
      uniqueCharacters++
    } else {
      decodingIndex++
      node.left = new Node()
      readTree(node.left)
      node.right = new Node()
      readTree(node.right)
    }
  }*/
  
  /**
   * Recursive method that builds a Huffman tree from an array of unassociated nodes
   * @param nodes An array of nodes, each containing a character found in the string along with the frequency with
   *              which it appears in the string
   * @param index The index usd to traverse the array of nodes
   */
  /*func formTree(nodes: [Node], index: Int) {
    if (index >= nodes.length - 1) {
      root = nodes[index]
    } else if (nodes[index].frequency > nodes[index + 1].frequency) {
      int i = index
      while ((i + 1 < nodes.length) && (nodes[index].frequency > nodes[i + 1].frequency)) {
        i++
      }
      Node tmp = nodes[index]
      nodes[index] = nodes[i]
      nodes[i] = tmp
      formTree(nodes, index)
    } else if (nodes[index].frequency <= nodes[index + 1].frequency) {
      Node tmp = new Node(nodes[index], nodes[index + 1], nodes[index].frequency + nodes[index + 1].frequency)
      nodes[index + 1] = tmp
      nodes[index] = null
      formTree(nodes, index + 1)
    }
  }*/
  
  /**
   * Given the root of a Huffman tree, traverses the tree to build a table of Huffman codes
   * @param root  The root of the Huffman tree
   * @param code  The Huffman codes
   */
  /* func createCodes(root: Node, inout code: String) {
    if (root != nil) {
      root.huffCode = code
      if (root.character != 0) {
        if (code == "") {
          code = "0"
        }
        encodingScheme.put(root.character, code)
        huffmanTree = huffmanTree + "0" + root.asciiBinary()
      } else {
        huffmanTree = huffmanTree + "1"
      }
      createCodes(root.left, code + "0")
      createCodes(root.right, code + "1")
    }
  }*/
  
  /**
   * Used to output the Huffman tree. Outputs the tree both visually and as a binary string.
   */
  func printTree() {
    print("")
    print("                 Huffman Tree - Tree Format")
    print("  {charcter}:{number of occurrences - always 0 when decoding}")
    print("")
    // printTreeNode(root, " ")
    print("")
    print("      Huffman Tree - Print as String")
    print("  A single bit with value 1 for each internal node")
    print("  A single bit with value 0, followed by an 8-bit character for each leaf")
    print("")
    print(huffmanTree)
    print("")
  }
  
  /**
   * Called by PrintTree, recursively prints Huffman tree nodes
   * @param node A node in the Huffman tree
   * @param indent    The indentation used when outputting the node
   */
  func printTreeNode(node: Node, inout indent: String) {
    /*if (node != nil) {
      if (node.character == 0) {
        node.character = " " // Add a space to make things align nicely
      }
      print("\(indent) \(node.character) \(node.frequency)")
      indent = indent + "      "
      printTreeNode(node.left, indent)
      printTreeNode(node.right, indent)
    }*/
  }
  
  /**
   * Outputs a table showing the frequencies of occurrence of each ascii character in the string
   */
  func printAsciiCount() {
    print("  ┌───────────────────────────────────────────────────────────────┐")
    print("  │                Input File Character Frequency                 │")
    print("  │                                                               │")
    print("  │   Char      Decimal Hex         Binary            Frequency   │")
    print("  ├───────────────────────────────────────────────────────────────┤")
    for (var i = 0; i < 256; i++) {
      if (asciiCount[i] > 0) {
        var character: Character = " "
        
        if (i > 31) {
          character = decimalToASCIICharacter(UInt8(i))
        }
        print("  │     \(character)\t\t\(i)\t\(i)\t\t\(asBinary(i))\t\t\t\(asciiCount[i])\t│")
      }
    }
    print("  ├───────────────────────────────────────────────────────────────┤")
    print("  │  Total characters:\t\(text.characters.count)\t\t\t\t\t\t\t│" )
    print("  │  Unique characters:\t\(uniqueCharacters)\t\t\t\t\t\t\t│" )
    print("  └───────────────────────────────────────────────────────────────┘")
    
  }
  
  /**
   * Outputs a table showing each ascii character in the string and the Huffman code that has been assigned to it
   */
  func printCodes() {
    print("  ┌───────────────────────────────────────────────────────────────┐")
    print("  │                      Huffman Codes                            │")
    print("  │                                                               │")
    print("  │   Char    Decimal   Hex      Binary              Encoding     │")
    print("  ├───────────────────────────────────────────────────────────────┤")
    
    /*var ascii = 0
    var code = ""
    for (Character character : encodingScheme.keySet()) {
      ascii = (int) character
      code = encodingScheme.get(character)
      if (ascii < 32) {
        character = " "
      }
      
      print("  │ \(character) \(ascii) \(Integer.toHexString(ascii)) \(asBinary(ascii)) \(code) │\n")
    }*/
    print("  └───────────────────────────────────────────────────────────────┘")
  }
  
  
  /**
   * Returns the ASCII decimal value of a Character
   * value represented as an 8-bit binary value and padded with zeroes as needed
   * @param char    The Character
   * @return  The ASCII value of the Character, as a UInt8
   */
  func characterToASCIIDecimal(char: Character) -> UInt8 {
    
    let value = String(char).utf8.first
    
    return UTF8.CodeUnit(value!)
  }
  
  
  /**
   * Converts an ASCII decimal value into a Character
   * @param char    The Character to be converted to binary
   * @return  A string representing the Character's decimal ASCII value, in binary
   */
  func decimalToASCIICharacter(value: UInt8) -> Character {
    return Character(UnicodeScalar(value))
  }
  
  
  /**
   * Converts a Character into a String representation of that Character's ASCII
   * value represented as an 8-bit binary value and padded with zeroes as needed
   * @param char    The Character to be converted to binary
   * @return  A string representing the Character's decimal ASCII value, in binary
   */
  func characterToASCIIBinary(char: Character) -> String {
    var returnValue = String(characterToASCIIDecimal(char), radix: 2)
    
    while (returnValue.characters.count < 8) {
      returnValue = "0" + returnValue
    }
    return returnValue
  }
  
  
  /**
   * Converts an int into a String representation of that int's 8-bit binary value, padding with zeroes as needed
   * @param number    The int to be converted to binary
   * @return  A string representing the binary value of the number
   */
  func asBinary(number: Int) -> String {
    var returnValue = String(number, radix: 2)
    
    while (returnValue.characters.count < 8) {
      returnValue = "0" + returnValue
    }
    return returnValue
  }
  
  /**
   * Outputs the compressed and uncompressed size of the string
   */
  func printCompressionReport() {
    /*var uncompressed: Int = getUnencodedSize()
    var compressed: Int = getEncodedSize()
    
    print("  ┌───────────────────────────────────────────────────────────────┐\n")
    print("  │                      Compression Report                       │\n")
    print("  │                                                               │\n")
    print("  │ Uncompressed size: \(getUnencodedSize()) bits \(getUnencodedSize()) bytes         │\n")
    print("  │ Compressed size  : \(getEncodedSize()) bits \(getEncodedSize()) bytes         │\n")
    print("  └───────────────────────────────────────────────────────────────┘\n")*/
  }
  
  /**
   * Huffman tree Node element, used to build the Huffman tree
   */
  class Node {
    
    var left: Node?
    var right: Node?
    var character: Character?
    var frequency: Int
    var huffCode: String
    
    /**
     * Constructor for the Node class: called from createEncoding(), it allows population of frequency as the
     * array of unassociated leaf nodes is first assembled
     * @param character A character found int he string
     * @param frequency The frequency with which the character appears in the string
     */
    init(character: Character, frequency: Int) {
      self.left = nil
      self.right = nil
      self.character = character
      self.frequency = frequency
      self.huffCode = ""
    }
    
    /**
     * Constructor for the Node class: called from formTree(), it is used to create inner nodes
     * @param left  Left child of the node
     * @param right Right child of the node
     * @param frequency The combined frequency of this node's child nodes
     */
    init(left: Node, right: Node, frequency: Int) {
      self.left = left
      self.right = right
      self.frequency = frequency
      self.huffCode = ""
    }
    
    /**
     * Constructor for the Node class: called from readTree(), it is used when building up a tree from a
     * binary string representation of a Huffman tree and allows the creation of blank nodes
     */
    init() {
      self.left = nil
      self.right = nil
      self.frequency = 0
      self.huffCode = ""
    }
    
    /**
     *
     * @return  The decimal value of the ascii character which the node represents
     */
    func asciiDecimal() -> UInt8 {
      
      let value = String(self.character).utf8.first
      
      return UTF8.CodeUnit(value!)
    }
    
    /**
     *
     * @return  The binary representation of the ascii character which the node represents
     */
    func asciiBinary() -> String {
      var returnValue = String(asciiDecimal(), radix: 2)
      
      while (returnValue.characters.count < 8) {
        returnValue = "0" + returnValue
      }
      return returnValue
    }
    
    /**
     *
     * @return  The hexidecimal value of the ascii character which the node represents
     */
    func asciiHex() -> String {
      return String(asciiDecimal(), radix: 16)
    }
    
  }
  
}