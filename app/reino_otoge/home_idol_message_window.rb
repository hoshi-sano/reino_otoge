module ReinoOtoge
  # ホーム画面においてキャラクターがランダムでしゃべるメッセージを
  # 表示するためのクラス
  class HomeIdolMessageWindow < Sprite
    include HelperMethods

    POSITION = [400, 240]
    MESSAGE_POSITION = [435, 245]
    IDOL_NAME_POSITION = [435, 325]
    RELATIVE_POSITIONS = {
      message: [35, 5],
      idol_name: [35, 85],
    }
    IMAGE = load_image('idol-message-window')
    FONT = CFONT[14]
    TTL = 600

    def initialize(idol)
      @idol = idol
      super(*POSITION, IMAGE.dup)
      reset
    end

    def idol=(new_idol)
      @idol = new_idol
      reset
    end

    def reset
      self.image = IMAGE.dup
      @idol_message = @idol.random_message
      @ttl = TTL
      PlayerData.recover_stamina
    end

    def update
      @ttl -= 1
      reset if @ttl < 0
    end

    def draw
      super
      # Image#draw_fontは改行を考慮しないため、Window#draw_font_exを利用する
      Window.draw_font(*IDOL_NAME_POSITION, @idol.name, FONT)
      return unless @idol_message
      Window.draw_font(*MESSAGE_POSITION, @idol_message, FONT)
    end
  end
end
