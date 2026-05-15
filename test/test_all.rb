#!/usr/bin/env ruby

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'huffman_bmp'

IMAGE_DIR = File.expand_path('../bmps', __dir__)
ALGORITHMS = {
  'Хаффман' => :huffman,
  'Фано' => :fano
}.freeze

images = Dir.children(IMAGE_DIR)
            .grep(/\.bmp\z/i)
            .sort
            .map { |name| File.join(IMAGE_DIR, name) }

if images.empty?
  puts "Файлы в #{IMAGE_DIR}/ не найдены"
  exit
end

summary_rows = []
channel_rows = []

images.each do |image|
  image_name = File.basename(image, '.bmp')
  _, body = HuffmanBMP::BMPHandler.read(image)
  r, g, b = HuffmanBMP::RGBSplitter.split(body)

  ALGORITHMS.each do |algorithm_name, algorithm_key|
    ratio_by_channels = HuffmanBMP.compress_file(image, nil, mode: :three_trees, algorithm: algorithm_key)[:ratio]
    ratio_single_tree = HuffmanBMP.compress_file(image, nil, mode: :single_tree, algorithm: algorithm_key)[:ratio]

    best_ratio = [ratio_by_channels, ratio_single_tree].min
    best_type = ratio_by_channels <= ratio_single_tree ? 'По каналам' : 'Одно дерево'

    summary_rows << {
      file: image_name,
      algorithm: algorithm_name,
      ratio_by_channels: ratio_by_channels,
      ratio_single_tree: ratio_single_tree,
      best_ratio: best_ratio,
      best_type: best_type
    }

    { 'r' => r, 'g' => g, 'b' => b }.each do |channel_name, channel_data|
      compressed_channel = HuffmanBMP::Compressor.compress(channel_data, algorithm: algorithm_key)
      channel_ratio = (compressed_channel.bytesize.to_f / channel_data.bytesize * 100).round(2)

      channel_rows << {
        file: image_name,
        algorithm: algorithm_name,
        channel: channel_name,
        original_size: channel_data.bytesize,
        size: compressed_channel.bytesize,
        ratio: channel_ratio
      }
    end
  end
end

puts "Найдено #{images.size} BMP файл(ов)\n\n"

puts '-' * 132
puts "%-30s %-12s %18s %19s %14s %-14s" % ['Файл', 'Алгоритм', 'Коэф по каналам', 'Коэф одного дерева', 'Лучший', 'результат']
puts '-' * 132
summary_rows.each do |row|
  puts "%-30s %-12s %16.2f%% %17.2f%% %12.2f%% %-14s" % [
    row[:file][0..29],
    row[:algorithm],
    row[:ratio_by_channels],
    row[:ratio_single_tree],
    row[:best_ratio],
    row[:best_type]
  ]
end
puts '-' * 132

puts
puts '-' * 108
puts "%-30s %-14s %-8s %14s %14s %16s" % ['Файл', 'Алгоритм', 'Канал', 'Размер до', 'Размер после', 'Коэф сжатия']
puts '-' * 108
channel_rows.each do |row|
  puts "%-30s %-14s %-8s %14d %14d %14.2f%%" % [
    row[:file][0..29],
    row[:algorithm],
    row[:channel],
    row[:original_size],
    row[:size],
    row[:ratio]
  ]
end
puts '-' * 108