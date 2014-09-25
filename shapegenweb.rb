# shapegenweb.rb
require 'sinatra'
require 'yajl'
require './utils'
require './shape_generator'

include Timing

def standardparams(params)
  sizex = params['sizex'].to_i
  sizey = params['sizey'].to_i  
  if params['iter'] == nil then iter = 1 else iter = params['iter'].to_i end
  cutoff = (params['cutoff'] == nil)
  return sizex, sizey, iter, cutoff
end

get '/shapegenweb/generate' do
  sizex, sizey, iter, cutoff = standardparams(params)
  gen = ShapeGenerator.new({})
  shape, basenoise = gen.generate_shape(sizex, sizey, iter, cutoff)
  json = { :shape => shape, :basenoise => basenoise, :sizex => sizex, :sizey => sizey, :iter => iter, :cutoff => cutoff}
  Yajl::Encoder.encode(json)
end

put '/shapegen/shift_and_generate' do
  timing_before = timing
  parser = Yajl::Parser.new
  params = parser.parse(request.body.read)
  sizex, sizey, iter, cutoff = standardparams(params)
  direction = params['direction']
  basenoise = params['basenoise']
  timingTab = params['timing']
  timingTab["server receive"] = timing_before
  timingTab["server parse"] = timing
  gen = ShapeGenerator.new(timingTab)
  shape, basenoise = gen.shift_and_generate(basenoise, direction.to_sym, iter, cutoff)
  timingTab["server generate"] = timing
  json = { :shape => shape, :basenoise => basenoise, :sizex => sizex, :sizey => sizey, :iter => iter, :cutoff => cutoff, :timing => timingTab }
  Yajl::Encoder.encode(json)
end

get '/shapegenweb' do
  redirect '/shapegenajax.html'
end