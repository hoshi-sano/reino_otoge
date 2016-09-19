module ReinoOtoge
  # ライブ中に長押し判定が行われた際のエフェクトを表現するクラス
  class DownEffect < Sprite
    include HelperMethods

    # 2フレームずつ表示したいのでdupする
    IMAGES = load_image_tiles('down-effect', 8, 1).map { |img| [img, img.dup] }.flatten

    def initialize(line_num)
      image = IMAGES.first
      cx, cy = *HIT_POSITION_CENTERS[line_num]
      x = cx - image.width / 2
      y = cy - image.height
      super(x, y, image)
      @current_frame = 0
      self.visible = false
    end

    def show!
      # TODO: 音を鳴らす
      @current_frame = 0
      self.image = IMAGES[@current_frame]
      self.visible = true
    end

    def hide!
      # TODO: 音を止める
      self.visible = false
    end

    def update
      return unless self.visible
      @current_frame = @current_frame % IMAGES.size
      self.image = IMAGES[@current_frame]
      @current_frame += 1
    end
  end
end
