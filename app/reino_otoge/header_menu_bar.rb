module ReinoOtoge
  # 画面上部のメニューバー
  class HeaderMenuBar
    include HelperMethods

    GAGE_IMAGES = {
      exp:     load_image('exp-gage'),
      stamina: load_image('stamina-gage'),
    }
    POSITION = [25, 15]
    RELATIVE_POS = {
      lv:          [55, 7],
      exp:         [10, 25],
      stamina:     [103, 25],
      money_right: [315, 23],
      stone_right: [410, 23],
    }
    FONT = CFONT[:w][12]

    def initialize
      @base = Sprite.new(*POSITION, load_image('header-bar'))
      @exp_gage = Sprite.new(*exp_gage_xy, GAGE_IMAGES[:exp])
      @stamina_gage = Sprite.new(*stamina_gage_xy, GAGE_IMAGES[:stamina])
      # ゲージの増減をX軸方向への拡大縮小で表現する
      # このとき拡大縮小の起点が左端になるようcenter_xを設定しておく
      [@exp_gage, @stamina_gage].each { |g| g.center_x = 0 }
      update
    end

    def exp_gage_xy
      [RELATIVE_POS[:exp][0] + POSITION[0],
       RELATIVE_POS[:exp][1] + POSITION[1]]
    end

    def stamina_gage_xy
      [RELATIVE_POS[:stamina][0] + POSITION[0],
       RELATIVE_POS[:stamina][1] + POSITION[1]]
    end

    def lv_xy
      [RELATIVE_POS[:lv][0] + POSITION[0],
       RELATIVE_POS[:lv][1] + POSITION[1]]
    end

    def money_xy
      str_width = FONT.get_width(@money_str)
      [RELATIVE_POS[:money_right][0] + POSITION[0] - str_width,
       RELATIVE_POS[:money_right][1] + POSITION[1]]
    end

    def stone_xy
      str_width = FONT.get_width(@stone_str)
      [RELATIVE_POS[:stone_right][0] + POSITION[0] - str_width,
       RELATIVE_POS[:stone_right][1] + POSITION[1]]
    end

    def update
      @exp_gage.scale_x = PlayerData.current_exp.to_f / PlayerData.next_exp
      @stamina_gage.scale_x = PlayerData.current_stamina.to_f / PlayerData.max_stamina
      @money_str = int_with_comma(PlayerData.money)
      @stone_str = int_with_comma(PlayerData.stone)
    end

    def int_with_comma(int)
      int.to_s.reverse.scan(/.{1,3}/).join(',').reverse
    end

    def draw
      Sprite.draw([@base, @exp_gage, @stamina_gage])
      exp_str = "#{PlayerData.current_exp}/#{PlayerData.next_exp}"
      Window.draw_font_ex(*exp_gage_xy, exp_str, FONT)
      stamina_str = "#{PlayerData.current_stamina}/#{PlayerData.max_stamina}"
      Window.draw_font_ex(*stamina_gage_xy, stamina_str, FONT)
      Window.draw_font_ex(*lv_xy, PlayerData.lv.to_s, FONT, color: [255, 180, 60])
      Window.draw_font_ex(*money_xy, @money_str, FONT, color: C_BLACK)
      Window.draw_font_ex(*stone_xy, @stone_str, FONT, color: C_BLACK)
    end
  end
end
