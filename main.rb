$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), 'app'))
require 'dxruby'
require 'ayame'
require 'reino_otoge'

ReinoOtoge.demo_mode! if ENV['DEMO']
ReinoOtoge.debug_mode! if ENV['DEBUG']

ReinoOtoge.init
Window.loop do
  ReinoOtoge.play
end
