### Description
This is a Swift program that compresses and uncompresses files using Huffman coding. It is an adaptation of a program originally written in Java for CS245 at USF taught by the great Professor David Galles.

### Compressing an ASCII file
To compress a file the program performs the following steps:

1. Reads in the entire input file, and calculate the frequencies of all characters
2. Builds a Huffman tree for all characters that appear in the input file
3. Builds a lookup table that contains the codes for all the characters in the input file
4. Checks to see if the compressed file is smaller than the original file.
  - If it is not, the program will not perform any compression, but instead print out a message indicating that the file cannot be compressed
  - If it can be compressed, the program will create the encoded file:
  1. It will first write a 32-bit "filesize" header to the file (zero, initially)
  2. It will first write a Magic Number ("HF"), that will be used to guard against uncompressing files that we didn't compress
  3. It will then write the Huffman tree to the output file
  4. It will use the lookup table to write out the encoded file
  5. Before closing the file it will re-write the initial "filesize" header from step one, this time with the actual number of meaningful bits in the file

### Uncompressing a binary file
To uncompress a file, the program performs the following steps:
1. Reads in the 32-bit "filesize" value, representing the number of meaningful bits in the file
2. Reads in the Magic Number ("HF"), and make sure that it matches the number for the this program (exiting with an error if it does not match)
3. Reads in the Huffman tree from the input file
4. Decodes the input, using the Huffman tree
5. Writes the file back out as a new plain text file

### Flags
If the program is called with the "verbose" flag (-v), it will also output debugging information. If it is called with the "force" flag (-f), it will be compressed even if the compressed file would be larger than the original file.

### Usage
    $ HuffmanConverter (-c|-u) [-v] [-f]  infile outfile
where:
- (-c|-u) stands for either '-c' (for encode), or '-u' (for uncompress)
- [-v] stands for an optional '-v' flag (for verbose)
- [-f] stands for an optional '-f' flag, that forces compression even if the compressed file will be larger than the original file
- infile is the input file
- outfile is the output file

The flags -f and -v can be in either order.

#### Examples:

    HuffmanConverter -c test test.huff
    HuffmanConverter -c -v myTestFile myCompressedFile
    HuffmanConverter -c -f -v test test.huff
    HuffmanConverter -u -f test1.huff test2
    HuffmanConverter -u -f -v test1.huff test2
