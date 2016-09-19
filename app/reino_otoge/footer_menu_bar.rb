module ReinoOtoge
  # 画面下部のメニューバー
  class FooterMenuBar
    include HelperMethods

    ID_TO_SCENE = {
      home:  HomeScene,
      idol:  nil,
      commu: nil,
      live:  MusicSelectScene,
      room:  nil,
      gasha: nil,
      menu:  nil,
    }
    BUTTON_IDS = ID_TO_SCENE.keys

    def initialize
      @base = Sprite.new(35, 410, load_image('footer-menu-bar'))
      load_buttons
      @selected = :home
      @scale_mod = 1
      @mouse_pointer = Sprite.new(0, 0, Image.new(1, 1, [0, 0, 0, 0]))
    end

    def load_buttons
      @buttons = []
      BUTTON_IDS.each_with_index do |id, idx|
        @buttons << {
          icon: Icon.new(85 * idx + 40, 410, load_image("#{id}-icon"), id),
          label: Label.new(85 * idx + 40, 435, load_image("#{id}-label"), id),
        }
      end
      @buttons.each { |b| b[:icon].center_y = b[:icon].image.height }
    end

    def select(id)
      selected_icon = @buttons[select_idx][:icon]
      selected_icon.scale_x = 1.0
      selected_icon.scale_y = 1.0
      @selected = id
    end

    def select_idx
      BUTTON_IDS.index(@selected)
    end

    def update
      selected_icon = @buttons[select_idx][:icon]
      selected_icon.scale_x = selected_icon.scale_x + (0.005 * @scale_mod)
      selected_icon.scale_y = selected_icon.scale_y + (0.005 * @scale_mod)
      if selected_icon.scale_x > 1.2
        @scale_mod = -1
      elsif selected_icon.scale_x < 1.0
        @scale_mod = 1
      end
    end

    def draw
      Sprite.draw([@base, @buttons.map(&:values)])
    end

    def check_click
      return unless Input.mouse_push?(M_LBUTTON)
      @mouse_pointer.x = Input.mouse_x
      @mouse_pointer.y = Input.mouse_y
      Sprite.check(@mouse_pointer, @buttons.map(&:values).flatten)
    end
  end

  class Button < Sprite
    attr_reader :id

    def initialize(x, y, image, id)
      super(x, y, image)
      @id = id.to_sym
    end

    def hit
      scene_class = FooterMenuBar::ID_TO_SCENE[@id]
      if ReinoOtoge.current_scene.class != scene_class
        ReinoOtoge.change_scene(scene_class.new)
      end
    end
  end

  class Icon < Button; end
  class Label < Button; end
end
