require_relative 'huffman_bmp/version'
require_relative 'huffman_bmp/huffman_node'
require_relative 'huffman_bmp/huffman_tree'
require_relative 'huffman_bmp/bit_stream'
require_relative 'huffman_bmp/bmp'
require_relative 'huffman_bmp/rgb'
require_relative 'huffman_bmp/compressor'

module HuffmanBMP
  class Error < StandardError; end

  # Основной интерфейс сжатия
  def self.compress_file(input_file, output_file = nil, mode: :three_trees)
    header, body = BMPHandler.read(input_file)

    compressed = case mode
    when :three_trees
      compress_three_trees(body)
    when :single_tree
      Compressor.compress(body)
    else
      raise Error, "Неизвестный режим: #{mode}"
    end

    if output_file
      File.write(output_file, compressed)
    end

    {
      original_size: body.bytesize,
      compressed_size: compressed.bytesize,
      ratio: (compressed.bytesize.to_f / body.bytesize * 100).round(2),
      mode: mode
    }
  end

  # Восстановление
  def self.decompress_file(input_file, output_file, header_file: nil)
    # Если передан header_file — берём заголовок оттуда
    header = if header_file
               BMPHandler.read(header_file)[0]
             else
               raise Error, "Необходим header_file для восстановления BMP"
             end

    compressed = File.read(input_file)

    # Определяем режим по сигнатуре
    body = if compressed.start_with?("\x00\x00\x00")  # сигнатура трёх деревьев
             decompress_three_trees(compressed)
           else
             Compressor.decompress(compressed)
           end

    BMPHandler.write(output_file, header, body)
    true
  end

  private

  def self.compress_three_trees(body)
    r, g, b = RGBSplitter.split(body)

    comp_r = Compressor.compress(r)
    comp_g = Compressor.compress(g)
    comp_b = Compressor.compress(b)

    # Сигнатура + длины + данные
    signature = "H3T"  # Huffman 3 Trees
    [signature, comp_r.bytesize, comp_g.bytesize, comp_b.bytesize].pack('A3VVV') +
      comp_r + comp_g + comp_b
  end

  def self.decompress_three_trees(compressed)
    scanner = StringScanner.new(compressed)

    signature = scanner.peek(3)
    raise Error, "Неверная сигнатура" unless signature == "H3T"
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