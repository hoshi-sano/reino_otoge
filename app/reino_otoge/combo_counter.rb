module ReinoOtoge
  class ComboCounter < Sprite
    # コンボ数の表示位置(@xと@yからの相対位置)
    NUMBER_XY = {
      1 => [25, 0], # コンボ数が1桁の場合
      2 => [10, 0], # コンボ数が2桁の場合
      3 => [ 0, 0], # コンボ数が3桁の場合
    }
    # 「COMBO」という文字列の表示位置(@xと@yからの相対位置)
    COMBO_STR_XY = [0, 44]
    # コンボ数の表示用オプション
    NUMBER_OPTIONS = {
      edge: true,
      edge_color: [255, 155, 0],
      edge_width: 5,
    }
    # 「COMBO」という文字列の表示用オプション
    COMBO_STR_OPTIONS = {
      edge: true,
      edge_color: [255, 155, 0],
      edge_width: 5,
      edge_level: 5,
    }
    COMBO_STR = 'COMBO'

    attr_reader :count, :max

    def initialize(x, y)
      @x = x
      @y = y
      @number_font = CFONT[:w][48]
      @combo_str_font = CFONT[:w][20]
      @count = 0
      @max = 0
      @scale_x = 1.0
      @scale_y = 1.0
    end

    def chain!
      @count += 1
      @scale = 0.2
    end

    def break!
      update_max_combo!
      @count = 0
    end

    def update_max_combo!
      @max = @count if @count > @max
    end

    def draw
      return if @count <= 1
      num_x, num_y = NUMBER_XY[Math.log10(@count).to_i + 1]
      Window.draw_font_ex(@x + num_x,
                          @y + num_y,
                          @count.to_s,
                          @number_font,
                          NUMBER_OPTIONS.merge(scale_x: @scale, scale_y: @scale))
      Window.draw_font_ex(@x + COMBO_STR_XY[0],
                          @y + COMBO_STR_XY[1],
                          COMBO_STR,
                          @combo_str_font,
                          COMBO_STR_OPTIONS)
      # 次の拡大率の計算。最終的に1.0に収束する
      @scale = (1 + Math.log10(@scale)).to_r.ceil(1).to_f
    end
  end
end
