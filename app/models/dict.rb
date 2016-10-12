class Dict < ApplicationRecord
    
    attr_reader :words
    ALL = '/usr/share/dict/words'
    def initialize()
      words = IO.read('/usr/share/dict/words').split("\n")
      words.select!{ |e| e[/[a-zA-Z]+/] == e }
      words.each { |word| REDIS.sadd("wordlist", word.upcase)}
    end

end
