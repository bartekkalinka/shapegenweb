# shapegenweb.rb
require 'sinatra'
require 'yajl'
require './tests_and_utils/utils'
require './core/db_cache'
require './core/terrain_cache'
require './batchgen'

get '/shapegenweb/:x/:y' do
  shape = TerrainCache.get_shape(params['x'].to_i, params['y'].to_i)
  json = { :shape => shape }
  Yajl::Encoder.encode(json)
end

get '/shapegenweb/generate' do
  BatchGenerator.generate([-5, -5], [5, 5])
  'done'
end

get '/shapegenweb' do
  redirect '/index.html'
end