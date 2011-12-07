Gem::Specification.new do |s|
  s.name = 'galvinhsiu-active_cart'
  s.summary = "Shopping Cart framework gem. Supports 'storage engines' and order total plugins, forked to use state_machine from active_cart."
  s.description = <<-EOS
    You can use active_cart as the basis of a shopping cart system. It's not a shopping cart application - it's a shopping cart framework. Forked from active_cart and uses state_machine.
  EOS
  s.email = 'myles@madpilot.com.au, galvin.hsiu@gmail.com'
  s.homepage = "http://rubygems.org/gems/galvinhsiu-active_cart"
  s.authors = ["Myles Eftos", "Galvin Hsiu"]
  s.version = '0.0.20'

  s.require_paths = ['lib']

  s.add_dependency 'state_machine'
  s.add_development_dependency 'shoulda'
  s.add_development_dependency 'mocha'
  s.add_development_dependency 'machinist'
  s.add_development_dependency 'faker'

  s.files = Dir['lib/**/*', 'galvinhsiu-active_cart.gemspec']
end