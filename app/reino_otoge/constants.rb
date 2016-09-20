module ReinoOtoge
  ROOT_DIR = File.absolute_path(File.join(File.dirname(__FILE__), '..', '..'))
  DATA_DIR = File.join(ROOT_DIR, 'data')
  IMAGE_DIR = File.join(DATA_DIR, 'images')
  MUSIC_DIR = File.join(DATA_DIR, 'music')
  IDOL_DIR = File.join(DATA_DIR, 'idol')
  SOUND_DIR = File.join(DATA_DIR, 'sound')
  CUSTOM_DIR = File.join(ROOT_DIR, 'customize')
  CUSTOM_IMAGE_DIR = File.join(CUSTOM_DIR, 'images')
  CUSTOM_MUSIC_DIR = File.join(CUSTOM_DIR, 'music')
  CUSTOM_IDOL_DIR = File.join(CUSTOM_DIR, 'idol')
  CUSTOM_SOUND_DIR = File.join(CUSTOM_DIR, 'sound')
  CONFIG_DIR = File.join(ROOT_DIR, 'config')
  WINDOW_WIDTH = 650
  WINDOW_HEIGHT = 480
  DEFAUTL_SPEED = 5
  KEY_SPACING = 100
  KEY_LINE_Y = 350
  NOTE_GENERATE_Y = 50
  HIT_POSITION_CENTERS = [
    [125, KEY_LINE_Y],
    [225, KEY_LINE_Y],
    [325, KEY_LINE_Y],
    [425, KEY_LINE_Y],
    [525, KEY_LINE_Y],
  ]
  CFONT = [14, 16, 20, 24, 32].map { |size|
    [size, Font.new(size, 'ＭＳ Ｐゴシック')]
  }.to_h.merge(
    w: [12, 14, 20, 48].map { |size|
      [size, Font.new(size, 'ＭＳ Ｐゴシック', weight: true)]
    }.to_h
  )
  SELECTABLE_KEYS = ('A'..'Z').map { |c|
    const_name = "K_#{c}"
    [c, DXRuby.const_get(const_name)]
  }.to_h
end
