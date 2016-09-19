module ReinoOtoge
  # ホーム画面に複数配置するアイコン・ボタンを表示するためのクラス
  # 現状表示以外に特に用途なし
  class HomeIconButton < Sprite
    include HelperMethods

    BASE_POSITION = [420, 365]
    MARGIN = 5
    BADGE_IMAGE = load_image('badge')
    BADGE_FONT = CFONT[:w][12]
    BADGE_OPTIONS = {
      edge: true,
      edge_color: [0, 0, 0],
      edge_width: 1,
      edge_level: 3,
    }

    def initialize(type, index)
      img = load_image("#{type}-button")
      x = BASE_POSITION[0] + (index * (img.width + MARGIN))
      y = BASE_POSITION[1]
      super(x, y, img)
    end

    # バッジ(要チェック項目数を表示する吹き出し)を表示する
    def show_badge(count)
      @badge = Sprite.new(self.x + self.image.width - 20,
                          self.y - (self.image.height / 2),
                          BADGE_IMAGE.dup)
      @badge.image.draw_font_ex(13, 6, count.to_s, BADGE_FONT, BADGE_OPTIONS)
    end

    def draw
      super
      @badge.draw if @badge
    end
  end
end
