# shapegenweb.rb
require 'sinatra'
require 'yajl'
require './shape_generator'

get '/shapegenweb' do
  sizex = params['sizex'].to_i
  sizey = params['sizey'].to_i
  gen = ShapeGenerator.new(sizex, sizey, true)
  json = { :shape => gen.shape, :sizex => sizex, :sizey => sizey }
  Yajl::Encoder.encode(json)
end