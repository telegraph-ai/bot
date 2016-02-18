$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'api'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'boot'

TYPINGSPEED=40

Bundler.require :default, ENV['RACK_ENV']
Dir[File.expand_path('../../bot/*.rb', __FILE__)].each do |f|
	require f
end