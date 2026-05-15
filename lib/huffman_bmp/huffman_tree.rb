module HuffmanBMP
  class HuffmanTree
    attr_reader :root, :codes

    def initialize(freq_hash)
      @root = build_tree(freq_hash)
      @codes = {}
      build_codes(@root, '', @codes) if @root
    end

    # Кодирование одного байта
    def encode(byte)
      @codes[byte]
    end

    private

    # Построение дерева
    def build_tree(freq)
      nodes = freq.map { |byte, f| HuffNode.new(byte: byte, freq: f) }
      return nil if nodes.empty?
      return nodes.first if nodes.size == 1

      nodes.sort_by! { |n| [n.freq, n.byte || 0] }

      # Из двух узлов с наименьшей частотой создаём новый,
      # повторяем, пока не останется один узел
      while nodes.size > 1
        left = nodes.shift
        right = nodes.shift
        parent = HuffNode.new(byte: nil, freq: left.freq + right.freq, left: left, right: right)

        nodes << parent
        nodes.sort_by! { |n| [n.freq, n.byte || 0] }
      end

      nodes.first
    end

    # Рекурсивное построение кодовой таблицы
    def build_codes(node, prefix, hash)
      if node.leaf?
        hash[node.byte] = prefix.empty? ? '0' : prefix
      else
        build_codes(node.left, prefix + '0', hash)  if node.left
        build_codes(node.right, prefix + '1', hash) if node.right
      end
    end
  end
end
