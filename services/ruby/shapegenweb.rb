# shapegenweb.rb
require 'sinatra'
require 'yajl'
require './shape_generator'

def standardparams(params)
  sizex = params['sizex'].to_i
  sizey = params['sizey'].to_i  
  if params['iter'] == nil then iter = 1 else iter = params['iter'].to_i end
  cutoff = (params['cutoff'] == nil)
  return sizex, sizey, iter, cutoff
end

get '/shapegenweb/generate' do
  sizex, sizey, iter, cutoff = standardparams(params)
  gen = ShapeGenerator.new(sizex, sizey)
  shape, basenoise = gen.generate_shape(iter, cutoff)
  json = { :shape => shape, :basenoise => basenoise, :sizex => sizex, :sizey => sizey, :iter => iter, :cutoff => cutoff}
  Yajl::Encoder.encode(json)
end

put '/shapegen/shift_and_generate' do
  parser = Yajl::Parser.new
  params = parser.parse(request.body.read)
  sizex, sizey, iter, cutoff = standardparams(params)
  basenoise = params['basenoise']
  gen = ShapeGenerator.new(sizex, sizey)
  shape, basenoise = gen.shift_and_generate(basenoise, iter, cutoff)
  json = { :shape => shape, :basenoise => basenoise, :sizex => sizex, :sizey => sizey, :iter => iter, :cutoff => cutoff}
  Yajl::Encoder.encode(json)
end

get '/shapegenweb' do
  redirect '/shapegenajax.html'
end