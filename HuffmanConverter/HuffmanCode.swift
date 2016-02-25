//
//  HuffmanCode.swift
//  HuffmanConverter
//
//  Created by David Westgate on 2/25/16.
//  Copyright © 2016 Refabricants. All rights reserved.
//

import Foundation

class HuffmanCode {
  
  var text: String
  var verbose: Bool
  var uniqueCharacters: Int
  var encodingScheme: [Character: String]
  var root: Node
  var huffmanTree: String
  var asciiCount: [Int]
  var decodingIndex: Int
  
  /**
  * @param text      The text to be coded or decoded using Huffman coding
  * @param verbose   Indicates whether the application is running in "verbose" mode or not. Verbose mode is
  *                  triggered when the -v command line parameter has been provided
  * @param inputType Indicates whether the text provided is in binary or ascii format
  */
  func HuffmanCode(text: String, verbose: Bool, inputType: String) {
  this.text = text
  this.verbose = verbose
  this.uniqueCharacters = 0
  this.encodingScheme = new TreeMap<Character, String>()
  this.root = null
  this.huffmanTree = ""
  this.asciiCount = new int[256]
  this.decodingIndex = 0
  
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
  * Encodes the provided ascii text using Huffman coding
  * @return  The Huffman code of the provided ascii text
  */
  func encode() -> String {
  String code
  String compressedMessage = asBinary((int) 'H') + asBinary((int) 'F')
  
  compressedMessage = compressedMessage + huffmanTree
  
  for (var i = 0; i < text.length(); i++) {
  code = encodingScheme.get(text.charAt(i))
  compressedMessage = compressedMessage + code
  }
  
  return compressedMessage
  }
  
  /**
  * Decodes a Huffman coded binary string to ascii
  * @return  The ascii code of the provided Huffman coded binary string
  */
  func decode() -> String {
  String decompressedMessage = ""
  String code
  
  var found = false
  
  while (decodingIndex < text.length()) {
  int i = 0
  for (Character character : encodingScheme.keySet()) {
  code = encodingScheme.get(character)
  if (decodingIndex + code.length() <= text.length()) {
  String a = text.substring(decodingIndex, decodingIndex + code.length())
  if (code.equals(text.substring(decodingIndex, decodingIndex + code.length()))) {
  decodingIndex = decodingIndex + code.length()
  decompressedMessage = decompressedMessage + character
  break
  }
  }
  }
  }
  
  return decompressedMessage
  }
  
  /**
  *
  * @return  The size of the string when saved as an ascii text file
  */
  func getUnencodedSize() -> Int {
    return text.length() * 8
  }
  
  /**
  *
  * @return  The size of the string when saved as a Huffman coded binary file
  */
  func getEncodedSize() -> Int {
  var size = 32 + 16 + huffmanTree.length()
  
  for (var i = 0; i < 256; i++) {
  String code = encodingScheme.get((char) i)
  if (code != null) {
  size = size + asciiCount[i] * encodingScheme.get((char) i).length()
  }
  }
  
  return size
  }
  
  /**
  * Counts the number of occurrences of each ascii character in the ascii string by populating a simple array
  * where the array indexes represent the ascii values of characters in the file.
  */
  func countChars() {
  for (var i = 0; i < text.length(); i++) {
  if (asciiCount[text.charAt(i)] == 0) {
  uniqueCharacters++
  }
  asciiCount[text.charAt(i)]++
  }
  }
  
  /**
  * Builds a Huffman tree and then uses the tree to determine the Huffman codes for each character in the string
  */
  func createEncoding() {
  int[] asciiFrequencies = Arrays.copyOf(asciiCount, asciiCount.length)
  int[] sorted = new int[uniqueCharacters]
  Node[] sortedNodes = new Node[uniqueCharacters]
  int max = 0
  
  for (var i = uniqueCharacters - 1; i >= 0; i--) {
  max = 0
  for (var j = 0; j < asciiFrequencies.length; j++) {
  if (asciiFrequencies[j] > max) {
  max = asciiFrequencies[j]
  sorted[i] = j
  }
  }
  sortedNodes[i] = new Node((char) sorted[i], asciiCount[sorted[i]])
  asciiFrequencies[sorted[i]] = 0
  }
  
  formTree(sortedNodes, 0)
  
  createCodes(root, "")
  
  if (verbose) {
  printTree()
  printCodes()
  }
  }
  
  /**
  * Reads a binary string representing a Huffman tree, builds the Huffman tree described, and then uses the
  * tree to determine the Huffman codes to be used in decoding a string
  */
  func readEncoding() {
  root = new Node()
  readTree(root)
  createCodes(root, "")
  }
  
  /**
  * Recursive method that builds a Huffman tree from a binary string description of that tree
  * @param node  A node in the Huffman tree
  */
  func readTree(Node node) {
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
  }
  
  /**
  * Recursive method that builds a Huffman tree from an array of unassociated nodes
  * @param nodes An array of nodes, each containing a character found in the string along with the frequency with
  *              which it appears in the string
  * @param index The index usd to traverse the array of nodes
  */
  func formTree(Node[] nodes, int index) {
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
  }
  
  /**
  * Given the root of a Huffman tree, traverses the tree to build a table of Huffman codes
  * @param root  The root of the Huffman tree
  * @param code  The Huffman codes
  */
  func createCodes(Node root, String code) {
  if (root != null) {
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
  }
  
  /**
  * Used to output the Huffman tree. Outputs the tree both visually and as a binary string.
  */
  func printTree() {
  print()
  print("                 Huffman Tree - Tree Format")
  print("  {charcter}:{number of occurrences - always 0 when decoding}")
  print()
  printTreeNode(root, "  ")
  print()
  print("      Huffman Tree - Print as String")
  print("  A single bit with value 1 for each internal node")
  print("  A single bit with value 0, followed by an 8-bit character for each leaf")
  print()
  print(huffmanTree)
  print()
  }
  
  /**
  * Called by PrintTree, recursively prints Huffman tree nodes
  * @param node A node in the Huffman tree
  * @param indent    The indentation used when outputting the node
  */
  func printTreeNode(Node node, String indent) {
  if (node != null) {
  if (node.character == 0) {
  node.character = ' ' // Add a space to make things align nicely
  }
  print("%s%s:%d%n", indent, node.character, node.frequency)
  indent = indent + "      "
  printTreeNode(node.left, indent)
  printTreeNode(node.right, indent)
  }
  }
  
  /**
  * Outputs a table showing the frequencies of occurrence of each ascii character in the string
  */
  func printAsciiCount() {
  print("  ┌───────────────────────────────────────────────────────────────┐%n")
  print("  │                 Input File Character Frequency                │%n")
  print("  │                                                               │%n")
  print("  │   Char    Decimal   Hex      Binary               Frequency   │%n")
  print("  ├───────────────────────────────────────────────────────────────┤%n")
  for (var i = 0; i < 256; i++) {
  if (asciiCount[i] > 0) {
  char character = ' '
  
  if (i > 31) {
  character = (char) i
  }
  
  print("  │ %5s%10d%8s%13s%19d       │%n", character, i, Integer.toHexString(i), asBinary(i),
  asciiCount[i])
  }
  }
  print("  ├───────────────────────────────────────────────────────────────┤%n")
  print("  │  Total characters:  %12d                              │%n", text.length())
  print("  │  Unique characters: %12d                              │%n", uniqueCharacters)
  print("  └───────────────────────────────────────────────────────────────┘%n")
  
  }
  
  /**
  * Outputs a table showing each ascii character in the string and the Huffman code that has been assigned to it
  */
  private void printCodes() {
  print("  ┌───────────────────────────────────────────────────────────────┐%n")
  print("  │                      Huffman Codes                            │%n")
  print("  │                                                               │%n")
  print("  │   Char    Decimal   Hex      Binary              Encoding     │%n")
  print("  ├───────────────────────────────────────────────────────────────┤%n")
  
  int ascii = 0
  String code = ""
  for (Character character : encodingScheme.keySet()) {
  ascii = (int) character
  code = encodingScheme.get(character)
  if (ascii < 32) {
  character = ' '
  }
  
  print("  │ %5s%10d%8s%13s%23s   │%n", character, ascii, Integer.toHexString(ascii),
  asBinary(ascii), code)
  }
  print("  └───────────────────────────────────────────────────────────────┘%n")
  }
  
  /**
  * Converts an int into a String representation of that int's 8-bit binary value, padding with zeroes as needed
  * @param number    The int to be converted to binary
  * @return  A string representing the binary value of the number
  */
  public static String asBinary(int number) {
  String returnValue = Integer.toBinaryString(number)
  
  while (returnValue.length() < 8) {
  returnValue = "0" + returnValue
  }
  
  return returnValue
  }
  
  /**
  * Outputs the compressed and uncompressed size of the string
  */
  private void printCompressionReport() {
  int uncompressed = getUnencodedSize()
  int compressed = getEncodedSize()
  
  print("  ┌───────────────────────────────────────────────────────────────┐%n")
  print("  │                      Compression Report                       │%n")
  print("  │                                                               │%n")
  print("  │ Uncompressed size: %15d bits/%7d bytes         │%n", getUnencodedSize(),
  (int) Math.ceil(getUnencodedSize() / 8.0))
  print("  │ Compressed size  : %15d bits/%7d bytes         │%n", getEncodedSize(),
  (int) Math.ceil(getEncodedSize() / 8.0))
  print("  └───────────────────────────────────────────────────────────────┘%n")
  }
  
  /**
   * Huffman tree Node element, used to build the Huffman tree
   */
  struct Node {
    
    private Node left
    private Node right
    private char character
    private int frequency
    private String huffCode
    
    /**
    * Constructor for the Node class: called from createEncoding(), it allows population of frequency as the
    * array of unassociated leaf nodes is first assembled
    * @param character A character found int he string
    * @param frequency The frequency with which the character appears in the string
    */
    public Node(char character, int frequency) {
    this.left = null
    this.right = null
    this.character = character
    this.frequency = frequency
    this.huffCode = ""
    }
    
    /**
    * Constructor for the Node class: called from formTree(), it is used to create inner nodes
    * @param left  Left child of the node
    * @param right Right child of the node
    * @param frequency The combined frequency of this node's child nodes
    */
    public Node(Node left, Node right, int frequency) {
    this.left = left
    this.right = right
    this.frequency = frequency
    this.huffCode = ""
    }
    
    /**
    * Constructor for the Node class: called from readTree(), it is used when building up a tree from a
    * binary string representation of a Huffman tree and allows the creation of blank nodes
    */
    func Node() {
    this.left = null
    this.right = null
    this.frequency = 0
    this.huffCode = ""
    }
    
    /**
    *
    * @return  The decimal value of the ascii character which the node represents
    */
    func asciiDecimal() -> Int {
    return (int) character
    }
    
    /**
    *
    * @return  The binary representation of the ascii character which the node represents
    */
    func asciiBinary() -> String {
    String returnValue = Integer.toBinaryString((int) character)
    
    while (returnValue.length() < 8) {
    returnValue = "0" + returnValue
    }
    return returnValue
    }
    
    /**
    *
    * @return  The hexidecimal value of the ascii character which the node represents
    */
    func asciiHex() -> String {
    return Integer.toHexString((int) character)
    }
    
  }
  
  
}