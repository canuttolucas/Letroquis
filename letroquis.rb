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
		return if word.empty?
		node = @root
		word.each_char { |char| node = node.add char }
		node.valid = true
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
      in_range = !range || (range && range === node.word.length)
      result.push node.word if node.valid? && in_range
    end
    result
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
		words.to_s
	end
end

@selected = Array.new
@catalog = Trie.new

# Este método recursivo obtém todos as palavras válidas do catálogo usando como base as letras da palavra escolhida
def combine(word, letters)
	node = @catalog[word]
	# Se a palavra passada como parâmetro não gerar um caminho válido na árvore trie, qualquer cadeia descendente dela
	# também será inválida
	return if node == nil
	@selected.push word if node.valid? && @selected.include?(word) == false
	letters.each_with_index do |letter, index|
		new_letters = Array.new(letters)
		new_letters.delete_at index
		combine(word + letter, new_letters)
	end
end

File.readlines("palavras.txt").each do |line|
	@catalog.add line.chomp
end
@current_word = @catalog.words(4..6).sample
combine("", @current_word.chars)
@selected.sort!
@found = []
@shuffled_word = @current_word.chars.shuffle.join(" ")
# Inicia a mecânica do jogo
word = ""
while @found.length < @selected.length && word != "sair!"
  # Imprime o tabuleiro
  cheat = word == "cacildis!"
  columns = 0
  @selected.each do |word|
    columns += word.length + 1
    if columns >= 80
      print "\n"
      columns = 0
    end
  	if cheat || @found.include?(word)
  		print "#{word} "
  	else
  		print ("#" * word.length) + " "
  	end
  end
  if cheat
    print "\n#{@current_word.chars.join(" ")}: "
  else
    print "\n#{@shuffled_word}: "
  end
	word = gets.chomp
	@found << word if @selected.include? word
  print "\n"
end