shapegenweb
===========

Browsing through generated terrain on a webpage.

Self-educational and recreational project.

Scala version
===========
Scala rewrite started in February 2015.  It introduced better approach to scaling tiles - dividing them in place, changing their size.  It also works faster then Ruby version, so more scaling/smoothing phases were possible.

Run service: sbt run

Client url: http://localhost:8080/index.html

Ruby version
===========

Ruby version was the original version written from July till October 2014.  Shape generator originally comes from my [Clouds](https://github.com/bartekkalinka/clouds) game.  The algorithm involves scaling and smoothing random pattern.  Scaling works on fragments of base random number 2-dimensional table, with constant tile size.

Demo: http://ruby-bka.rhcloud.com/index.html

Needs: ruby 2.0, sinatra, yajl (+ ruby dev kit on windows), rspec (for unit tests), mongo (+ instance of mongodb)

Run webservice: ruby shapegenweb.rb

Client url: http://localhost:4567/shapegenweb

Generation url: http://localhost:4567/generate.html

Run tests: rspec tests_and_utils\tests.rb
