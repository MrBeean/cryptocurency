# Coinmarket (описание)

Программа для расчета средневзвешенного кросс-курса монеты MNX к $

## Установка

Используемая Ruby версия:

    ruby -v => ruby 2.4.1p111 (2017-03-22 revision 58053) [x86_64-darwin17]
    
Для установки необходимо склониловать репозиторий, создать новый gemset (в нашем случае мы будем использовать RVM).
И запустить bundle

    rvm use 2.4.1@coinmarket --create
    gem install bundler
    bundle

## Использвоание

    ruby coinmarket.rb
