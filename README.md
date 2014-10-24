shapegenweb
===========

Browsing through generated terrain on a webpage.

Self-educational and recreational project.

Shape generator originally comes from my [Clouds](https://github.com/bartekkalinka/clouds) game.

Needs: ruby 2.0, sinatra, yajl (+ ruby dev kit on windows), rspec (for unit tests), mongo (+ instance of mongodb)

Run generator script: ruby batchgen.rb

Run webservice: ruby shapegenweb.rb

Client url: http://localhost:4567/shapegenweb

Run tests: rspec tests_and_utils\tests.rb
