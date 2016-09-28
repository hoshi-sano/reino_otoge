module ReinoOtoge
  # 楽曲選択画面におけるライブ設定表示部
  # @note 他のシーンでも利用する可能性がある
  class LiveSettingWindow < PartialView
    include HelperMethods

    BASE_IMAGE = load_image('common-window')
    BASE_XY = [(WINDOW_WIDTH / 2) - (BASE_IMAGE.width / 2), 65]
    OK_BUTTON_IMAGE = load_image('ok-button')
    OK_BUTTON_XY = [460, 360]
    KEY_IMAGES_Y = 165
    WINDOW_TITLE_STR = 'ライブ設定'
    KEY_CONFIG_STR = 'キー設定'
    WINDOW_TITLE_POS = [40, 10]
    KEY_CONFIG_POS = [40, 60]

    attr_accessor :prev_window
    attr_reader :key_windows

    def initialize
      super()
      @base = Sprite.new(*BASE_XY, BASE_IMAGE.clone)
      @base.image.draw_font_ex(*WINDOW_TITLE_POS, WINDOW_TITLE_STR,
                               CFONT[:w][20], color: C_BLACK)
      @base.image.draw_font_ex(*KEY_CONFIG_POS, KEY_CONFIG_STR,
                               CFONT[16], color: C_BLACK)
      @key_windows = Config.live_key_chars.map.with_index do |c, idx|
        KeyWindow.new(130 + idx * 80, KEY_IMAGES_Y, c, self)
      end
      @ok_button = Sprite.new(*OK_BUTTON_XY, OK_BUTTON_IMAGE)
      @components = [@base, *@key_windows, @ok_button]
      @components.each { |spr| spr.target = @render_target }
    end

    def update
      super
      return if hidden?
      Sprite.check(MOUSE_POINTER, @key_windows)
    end

    def draw
      return if hidden?
      Sprite.draw(@components)
      Window.draw(0, 0, @render_target)
    end

    def check_keys
      return if hidden?
      if kw = @key_windows.find(&:selected)
        # キーコンフィグ変更中の動作
        SELECTABLE_KEYS.each do |char, key_value|
          if Input.key_push?(key_value) &&
             !@key_windows.map(&:char).include?(char)
            kw.set_char(char)
            break
          end
        end
      else
        # キーコンフィグ変更中以外の動作
        if Input.key_push?(K_RETURN)
          # キー設定変更の反映
          Config.live_keys = @key_windows.map(&:key_const)
          SE.play(:next)
          back_to_prev_window
        elsif Input.key_push?(K_BACK)
          SE.play(:cancel)
          back_to_prev_window
        end
      end
    end

    def back_to_prev_window
      @key_windows.each(&:deselect!)
      @finish_hiding_callback = Proc.new { @prev_window.show! }
      hide!
    end

    class KeyWindow < Sprite
      include HelperMethods

      FRAME_IMAGE = load_image('thumbnail-frame')
      BASE_IMAGE = Image.new(FRAME_IMAGE.width - 2,
                             FRAME_IMAGE.height - 2,
                             [50, 50, 50])

      attr_reader :char, :selected

      def initialize(x, y, char, parent_window)
        @parent_window = parent_window
        super(x, y, Image.new(FRAME_IMAGE.width, FRAME_IMAGE.height))
        set_char(char)
      end

      def set_char(char)
        @char = char
        deselect!
      end

      def key_const
        DXRuby.const_get("K_#{@char}")
      end

      def update_image(char, opts = {})
        @char = char
        image.clear
        image.draw(2, 2, BASE_IMAGE)
        image.draw_font_ex(20, 10, @char, CFONT[:w][48], opts)
        image.draw(0, 0, FRAME_IMAGE)
      end

      def hit
        @parent_window.key_windows.each(&:deselect!)
        select!
      end

      def select!
        @selected = true
        update_image(@char, { color: C_YELLOW })
      end

      def deselect!
        @selected = false
        update_image(@char, { color: C_WHITE })
      end
    end
  end
end
