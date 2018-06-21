require 'open-uri'
require 'nokogiri'

# Class который парсит сайт
class Parser
  attr_reader :data, :currency

  def initialize(url)
    @url = url
    @data = []
    @currency = {}
    save_table(url)
  end

  ## Метод сохраняющий всю таблицу с главной страницы
  def save_table(url)
    ## Открываем сайт 'url' с помощью Nokogiri
    ## TODO необходима проверка доступности url
    site = Nokogiri::HTML(open(url))

    ## Находим на сайте таблицу с HTML тэгом 'id=currencies'
    table = site.css('#currencies')

    ## Сохраняем все строки таблицы в rows
    rows = table.css('tr')

    ## Выдергиваем названия
    column_names = rows.shift.css('th').map(&:text)
    ## Выдергиваем значения
    text_all_rows = read_text(rows)
    # Создаем массив из хэшей
    create_hashes(column_names, text_all_rows)
  end

  ## Метод сохраняющий значения таблицы в виде массивов
  ## на вход передаем все строки
  def read_text(rows)
    rows.map do |row|
      row_values = row.css('td').map(&:text)
      row_values.pop(2)
      [*row_values]
    end
  end

  ## Метод который делает массив из хэшей [{название => значение, название => значение}]
  ## на вход передаем названия колонок и значения каждой из считаных строк
  def create_hashes(names, texts)
    texts.each do |row|
      hash = names.zip(row).to_h
      ## Удаляем значение графика
      hash.delete('Price Graph (7d)')
      ## Удаляем пустые элементы
      hash.compact!
      @data << hash
    end
  end

  ## Метод берущий первых 10 названий монет (они динамические)
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

  ## Метод сохраняющий все необходимые значения по названию монеты
  def save_currency(name)
    url = @url + "currencies/#{name}"

    site = Nokogiri::HTML(open(url))
    usd = site.css('#quote_price')

    ## Специфика при работе с монетой EOS
    if name == 'eos'
      btc_eos_xpath = '/html/body/div[2]/div/div[1]/div[5]/div[2]/span[3]/span'
      cap_eos_xpath = '/html/body/div[2]/div/div[1]/div[6]/div[1]/div[1]/div/span[1]/span[1]'
      ## TODO Нужна проверка на наличие таких xpath на странице, иначе прирывать программу

      btc = site.xpath(btc_eos_xpath)
      cap = site.xpath(cap_eos_xpath)
    else
      btc_xpath = '/html/body/div[2]/div/div[1]/div[4]/div[2]/span[3]/span'
      cap_xpath = '/html/body/div[2]/div/div[1]/div[5]/div[1]/div[1]/div/span[1]/span[1]'
      ## TODO Нужна проверка на наличие таких xpath на странице, иначе прирывать программу

      btc = site.xpath(btc_xpath)
      cap = site.xpath(cap_xpath)
    end

    ## Сохраняем в hash массив со значениями монеты
    @currency[name] = [text_to_f(usd), text_to_f(btc), text_to_i(cap)]
  end

  ## Метод преобразующий текст в дробное число
  def text_to_f(text)
    text.text.split.first.to_f
  end

  ## Метод перобразующий текст в число
  def text_to_i(text)
    text.text.split(',').join.to_i
  end
end
