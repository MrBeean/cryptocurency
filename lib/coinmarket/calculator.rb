# Class который содержит математические вычисления
class Calculator
  attr_reader :summ

  def initialize(currency)
    @summ = 0
    @currency = currency
    @cap_sum = calculate_cap_sum
  end

  ## Метод расчитывающий средневзвешенный курс minexcoin
  def average(minexcoin)
    sum = []
    @currency.each_value do |value|
      sum << (value[0]/value[1])*(value[2].to_f/@cap_sum)
    end

    @summ = minexcoin*sum.sum
  end

  ## Метод для расчета суммы всех Market Cap
  def calculate_cap_sum
    all_cap = []
    @currency.delete('minexcoin')
    @currency.each_value do |value|
      all_cap << value[2]
    end

    @cap_sum = all_cap.sum
  end
end
