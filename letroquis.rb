class TrieNode
	def word
		@word
	end

	def valid?
		@valid
	end

	def valid=(valid)
		@valid = valid
	end

	def subnodes
		@subnodes
	end

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
		@subnodes[letter] = TrieNode.new(self, letter) unless @subnodes.key? letter
		@subnodes[letter]
	end
  
	def each_subnode(&block)
		@subnodes.each_value { |n| block.call n }
	end

	def to_s
		word
	end
end

class Trie
  def root
    @root
  end

	def initialize
		@root = TrieNode.new(nil, nil)
	end

	def add(word)
		node = @root
		word.each_char { |char| node = node.add char }
		node.valid = node != @root
	end
  
	def traverse(node, &block)
		block.call node if node != @root
		node.each_subnode { |node| traverse node, &block }
	end

	def each_node(&block)
		traverse @root, &block
	end

  def words(range = nil)
    result = []
    each_node do |node|
      range_ok = !range || range === node.word.length
      result.push node.word if node.valid? && range_ok
    end
    result
  end
  
  def words=(list)
    list.each { |word| add word.chomp }
  end

	def fetch(word)
		node = @root
		word.each_char do |char|
			return nil unless node.subnodes.key? char
			node = node.subnodes[char]
		end
		node
	end

	alias [] fetch

	def include?(word)
		fetch(word) != nil
	end

	def valid?(word)
		node = fetch word
		return false if node == nil
		node.valid?
	end

	def to_s
		words.join ", "
	end
end

class Game
  MAX_COLUMNS = 80
  
  def initialize(filename)
    # Preenche o catálogo de palavras disponíveis em uma árvore Trie
    @catalog = Trie.new
    @catalog.words = File.readlines filename
    # As listas de palavras do jogo
    @selected = []
    @found = []
    @current_word = @catalog.words(4..7).sample
    @shuffled_word = @current_word.chars.shuffle.join
    @word = ""
  end

  # Este método recursivo obtém todos as palavras válidas do catálogo usando como base as letras da palavra escolhida
  def combine(word, letters)
  	node = @catalog[word]
  	# Se a palavra passada como parâmetro não gerar um caminho válido na árvore trie, qualquer cadeia descendente dela
  	# também será inválida
  	return if node == nil
  	@selected.push word if node.valid?
  	letters.each_with_index do |letter, index|
  		new_letters = Array.new(letters)
  		new_letters.delete_at index
  		combine word + letter, new_letters
  	end
  end
  
  def print_board
    cheat = @word == "cacildis!"
    output = ""
    @selected.each do |word|
      if output.length + word.length >= MAX_COLUMNS
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
    print "#{cheat ? @current_word : @shuffled_word}: "
  end
  
  def run
    combine "", @current_word.chars
    @selected.sort!.uniq!
    while @found.length < @selected.length && @word != "sair!"
      # Imprime o tabuleiro
      print_board
    	@word = gets.chomp
    	@found.push @word if @selected.include? @word
    end
  end
end

game = Game.new "palavras.txt"
game.run
