require_relative 'lib/huffman_bmp/version'

Gem::Specification.new do |spec|
  spec.name          = "huffman_bmp"
  spec.version       = HuffmanBMP::VERSION
  spec.authors       = ["Irina Grigorian"]
  spec.email         = ["irigorian@sfedu.ru"]

  spec.summary       = "compression of 24-bit BMF using Huffman code"
  spec.description   = "a Ruby gem for compressing and decompressing 24-bit BMP images 
    using the Huffman coding algorithm."
  spec.homepage      = "https://github.com/smokinblackdog/huffman_bmp"
  spec.license       = "MIT"

  spec.required_ruby_version = ">= 2.7.0"

  spec.files         = Dir["lib/**/*.rb", "bin/*", "LICENSE.txt"]
  spec.require_paths = ["lib"]
end