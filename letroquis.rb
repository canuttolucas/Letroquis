class String
  def shuffle
    self.chars.shuffle.join
  end
end

class TrieNode
  attr_reader :valid, :word, :subnodes
  attr_writer :valid

  alias valid? valid

  def initialize(supernode, letter)
    @subnodes = {}
    @supernode = supernode
    if supernode && supernode.word
      @word = supernode.word + letter
    else
      @word = letter
    end
    @valid = false
  end

  def add(letter)
    @subnodes[letter] = TrieNode.new(self, letter) unless @subnodes.key?(letter)
    @subnodes[letter]
  end

  def each_subnode(&block)
    @subnodes.each_value { |node| block.call(node) }
  end

  def to_s
    word
  end
end

class Trie
  attr_reader :root

  def words(range = nil)
    result = []
    each do |node|
      range_ok = range.nil? || range === node.word.length
      result.push(node.word) if node.valid? && range_ok
    end
    result
  end

  def words=(array)
    array.each { |word| add(word.chomp.downcase) }
  end

  def initialize
    @root = TrieNode.new(nil, nil)
  end

  def add(word)
    node = @root
    word.each_char { |char| node = node.add(char) }
    node.valid = node != @root
  end

  def each(&block)
    traverse(@root, &block)
  end

  def fetch(word)
    node = @root
    word.each_char do |char|
      return nil unless node.subnodes.key?(char)
      node = node.subnodes[char]
    end
    node
  end

  alias [] fetch

  def include?(word)
    !fetch(word).nil?
  end

  def valid?(word)
    node = fetch(word)
    return false if node.nil?
    node.valid?
  end

  def to_s
    words.join(", ")
  end

  private

  def traverse(node, &block)
    block.call(node) unless node == @root
    node.each_subnode { |node| traverse(node, &block) }
  end
end

class Game
  MAX_COLUMNS = 78
  LENGTH_RANGE = 4..7
  SELECTED_RANGE = 10..15

  def initialize(filename)
    @catalog = Trie.new
    @catalog.words = File.readlines(filename)
    # As listas de palavras
    @found = []
    pool = @catalog.words(LENGTH_RANGE)
    begin
      @keyword = pool.sample
      # Executa o método de combinação para obter todas as palavras derivadas válidas
      @selected = []
      combine("", @keyword.chars)
      @selected.uniq!
    end until SELECTED_RANGE === @selected.length
    @shuffled = @keyword.shuffle
    @selected.sort!
    @word = ""
  end

  def run
    while @found.length < @selected.length && @word != "sair!"
      # Imprime o tabuleiro
      print_board
      @word = gets.chomp.downcase
      @found.push(@word) if @selected.include?(@word) && !@found.include?(@word)
    end
  end

  private

  # Este método recursivo obtém todas as palavras válidas do catálogo usando como base as letras da palavra escolhida
  def combine(word, letters)
    # Se a palavra passada como parâmetro não gerar um caminho válido na árvore trie, qualquer cadeia descendente dela
    # também será inválida e a recursão deste ramo deve ser encerrada
    node = @catalog[word]
    return if node.nil?
    @selected.push(node.word) if node.valid?
    letters.each.with_index do |letter, index|
      new_letters = Array.new(letters)
      new_letters.delete_at(index)
      combine(word + letter, new_letters)
    end
  end

  def print_board
    cheat = @word == "cacildis!"
    output = ""
    @selected.each do |word|
      if output.length + word.length > MAX_COLUMNS
        print "#{output}\n"
        output.clear
      end
      if cheat || @found.include?(word)
        output << word
      else
        output << "#" * word.length
      end
      output << " "
    end
    print "#{output}\n"
    print "#{cheat ? @keyword : @shuffled}: "
  end
end

game = Game.new("palavras.txt")
game.run
