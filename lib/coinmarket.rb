require_relative "coinmarket/parser"

module Coinmarket
  def self.run
    Parser.new('https://coinmarketcap.com/')
  end
end



result = Coinmarket.run
puts result.data[1] # Ожидается вывод Ethereum