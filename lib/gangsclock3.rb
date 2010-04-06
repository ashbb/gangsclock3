# RubyLearning Gangs Clock 3 v0.5b
require 'yaml'
require 'menu'
require 'gangsclock'
Shoes.app :title => 'Gangs Clock 3 v0.5b', :width => W, :height => H, :resizable => false do
  extend Menu
  extend GangsClock
  
  @color = blue, green, white
  gangs_clock
end
