module ReinoOtoge
  # ライブ中にヒット判定が行われた際のエフェクトを表現するクラス
  class HitEffect < Sprite
    include HelperMethods


    # 最初の画像以外は2フレーム分表示したいのでdupしたりする
    IMAGES = load_image_tiles('hit-effect', 6, 1)
             .map { |img| [img, img.dup] }.flatten[1..-1]

    def initialize(line_num)
      image = IMAGES.first
      cx, cy = *HIT_POSITION_CENTERS[line_num]
      x = cx - image.width / 2
      y = cy - image.height / 2
      super(x, y, image)
      @current_frame = 0
      self.visible = false
    end

    def show!
      @current_frame = 0
      self.image = IMAGES[@current_frame]
      self.visible = true
    end

    def update
      return unless self.visible
      @current_frame += 1
      if @current_frame >= IMAGES.size
        self.visible = false
      else
        self.image = IMAGES[@current_frame]
      end
    end
  end
end
