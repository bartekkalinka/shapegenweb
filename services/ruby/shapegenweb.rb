# shapegenweb.rb
require 'sinatra'
require 'yajl'
require './shape_generator'

get '/shapegenweb/generate' do
  sizex = params['sizex'].to_i
  sizey = params['sizey'].to_i
  if params['iter'] == nil then iter = 1 else iter = params['iter'].to_i end
  cutoff = (params['cutoff'] == nil)
  gen = ShapeGenerator.new(sizex, sizey)
  shape, basenoise = gen.generate_shape(iter, cutoff)
  json = { :shape => shape, :basenoise => basenoise, :sizex => sizex, :sizey => sizey, :iter => iter, :cutoff => cutoff}
  Yajl::Encoder.encode(json)
end

put '/shapegen/shift_and_generate' do
  puts "sizex: " + params['sizex'].to_s
  puts "basenoise: " + params['basenoise'].to_s
  sizex = params['sizex'].to_i
  sizey = params['sizey'].to_i
  parser = Yajl::Parser.new
  basenoise = parser.parse(params['basenoise']).values
  if params['iter'] == nil then iter = 1 else iter = params['iter'].to_i end
  cutoff = (params['cutoff'] == nil)
  gen = ShapeGenerator.new(sizex, sizey)
  shape, basenoise = gen.shift_and_generate(basenoise, iter, cutoff)
  json = { :shape => shape, :basenoise => basenoise, :sizex => sizex, :sizey => sizey, :iter => iter, :cutoff => cutoff}
  Yajl::Encoder.encode(json)
end

get '/shapegenweb' do
  redirect '/shapegenajax.html'
end