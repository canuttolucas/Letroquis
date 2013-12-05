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

	def initialize
		@root = TrieNode.new(nil, nil)
	end

	def add(word)
		node = @root
		word.each_char { |char| node = node.add(char) }
		node.valid = node != @root
	end

	def each_node(&block)
		traverse(@root, &block)
	end

	def words(range = nil)
		result = []
		each_node do |node|
			range_ok = !range || range === node.word.length
			result.push(node.word) if node.valid? && range_ok
		end
		result
	end

	def words=(array)
		array.each { |word| add(word.chomp) }
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
		fetch(word) != nil
	end

	def valid?(word)
		node = fetch(word)
		return false if node == nil
		node.valid?
	end

	def to_s
		words.join(", ")
	end

	private

	def traverse(node, &block)
		block.call(node) if node != @root
		node.each_subnode { |node| traverse(node, &block) }
	end
end

class Game
	MAX_COLUMNS = 80

	def initialize(filename)
		@catalog = Trie.new
		@catalog.words = File.readlines(filename)
		# As listas de palavras
		@selected = []
		@found = []
		@keyword = @catalog.words(4..7).sample
		@shuffled = @keyword.chars.shuffle.join
		# Executa o método de combinação para obter todas as palavras válidas derivadas da selecionada
		combine("", @keyword.chars)
		@selected.sort!.uniq!
		@word = ""
	end

	def run
		while @found.length < @selected.length && @word != "sair!"
			# Imprime o tabuleiro
			print_board
			@word = gets.chomp
			@found.push(@word) if @selected.include?(@word)
		end
	end

	private

	# Este método recursivo obtém todos as palavras válidas do catálogo usando como base as letras da palavra escolhida
	def combine(word, letters)
		# Se a palavra passada como parâmetro não gerar um caminho válido na árvore trie, qualquer cadeia descendente dela
		# também será inválida
		return unless node = @catalog[word]
		@selected.push(word) if node.valid?
		letters.each_with_index do |letter, index|
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
		print "#{cheat ? @keyword : @shuffled}: "
	end
end

game = Game.new "palavras.txt"
game.run
