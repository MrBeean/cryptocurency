require_relative "coinmarket/parser"
require_relative "coinmarket/calculator"

module Coinmarket
  def self.run
    Parser.new('https://coinmarketcap.com/')
  end
end



parser = Coinmarket.run
names = parser.take_ten
names << 'minexcoin'
names.each do |name|
  parser.save_currency(name)
end
minexcoin_cap = parser.currency['minexcoin'][1]
calculator = Calculator.new(parser.currency)
calculator.average(minexcoin_cap)
puts "Средневзвешенный кросс-курс MNX/$ = #{calculator.summ}"
