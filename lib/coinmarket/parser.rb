require 'open-uri'
require 'nokogiri'

class Parser
  attr_reader :data

  def initialize(url)
    @url = url
    @data = []
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
end
