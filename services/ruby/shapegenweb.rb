# shapegenweb.rb
require 'sinatra'
require 'yajl'
require './shape_generator'

get '/shapegenweb/generate' do
  sizex = params['sizex'].to_i
  sizey = params['sizey'].to_i
  gen = ShapeGenerator.new(sizex, sizey)
  gen.generate
  json = { :shape => gen.shape, :sizex => sizex, :sizey => sizey }
  Yajl::Encoder.encode(json)
end

get '/shapegenweb' do
  redirect '/shapegenajax.html'
end