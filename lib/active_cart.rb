$:.unshift(File.join(File.dirname(__FILE__), 'active_cart'))

require 'rubygems'
require 'singleton'
require 'forwardable'
require 'state_machine'
require 'item'
require 'cart_storage'
require 'order_total'
require 'order_total_collection'
require 'cart'

require 'exceptions/out_of_stock'

require 'storage_engines/memory'
require 'items/memory_item'

module ActiveCart
  VERSION = File.exist?('VERSION') ? File.read('VERSION') : ""
end
