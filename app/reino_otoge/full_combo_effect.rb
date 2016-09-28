module ReinoOtoge
  # フルコンボ表示を行うクラス
  class FullComboEffect < Sprite
    include HelperMethods

    IMAGE = load_image('full-combo')
    SCALE_ALPHAS = [
      [1.5, 50], # 1.5倍のサイズでフェードイン
      [1.4, 100],
      [1.3, 150],
      [1.2,  200],
      [1.1,   255],
      *([[1.0, 255]] * 30), # 30フレーム停止
      [1.1, 255],
      [1.2, 255],
      [1.3, 255],
      [1.4, 255],
      [1.5, 255], # 消える前の予備動作として少し拡大
      [1.4, 255],
      [1.3, 255],
      [1.2, 255],
      [1.1, 255],
      [1.0, 255], # 徐々にフェードアウト
      [0.9, 220],
      [0.8, 190],
      [0.7, 160],
      [0.6, 130],
      [0.5, 100],
      [0.4,  70],
      [0.3,  40],
      [0.2,  10],
      [0.1,   0],
    ]

    def initialize
      x = (WINDOW_WIDTH / 2) - (IMAGE.width / 2)
      y = (WINDOW_HEIGHT / 2) - (IMAGE.height / 2)
      super(x, y, IMAGE)
      self.visible = false
      self.scale_x = IMAGE.width / 2
      self.scale_y = IMAGE.height / 2
      @count = 0
    end

    def show
      SE.play(:full_combo)
      self.visible = true
    end

    def update
      return if !self.visible || @finish
      scale, self.alpha = SCALE_ALPHAS[@count]
      self.scale_x = scale
      self.scale_y = scale
      @count += 1
      if @count >= SCALE_ALPHAS.size
        @finish = true
        self.visible = false
      end
    end

    def finish?
      !!@finish
    end
  end
end
