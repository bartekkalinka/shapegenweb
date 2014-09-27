# shapegenweb.rb
require 'sinatra'
require 'yajl'
require './tests_and_utils/utils'
require './core/shape_generator'
require './core/terrain_cache'

include Timing

def standardparams(params)
  sizex = params['sizex'].to_i
  sizey = params['sizey'].to_i  
  if params['iter'] == nil then iter = 1 else iter = params['iter'].to_i end
  cutoff = (params['cutoff'] == nil)
  return sizex, sizey, iter, cutoff
end

get '/shapegenweb/generate' do
  # read request parameters
  sizex, sizey, iter, cutoff = standardparams(params)
  # call generator
  shape, basenoise = TerrainCache.generate(sizex, sizey, iter, cutoff)
  # encode response
  json = { :shape => shape, :basenoise => basenoise, :sizex => sizex, :sizey => sizey, :iter => iter, :cutoff => cutoff}
  Yajl::Encoder.encode(json)
end

put '/shapegen/shift_and_generate' do
  # timing
  timing_before = timing
  # read request parameters
  parser = Yajl::Parser.new
  params = parser.parse(request.body.read)
  sizex, sizey, iter, cutoff = standardparams(params)
  direction = params['direction']
  basenoise = params['basenoise']
  timingTab = params['timing']
  # timing
  timingTab["server receive"] = timing_before
  timingTab["server parse"] = timing
  # call generator
  shape, basenoise = TerrainCache.shift_and_generate(basenoise, direction.to_sym, iter, cutoff, timingTab)
  # timing
  timingTab["server generate"] = timing
  # encode response
  json = { :shape => shape, :basenoise => basenoise, :sizex => sizex, :sizey => sizey, :iter => iter, :cutoff => cutoff, :timing => timingTab }
  Yajl::Encoder.encode(json)
end

get '/shapegenweb' do
  redirect '/movingterrain.html'
end