module ReinoOtoge
  # ライブ成功時の成績表示用クラス
  class LiveGradeDisplay
    include HelperMethods

    FONT_S = CFONT[20]
    FONT_L = CFONT[24]
    SLIDE_SPEED = 10
    IDOL_X = 300
    ARTWORK_X = 5
    ARTWORK_Y = 10
    WINDOW_X = 5
    WINDOW_Y = 110
    GRADE_X = 250
    GRADE_Y_OFFSET = 10
    GRADE_Y_SPACING = 25
    SEAL_CENTER_POSITION = [350, 350]
    COMBO_POSITION = [240, 145]
    SCORE_POSITION = [190, 200]
    HIGHSCORE_POSITION = [205, 230]
    MUSIC_SCORE_POSITION = [110, 265]
    PLAYER_SCORE_POSITION = [230, 265]
    IMAGE = load_image('live-result-window')
    ARTWORK_SCALING_UNIT = 0.01
    SEAL_INITIAL_SCALE = 3.0
    SEAL_SCALING_UNIT = 0.2
    WAIT = LiveSuccessEffect::SCALES.size * LiveSuccessEffect::SLICE_NUM

    def initialize(grades, score, score_grade, max_combo, idol, music_data)
      @artwork = Sprite.new(0 - IMAGE.width,
                            ARTWORK_Y,
                            music_data.artwork_image)
      @artwork.scale_x = @artwork.scale_y = 0.5
      @artwork.center_x = @artwork.image.width / 2
      @artwork.center_y = 0
      @window = Sprite.new(0 - IMAGE.width, WINDOW_Y, IMAGE.dup)
      grades.values.each_with_index do |v, i|
        @window.image.draw_font_ex(GRADE_X,
                                   GRADE_Y_OFFSET + i * GRADE_Y_SPACING,
                                   "%04d" % v, FONT_S, color: C_BLACK)
      end
      @window.image.draw_font_ex(*COMBO_POSITION,
                                 "%04d" % max_combo, FONT_L, color: C_BLACK)
      @window.image.draw_font_ex(*SCORE_POSITION,
                                 "%08d" % score, FONT_L, color: C_BLACK)
      # NOTE: 以下三つのスコアは現状表示するのみで特に記録・更新はしていない
      @window.image.draw_font_ex(*HIGHSCORE_POSITION,
                                 "%08d" % score, FONT_S, color: C_BLACK)
      @window.image.draw_font_ex(*MUSIC_SCORE_POSITION,
                                 "%03d" % (score / 10_000), FONT_S, color: C_BLACK)
      @window.image.draw_font_ex(*PLAYER_SCORE_POSITION,
                                 "%03d" % PlayerData.score, FONT_S, color: C_BLACK)

      @idol = Sprite.new(WINDOW_WIDTH,
                         WINDOW_HEIGHT - idol.portrait.height,
                         idol.portrait)
      if score_grade == :NONE
        @grade_seal = Sprite.new(*SEAL_CENTER_POSITION, Image.new(1, 1, [0, 0, 0, 0]))
      else
        img = load_image("grade-#{score_grade.to_s.downcase}")
        pos = [SEAL_CENTER_POSITION[0] - (img.width / 2),
               SEAL_CENTER_POSITION[1] - (img.height / 2)]
        @grade_seal = Sprite.new(*pos, img)
      end
      @grade_seal.center_x = @grade_seal.image.width / 2
      @grade_seal.center_y = @grade_seal.image.height / 2
      @grade_seal.scale_x = @grade_seal.scale_y = SEAL_INITIAL_SCALE
      @grade_seal.visible = false
      @count = 0
      @update_method = method(:wait)
    end

    def draw
      Window.draw(0, 0, COMMON_BG_IMAGE)
      @idol.draw
      @window.draw
      @artwork.draw
      @grade_seal.draw
    end

    def update
      @update_method.call
    end

    def wait
      @count += 1
      @update_method = method(:slide) if @count > WAIT
    end

    def slide
      artwork_scaling
      @artwork.x += SLIDE_SPEED if (@artwork.x + @artwork.image.width / 4) <=  ARTWORK_X
      @window.x += SLIDE_SPEED if @window.x <= WINDOW_X
      @idol.x -= SLIDE_SPEED if @idol.x >= IDOL_X
      if (@window.x > WINDOW_X) && (@idol.x < IDOL_X)
        @grade_seal.visible = true
        @update_method = method(:show_grade_seal)
        @finish = true
      end
    end

    def show_grade_seal
      @grade_seal.scale_x -= SEAL_SCALING_UNIT
      @grade_seal.scale_y -= SEAL_SCALING_UNIT
      if @grade_seal.scale_x <= 1.0
        @update_method = method(:artwork_scaling)
        @finish = true
      end
    end

    def artwork_scaling
      @scaling_dir ||= -1
      @artwork.scale_x += ARTWORK_SCALING_UNIT * @scaling_dir
      if @artwork.scale_x <= 0 || @artwork.scale_x >= 0.5
        @scaling_dir = @scaling_dir * -1
      end
    end

    def finished?
      !!@finish
    end
  end
end
