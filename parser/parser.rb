require 'rubygems'
require 'nokogiri'

page = Nokogiri::HTML(open("../list.html"))   
puts page.class   # => Nokogiri::HTML::Document