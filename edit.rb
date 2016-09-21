# 譜面作成用のアプリケーション起動ファイル
#
# 楽曲データ用のディレクトリ、または楽曲データ番号を引数に指定して起動すること
#
#   $ ruby ./edit.rb ./data/music/012_hoge/ #=> OK!
#   $ ruby ./edit.rb 012_hoge               #=> OK!
#   $ ruby ./edit.rb 12                     #=> OK!
#   $ ruby ./edit.rb hoge                   #=> BAD!
#
if ARGV.size != 1
  puts <<-EOS
  Usage:
    ruby ./edit.rb ./data/music/012_music_data_dir/
    ruby ./edit.rb 012_music_data_dir
    ruby ./edit.rb 12
  EOS
  exit
end

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), 'app'))
REINO_OTOGE_EDIT = true
require 'dxruby'
require 'ayame'
require 'reino_otoge'

ReinoOtoge.demo_mode! if ENV['DEMO']
ReinoOtoge.debug_mode! if ENV['DEBUG']
EDIT_SCENE = ReinoOtoge::EditScene.new(ARGV[0])

ReinoOtoge.init
ReinoOtoge.instance_variable_set(:@current_scene, EDIT_SCENE)
Window.loop do
  ReinoOtoge.play
  Window.caption = "ReinoOtoge EDIT #{Window.real_fps}(fps)"
end
