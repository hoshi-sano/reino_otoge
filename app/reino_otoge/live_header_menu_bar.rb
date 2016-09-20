module ReinoOtoge
  # ライブ設定用の画面上部のメニューバー
  # NOTE: クラスじゃなくてモジュールで十分かもしれない。要検討。
  class LiveHeaderMenuBar
    include HelperMethods

    POSITION = [475, 18]
    SCORE_RELATIVE_POS = [62, 20]
    FONT = CFONT[:w][14]

    def initialize
      # TODO: 画像の分離(設定ボタンを抜き出したい)
      @base = Sprite.new(*POSITION, load_image('live-menu-header'))
    end

    def score_xy
      str_width = FONT.get_width(PlayerData.score.to_s)
      [SCORE_RELATIVE_POS[0] + POSITION[0] - str_width,
       SCORE_RELATIVE_POS[1] + POSITION[1]]
    end

    def draw
      Sprite.draw(@base)
      Window.draw_font_ex(*score_xy, PlayerData.score.to_s, FONT, color: C_BLACK)
    end

    def check_click
      # TODO: 設定ボタンのみをチェック対象とする
      if @base === MOUSE_POINTER
        # TODO: ライブ設定画面を表示する
      end
    end
  end
end
