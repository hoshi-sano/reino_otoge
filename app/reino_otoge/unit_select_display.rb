module ReinoOtoge
  # 楽曲選択画面におけるユニット選択表示部
  # @note 現時点ではユニットは1組しか定義できないため選択は実質不可
  class UnitSelectDisplay < PartialView
    include HelperMethods

    BASE_IMAGE = load_image('unit-select-window')
    BASE_XY = [(WINDOW_WIDTH / 2) - (BASE_IMAGE.width / 2), 65]
    LIVE_START_BUTTON_IMAGE = load_image('live-start-button')
    LIVE_START_BUTTON_XY = [460, 360]
    THUMBNAILS_Y = 165
    TITLE_XY = [80, 80]
    LIFE_XY = [450, 140]
    UNIT_NAME_XY = [95, 132]
    APPEAL_XY = [160, 287]
    TARGET_APPEAL_XY = [300, 287]
    STAMINA_XY = {
      current:  [480, 90],
      after:    [520, 90],
      spending: [540, 90],
    }
    NAME_FONT = CFONT[:w][20]
    NUMBER_FONT = CFONT[14]
    C_SPENDING = [255, 50, 50]
    C_APPEAL = [255, 0, 120]

    attr_reader :music_data

    def initialize
      super()
      @base = Sprite.new(*BASE_XY, BASE_IMAGE)
      @start_button = Sprite.new(*LIVE_START_BUTTON_XY, LIVE_START_BUTTON_IMAGE)
      @components = [@base, @start_button]
      @components.each do |spr|
        spr.target = @render_target
      end
      set(0)
    end

    # 選択されたユニットを返す
    # TODO: 複数ユニットから特定のユニットを選択可能にする
    def selected
      PlayerData.favorite
    end

    # TODO: 複数ユニットから特定のユニットを選択可能にする
    def set(idx)
      @unit_name =  selected.name
      @life =  selected.sum_life.to_s
      @appeal = selected.appeal.to_s
    end

    def music_data=(m_data)
      @title = m_data.title
      @spending = m_data.spending.to_s
      @target_appeal = m_data.target_appeal.to_s
    end

    def draw
      return if hidden?
      Sprite.draw(@components)
      thumbnails_x = (@render_target.width / 2) - (selected.thumbnails.width / 2)
      @render_target.draw(thumbnails_x, THUMBNAILS_Y, selected.thumbnails)
      @render_target.draw_font_ex(*TITLE_XY, @title,
                                  NAME_FONT, color: C_BLACK)
      @render_target.draw_font_ex(*STAMINA_XY[:current],
                                  PlayerData.current_stamina.to_s,
                                  NUMBER_FONT, color: C_BLACK)
      @render_target.draw_font_ex(*STAMINA_XY[:after],
                                  (PlayerData.current_stamina - @spending.to_i).to_s,
                                  NUMBER_FONT, color: C_BLACK)
      @render_target.draw_font_ex(*STAMINA_XY[:spending],"(-#{@spending})",
                                  NUMBER_FONT, color: C_SPENDING)
      @render_target.draw_font_ex(*UNIT_NAME_XY, @unit_name,
                                  NAME_FONT, color: C_BLACK)
      @render_target.draw_font_ex(*LIFE_XY, @life,
                                  NUMBER_FONT, color: C_BLACK)
      @render_target.draw_font_ex(*APPEAL_XY, @appeal,
                                  NUMBER_FONT, color: C_APPEAL)
      @render_target.draw_font_ex(*TARGET_APPEAL_XY, @target_appeal,
                                  NUMBER_FONT, color: C_BLACK)
      Window.draw(0, 0, @render_target)
    end

    def check_keys
      return if hidden?
      # TODO: ユニット選択をさせる
      if Input.key_push?(K_BACK)
        @finish_hiding_callback = -> { MusicSelectManager.music_data_display.show! }
        hide!
      elsif Input.key_push?(K_RETURN)
        SE.play(:ok)
        @finish_hiding_callback = -> { MusicSelectManager.go_to_next_scene }
        hide!
      end
    end
  end
end
