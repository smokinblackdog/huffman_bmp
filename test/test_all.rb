#!/usr/bin/env ruby

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require 'huffman_bmp'

IMAGE_DIR = File.join(__dir__, '..', 'bmps')

images = Dir.glob("#{IMAGE_DIR}/*.bmp")

if images.empty?
  puts "Файлы в #{IMAGE_DIR}/ не найдены"
  exit
end

puts "Найдено #{images.size} BMP файл(ов)\n\n"
puts "=" * 80
puts "%-30s %10s %12s %12s %10s" % ['Файл', 'Размер', '3 дерева', '1 дерево', 'Лучший результат']
puts "-" * 80

images.each do |image|
  name = File.basename(image, '.bmp')
  r3 = HuffmanBMP.compress_file(image, nil, mode: :three_trees)
  r1 = HuffmanBMP.compress_file(image, nil, mode: :single_tree)
  
  best = [r3[:ratio], r1[:ratio]].min
  
  puts "%-30s %10d %10.1f%% %10.1f%% %10.1f%%" % [
    name[0..29],
    r3[:original_size],
    r3[:ratio],
    r1[:ratio],
    best
  ]
end

puts "-" * 80