require 'active_record'
require 'aasm'
#require 'aasm/persistence/active_record_persistence'

module ActiveCart
  # acts_as_cart - Turns an ActiveRecord model in to a cart. It can take a hash of options
  #
  # state_column: The database column that stores the persistent state machine state. Default: state
  # invoice_id_column: The column that stores the invoice id. Default: invoice_id
  # cart_items: The model that represents the items for this cart. Is associated as a has_many. Default: cart_items
  # order_totals: The model that represents order totals for this cart. It is associated as a has_many. Default: order_totals
  #
  #   class Cart < ActiveModel::Base
  #     acts_as_cart
  #   end
  #
  # The only two columns that are required for a cart model are the state_column and invoice_id_column
  #
  # You can create custom acts_as_state_machine (aasm) states and events after declaring acts_as_cart
  #
  module Acts
    module Cart
      def self.included(mod)
        mod.extend(ClassMethods)
      end

      module ClassMethods
        def acts_as_cart(options = {})
          cattr_accessor :aac_config
          
          self.aac_config = {
            :state_column => :state,
            :invoice_id_column => :invoice_id,
            :cart_items => :cart_items,
            :order_totals => :order_totals
          }

          self.aac_config.merge!(options)

          class_eval do
            #include AASM::Persistence::ActiveRecordPersistence
            include ActiveCart::CartStorage

            def invoice_id
              read_attribute(self.aac_config[:invoice_id_column])
            end
            
            def state
              read_attribute(self.aac_config[:state_column])
            end
          end
         
          aasm_column self.aac_config[:state_column]

          has_many self.aac_config[:cart_items]
          has_many self.aac_config[:order_totals]

          extend Forwardable
          def_delegators self.aac_config[:cart_items], :[], :<<, :[]=, :at, :clear, :collect, :map, :delete, :delete_at, :each, :each_index, :empty?, :eql?, :first, :include?, :index, :inject, :last, :length, :pop, :push, :shift, :size, :unshift
        end
      end
    end

    # acts_as_cart_item - Sets up an ActiveModel as an cart item.
    #
    # Cart Items are slightly different to regular items (that may be created in a backend somewhere). When building shopping carts, one of the problems when building
    # shopping carts is how to store the items associated with a particular invoice. One method is to serialize Items and storing them as a blob. This causes problem if
    # the object signature changes, as you won't be able to deserialize an object at a later date. The other option is to duplicate the item into another model
    # which is the option acts_as_cart takes (ActiveCart itself can do either, by using a storage engine that supports the serialization option). As such, carts based
    # on act_as_cart will need two tables, most likely named items and cart_items. In theory, cart_items only needs the fields required to fulfill the requirements of
    # rendering an invoice (or general display), but it's probably easier to just duplicate the fields. The cart_items will also require a cart_id and a quantity field
    # acts_as_cart uses the 'original' polymorphic attribute to store a reference to the original Item object. The compound attribute gets nullified if the original Item gets
    # deleted.
    #
    # For complex carts with multiple item types, you will probably need to use STI, as it's basically impossible to use a polymorphic relationship (If someone can
    # suggest a better way, I'm all ears). That said, there is no easy way to model complex carts, so I'll leave this as an exercise for the reader.
    #
    # Options:
    #
    # cart: The cart model. Association as a belongs_to. Default: cart
    # quantity_column: The column that stores the quantity of this item stored in the cart. Default: quantity
    # name_column: The column that stores the name of the item. Default: name
    # price_column: The column that stores the price of the item. Default: price
    # foreign_key: The column that stores the reference to the cart. Default: [cart]_id (Where cart is the value of the cart option)
    #
    #   class Item < ActiveModel::Base
    #     acts_as_item
    #   end
    #
    module Item
      def self.included(mod)
        mod.extend(ClassMethods)
      end

      module ClassMethods
        def acts_as_cart_item(options = {})
          cattr_accessor :aaci_config
          
          self.aaci_config = {
            :cart => :cart,
            :quantity_column => :quantity,
            :name_column => :name,
            :price_column => :price
          }
          self.aaci_config.merge!(options)
          self.aaci_config[:foreign_key] = (self.aaci_config[:cart].to_s + "_id").to_sym unless options[:foreign_key]

          class_eval do
            include ActiveCart::Item
          
            def id
              read_attribute(:id)
            end

            def name
              read_attribute(self.aaci_config[:name_column])
            end

            def quantity
              read_attribute(self.aaci_config[:quantity_column])
            end 

            def quantity=(quantity)
              write_attribute(self.aaci_config[:quantity_column], quantity)
            end

            def price
              read_attribute(self.aaci_config[:price_column])
            end
          end

          belongs_to self.aaci_config[:cart], :foreign_key => self.aaci_config[:foreign_key]
          belongs_to :original, :polymorphic => true
        end
      end
    end

    # acts_as_order_total - Turns an ActiveModel into an order_total store.
    #
    # In the same way there is a seperation between items and cart_items, there is a difference between concrete order_total objects and this order_total store.
    # This model acts as a way of archiving the order total results for a given cart, so an invoice can be retrieved later. It doesn't matter if the concrete order_total
    # object is an ActiveModel class or not, as long as it matches the api
    #
    # Options:
    #
    # cart: The cart model. Association as a belongs_to. Default: cart
    # name_column: The column that stores the name of the item. Default: name
    # price_column: The column that stores the price of the item. Default: price
    # foreign_key: The column that stores the reference to the cart. Default: [cart]_id (Where cart is the value of the cart option)
    #
    #   class OrderTotal < ActiveModel::Base
    #     acts_as_order_total
    #   end
    #
    module OrderTotal
      def self.included(mod)
        mod.extend(ClassMethods)
      end

      module ClassMethods
        def acts_as_order_total(options = {})
          cattr_accessor :aaot_config
          
          self.aaot_config = {
            :cart => :cart,
            :quantity_column => :quantity,
            :name_column => :name,
            :price_column => :price
          }
          self.aaot_config.merge!(options)
          self.aaot_config[:foreign_key] = (self.aaci_config[:cart].to_s + "_id").to_sym unless options[:foreign_key]

          class_eval do
            include ActiveCart::Item
          
            def id
              read_attribute(:id)
            end

            def name
              read_attribute(self.aaci_config[:name_column])
            end

            def price
              read_attribute(self.aaci_config[:price_column])
            end
          end

          belongs_to self.aaci_config[:cart], :foreign_key => self.aaci_config[:foreign_key]
        end
      end
    end
  end
end

ActiveRecord::Base.class_eval do
  include ActiveCart::Acts::Cart
  include ActiveCart::Acts::Item
  include ActiveCart::Acts::OrderTotal
end
