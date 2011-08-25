Gem::Specification.new do |s|
  s.name      = 'active_cart'
  s.summary     = "Shopping Cart framework gem. Supports 'storage engines' and order total plugins"
  s.description = <<-EOS
    You can use active_cart as the basis of a shopping cart system. It's not a shopping cart application - it's a shopping cart framework.
  EOS
  s.email             = 'myles@madpilot.com.au'
  s.homepage    = "http://gemcutter.org/gems/active_cart"
  s.authors           = ["Myles Eftos"]
  s.version   = '0.0.19'

  s.require_paths     = ['lib']

  s.add_dependency 'state_machine'
  s.add_development_dependency 'redgreen'
  s.add_development_dependency 'shoulda'
  s.add_development_dependency 'mocha'
  s.add_development_dependency 'machinist'
  s.add_development_dependency 'faker'

  s.files = Dir['lib/**/*', 'active_cart.gemspec']
end