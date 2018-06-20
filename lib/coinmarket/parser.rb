require 'open-uri'
require 'nokogiri'

class Parser
  attr_reader :data, :currency

  def initialize(url)
    @url = url
    @data = []
    @currency = {}
    save_table(url)
  end

  def save_table(url)
    # Открываем сайт 'url' с помощью Nokogiri
    site = Nokogiri::HTML(open(url))

    # Находим на сайте таблицу с HTML тэгом 'id=currencies'
    table = site.css('#currencies')

    # Сохраняем все строки таблицы в rows
    rows = table.css('tr')

    # Выдергиваем названия
    column_names = rows.shift.css('th').map(&:text)
    # Выдергиваем значения
    text_all_rows = read_text(rows)
    # Создаем массив из хэшей
    create_hashes(column_names, text_all_rows)
  end

  # Метод сохраняющий значения таблицы в виде массивов
  # на вход передаем все строки
  def read_text(rows)
    rows.map do |row|
      row_values = row.css('td').map(&:text)
      row_values.pop(2)
      [*row_values]
    end
  end

  # Метод который делает массив из хэшей [{название => значение, название => значение}]
  # на вход передаем названия колонок и значения каждой из считаных строк
  def create_hashes(names, texts)
    texts.each do |row|
      hash = names.zip(row).to_h
      # Удаляем значение графика
      hash.delete('Price Graph (7d)')
      # Удаляем пустые элементы
      hash.compact!
      @data << hash
    end
  end

  def take_ten
    ten = @data[0..9]
    ten.map do |i|
      if i['Name'].split.last.downcase == 'cash'
        'bitcoin-cash'
      else
        i['Name'].split.last.downcase
      end
    end
  end

  def save_currency(name)
    url = @url + "currencies/#{name}"

    site = Nokogiri::HTML(open(url))
    # p site.css('col-xs-6 col-sm-8 col-md-4 text-left')
    usd = site.css('#quote_price')

    if name == 'eos'
      btc = site.xpath('/html/body/div[2]/div/div[1]/div[5]/div[2]/span[3]/span')
      cap = site.xpath('/html/body/div[2]/div/div[1]/div[6]/div[1]/div[1]/div/span[1]/span[1]')
    else
      btc = site.xpath('/html/body/div[2]/div/div[1]/div[4]/div[2]/span[3]/span')
      cap = site.xpath('/html/body/div[2]/div/div[1]/div[5]/div[1]/div[1]/div/span[1]/span[1]')
    end

    @currency[name] = [usd.text.split.first.to_f, btc.text.split.first.to_f, cap.text.split(',').join.to_i]
  end
end
