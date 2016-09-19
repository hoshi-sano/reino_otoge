module ReinoOtoge
  # ライブ終了時のクリア表示等を行うためのクラス
  class LiveFinishEffect < Sprite
    include HelperMethods

    CLEAR_IMAGE = load_image('live-clear')
    CLEAR_POSITION = [(WINDOW_WIDTH / 2) - (CLEAR_IMAGE.width / 2),
                      (WINDOW_HEIGHT / 2) - (CLEAR_IMAGE.height / 2)]
    CLEAR_Y_SCALES = [0.1, 0.1, 0.1, 0.2, 0.3, 0.4, 0.6, 0.8, 1.0, 1.4, 1.2,
                      *([1.0] * 90),
                      1.1, 1.2, 1.3, 1.4, 1.4, 1.3, 1.2, 1.1, 1.0,
                      0.9, 0.8, 0.7, 0.6, 0.5, 0.4, 0.3, 0.2, 0.1]
    CLEAR_X_SCALES = [1.0, 1.0, 1.0, 0.9, 0.8, 0.7, 0.6, 0.4, 0.2, 0.1, *([0.0] * 90)]

    def initialize
      super(*CLEAR_POSITION, CLEAR_IMAGE)
      self.center_x = self.image.width / 2
      self.center_y = self.image.height / 2
      self.scale_y = 0.0
      @y_scales = CLEAR_Y_SCALES.dup
      @x_scales = CLEAR_X_SCALES.dup
    end

    def update
      scale = @y_scales.shift
      if scale.nil?
        scale = @x_scales.shift
        if scale.nil?
          @finish = true
          return
        end
        self.scale_x = scale
        return
      end
      self.scale_y = scale
    end

    # エフェクトが終了したかどうかの判定
    def finished?
      !!@finish
    end
  end
end
