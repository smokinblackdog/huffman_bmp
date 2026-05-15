require_relative 'huffman_bmp/version'
require_relative 'huffman_bmp/huffman_node'
require_relative 'huffman_bmp/huffman_tree'
require_relative 'huffman_bmp/fano_tree'
require_relative 'huffman_bmp/bit_stream'
require_relative 'huffman_bmp/bmp'
require_relative 'huffman_bmp/rgb'
require_relative 'huffman_bmp/compressor'

module HuffmanBMP
  class Error < StandardError; end

  # Основной интерфейс сжатия
  def self.compress_file(input_file, output_file = nil, mode: :three_trees, algorithm: :huffman)
    header, body = BMPHandler.read(input_file)

    compressed = case mode
                 when :three_trees
                   compress_three_trees(body, algorithm: algorithm)
                 when :single_tree
                   Compressor.compress(body, algorithm: algorithm)
                 else
                   raise Error, "Неизвестный режим: #{mode}"
                 end

    File.write(output_file, compressed) if output_file

    {
      original_size: body.bytesize,
      compressed_size: compressed.bytesize,
      ratio: (compressed.bytesize.to_f / body.bytesize * 100).round(2),
      mode: mode,
      algorithm: algorithm
    }
  end

  # Восстановление
  def self.decompress_file(input_file, output_file, header_file: nil)
    header = if header_file
               BMPHandler.read(header_file)[0]
             else
               raise Error, 'Необходим header_file для восстановления BMP'
             end

    compressed = File.read(input_file)

    body = if compressed.start_with?('H3T', 'F3T')
             decompress_three_trees(compressed)
           else
             Compressor.decompress(compressed)
           end

    BMPHandler.write(output_file, header, body)
    true
  end

  private

  def self.compress_three_trees(body, algorithm: :huffman)
    r, g, b = RGBSplitter.split(body)

    comp_r = Compressor.compress(r, algorithm: algorithm)
    comp_g = Compressor.compress(g, algorithm: algorithm)
    comp_b = Compressor.compress(b, algorithm: algorithm)

    signature = case algorithm
                when :huffman then 'H3T'
                when :fano then 'F3T'
                else
                  raise Error, "Неизвестный алгоритм: #{algorithm}"
                end

    [signature, comp_r.bytesize, comp_g.bytesize, comp_b.bytesize].pack('A3VVV') +
      comp_r + comp_g + comp_b
  end

  def self.decompress_three_trees(compressed)
    scanner = StringScanner.new(compressed)

    signature = scanner.peek(3)
    raise Error, 'Неверная сигнатура' unless ['H3T', 'F3T'].include?(signature)
    scanner.pos += 3

    len_r = scanner.peek(4).unpack1('V'); scanner.pos += 4
    len_g = scanner.peek(4).unpack1('V'); scanner.pos += 4
    len_b = scanner.peek(4).unpack1('V'); scanner.pos += 4

    comp_r = scanner.peek(len_r); scanner.pos += len_r
    comp_g = scanner.peek(len_g); scanner.pos += len_g
    comp_b = scanner.peek(len_b); scanner.pos += len_b

    r = Compressor.decompress(comp_r)
    g = Compressor.decompress(comp_g)
    b = Compressor.decompress(comp_b)

    RGBSplitter.merge(r, g, b)
  end
end