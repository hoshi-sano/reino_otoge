module ReinoOtoge
  # ライブ成功時のリザルト画面の最初に表示されるエフェクトを表現するクラス
  class LiveSuccessEffect < Sprite
    include HelperMethods

    IMAGE = load_image('live-success')
    SCALES = [1.4, 1.8, 1.6, 1.4, 1.2, 1.0]
    SLICE_NUM = 13
    START_Y = (WINDOW_HEIGHT / 2) - 70
    END_Y = 30
    SLIDE_SPEED = 6

    def initialize
      super((WINDOW_WIDTH / 2) - (IMAGE.width / 2), START_Y, IMAGE)
      @sliced = IMAGE.dup.slice_tiles(SLICE_NUM, 1).flatten.map.with_index do |img, i|
        Sprite.new(self.x + img.width * i, self.y, img).tap do |spr|
          spr.center_x = img.width / 2
          spr.center_y = img.height / 2
        end
      end
      @scales = SCALES.dup
      @index = 0
      @appearing = true
    end

    # 一枚絵を分割した画像(@sliced)を左から1枚ずつ表示していく(appearing状態)
    # すべての画像が表示されたら画面上部へスライドする
    # スライドが完了したらエフェクト終了(finished状態)
    def update
      return if finished?

      # すべての画像が表示されたら画面上部へスライドする
      unless appearing?
        if self.y > END_Y
          self.y -= SLIDE_SPEED
        else
          # 指定の位置までスライドしたらエフェクト終了
          @finish = true
        end
        return
      end

      # 一枚絵を分割した画像(@sliced)を左から1枚ずつ表示していく
      if scale = @scales.shift
        @sliced[@index].scale_x = @sliced[@index].scale_y = scale
      else
        SE.play(:beep)
        @index += 1
        if @index >= SLICE_NUM
          @appearing = false
          BGM.play(:live_result)
        else
          @scales = SCALES.dup
        end
      end
    end

    def draw
      if appearing?
        Sprite.draw(@sliced[0..@index])
      else
        super
      end
    end

    # 出現アニメーションの最中かどうかの判定
    def appearing?
      !!@appearing
    end

    # エフェクトが終了したかどうかの判定
    def finished?
      !!@finish
    end
  end
end
