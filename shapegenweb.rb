# shapegenweb.rb
require 'sinatra'
require 'yajl'
require './tests_and_utils/utils'
require './core/shape_generator'
require './core/terrain_cache'

include Timing

get '/shapegenweb/generate' do
  # call generator
  shape, basenoise = TerrainCache.generate(params['size'].to_i)
  # encode response
  json = { :shape => shape, :basenoise => basenoise}
  Yajl::Encoder.encode(json)
end

put '/shapegen/shift_and_generate' do
  # read request parameters
  parser = Yajl::Parser.new
  params = parser.parse(request.body.read)
  direction = params['direction']
  basenoise = params['basenoise']
  Timing.timingTab = params['timing']
  # timing
  log_timing("server parse")
  # call generator
  shape, basenoise = TerrainCache.shift_and_generate(basenoise, direction.to_sym)
  # timing
  log_timing("server get shape")
  # encode response
  json = { :shape => shape, :basenoise => basenoise, :timing => Timing.timingTab }
  Yajl::Encoder.encode(json)
end

get '/shapegenweb' do
  redirect '/movingterrain.html'
end