module ReinoOtoge
  # 打鍵の評価を表現するクラス
  class Rating < Sprite
    include HelperMethods

    IMAGES = {
      perfect: load_image('perfect'),
      great:   load_image('great'),
      nice:    load_image('nice'),
      bad:     load_image('bad'),
      miss:    load_image('miss'),
    }
    # 24フレームの間評価を表示する
    # そのうち最初の2フレームは縮小状態
    SCALES = [0.8, 0.9] + Array.new(22, 1)

    def initialize
      super(250, 250, IMAGES.values.first)
      self.center_x = IMAGES.values.first.width / 2
      self.center_y = IMAGES.values.first.height / 2
      self.collision_enable = false
      self.visible = false
      @current_frame = 0
    end

    def show(type)
      self.image = IMAGES[type]
      self.visible = true
      @current_frame = 0
    end

    def update
      return unless self.visible
      self.scale_x = SCALES[@current_frame]
      self.scale_y = SCALES[@current_frame]
      @current_frame += 1
      self.visible = false if @current_frame > (SCALES.size - 1)
    end
  end
end
