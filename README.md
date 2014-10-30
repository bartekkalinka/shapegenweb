shapegenweb
===========

Browsing through generated terrain on a webpage.

Self-educational and recreational project.

Demo: http://ruby-bka.rhcloud.com/index.html

Shape generator originally comes from my [Clouds](https://github.com/bartekkalinka/clouds) game.

Needs: ruby 2.0, sinatra, yajl (+ ruby dev kit on windows), rspec (for unit tests), mongo (+ instance of mongodb)

Run webservice: ruby shapegenweb.rb

Client url: http://localhost:4567/shapegenweb

Generation url: http://localhost:4567/generate.html

Run tests: rspec tests_and_utils\tests.rb
