# Mixin this module into the class you want to use as your storage class. Remember to override the invoice_id method
#
module ActiveCart
  # The CartStorage object uses a state machine to track the state of the cart. The default states are: shopping, checkout, verifying_payment, completed, failed. It exposed the following transitions:
  # continue_shopping, checkout, check_payment, payment_successful, payment_failed
  #
  #   @cart.checkout! # transitions from shopping, verifying_payment or failed to checkout
  #   @cart.check_payment! # transistions from checkout to verifying_payment
  #   @cart.payment_successful! # transitions from verifying_payment to completed
  #   @cart.payment_failed! # transitions from verifying_payment to failed
  #   @cart.continue_shopping # transitions from checkout, verifying_payment or failed to shopping
  #   
  #   It will fire before_ and after callbacks with the same name as the transitions
  #
  module CartStorage
    def self.included(base) #:nodoc:

      base.state_machine :state, :initial => :shopping do

        event :continue_shopping do
          transition [ :checkout, :verifying_payment, :failed ] => :shopping
        end

        event :checkout do
          transition [ :shopping, :verifying_payment, :failed ] => :checkout
        end

        event :check_payment do
          transition :checkout => :verifying_payment
        end

        event :payment_successful do
          transition :verifying_payment => :completed
        end

        event :payment_failed do
          transition :verifying_payment => :failed
        end

        state :shopping
        state :checkout
        state :verifying_payment
        state :completed
        state :failed
      end
    end

    # Returns the unique invoice_id for this cart instance. This MUST be overriden by the concrete class this module is mixed into, otherwise you
    # will get a NotImplementedError
    #
    def invoice_id
      raise NotImplementedError
    end

    # Returns the sub-total of all the items in the cart. Usually returns a float.
    #
    #   @cart.sub_total # => 100.00
    #
    def sub_total
      inject(0) { |t, item| t + (item.quantity * item.price.to_f)  }
    end

    # Returns the number of items in the cart. It takes into account the individual quantities of each item, eg if there are 3 items in the cart, each with a quantity of 2, this will return 6
    #
    def quantity
      inject(0) { |t, item| t + item.quantity }
    end

    # Adds an item to the cart. If the item already exists in the cart (identified by the id of the item), then the quantity will be increased but the supplied quantity (default: 1)
    #
    #   @cart.add_to_cart(item, 5)
    #   @cart.quantity # => 5
    #
    #   @cart.add_to_cart(item, 2)
    #   @cart.quantity # => 7
    #   @cart[0].quantity # => 7
    #   @cart[1] # => nil
    #
    #   @cart.add_to_cart(item_2, 4)
    #   @cart.quantity => 100
    #   @cart[0].quantity # => 7
    #   @cart[1].quantity # => 4
    #
    def add_to_cart(item, quantity = 1, options = {})
      if self.include?(item)
        index = self.index(item)
        self.at(index).quantity += quantity
      else
        item.quantity += quantity
        self << item
      end
    end

    # Removes an item from the cart (identified by the id of the item). If the supplied quantity is greater than equal to the number in the cart, the item will be removed, otherwise the quantity will simply be decremented by the supplied amount
    #
    #   @cart.add_to_cart(item, 5)
    #   @cart[0].quantity # => 5
    #   @cart.remove_from_cart(item, 3)
    #   @cart[0].quantity # => 2
    #   @cart.remove_from_cart(item, 2)
    #   @cart[0] # => nil
    #   
    #   @cart.add_to_cart(item, 3)
    #   @cart[0].quantity # => 3
    #   @cart_remove_from_cart(item, :all)
    #   @cart[[0].quantity # => 0
    def remove_from_cart(item, quantity = 1, option = {})
      if self.include?(item)
        index = self.index(item)
        
        quantity = self.at(index).quantity if quantity == :all

        if (existing = self.at(index)).quantity - quantity > 0
          existing.quantity = existing.quantity - quantity
        else
          self.delete_at(index)
        end
      end
    end
  end
end
