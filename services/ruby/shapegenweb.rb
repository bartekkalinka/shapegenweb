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
  gen.generate(iter, cutoff)
  json = { :shape => gen.shape, :sizex => sizex, :sizey => sizey, :iter => iter, :cutoff => cutoff}
  Yajl::Encoder.encode(json)
end

get '/shapegenweb' do
  redirect '/shapegenajax.html'
end