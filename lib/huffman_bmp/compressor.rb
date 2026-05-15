require 'strscan'
require 'json' # для совместимости

module HuffmanBMP
  module Compressor
    ALGORITHMS = {
      huffman: HuffmanTree,
      fano: FanoTree
    }.freeze

    # Формат сжатых данных:
    # [4 байта: исходная длина (uint32, little-endian)]
    # [1 байт: битовый паддинг (0-7)]
    # [2 байта: длина дерева в JSON (uint16)]
    # [дерево в JSON]
    # [сжатые данные]
    def self.compress(data, algorithm: :huffman)
      tree_class = ALGORITHMS[algorithm]
      raise Error, "Неизвестный алгоритм: #{algorithm}" unless tree_class

      freq = data.bytes.tally
      tree = tree_class.new(freq)

      bitstring = data.bytes.map { |b| tree.encode(b) }.join
      packed, padding = BitStream.pack(bitstring)

      # Сериализуем коды в JSON (более переносимый формат)
      tree_json = JSON.generate(tree.codes)

      header = [data.bytesize, padding, tree_json.bytesize].pack('VCv')
      header + tree_json + packed
    end

    def self.decompress(compressed)
      scanner = StringScanner.new(compressed)

      original_len = scanner.peek(4).unpack1('V')
      scanner.pos += 4

      padding = scanner.peek(1).unpack1('C')
      scanner.pos += 1

      tree_len = scanner.peek(2).unpack1('v')
      scanner.pos += 2

      tree_json = scanner.peek(tree_len)
      scanner.pos += tree_len

      # Восстанавливаем коды
      codes = JSON.parse(tree_json)
      # Ключи JSON всегда строки, нужно преобразовать в числа
      codes.transform_keys!(&:to_i)
      reverse = codes.invert

      packed_data = scanner.rest
      bit_length = packed_data.bytesize * 8 - padding
      bitstring = BitStream.unpack(packed_data, bit_length)

      decoded = String.new(capacity: original_len)
      buffer = ''
      bitstring.each_char do |bit|
        buffer << bit
        if reverse.key?(buffer)
          decoded << reverse[buffer].chr
          buffer = ''
          break if decoded.bytesize == original_len
        end
      end
      decoded
    end
  end
end
