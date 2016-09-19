module ReinoOtoge
  # ライブシーンで表示する各種UI系をまとめ管理するクラス
  class LiveUi
    include HelperMethods

    STOP_BUTTON_POSITION = [580, 15]
    LIFE_GAGE_IMAGES = {
      bg:          load_image('life-gage-bg'),
      front:       load_image('life-gage-front'),
      green:       load_image('life-gage-green'),
      red:         load_image('life-gage-red'),
      heart_green: load_image('life-heart-green'),
      heart_red:   load_image('life-heart-red'),
    }
    SCORE_GAGE_IMAGES = {
      bg:      load_image('score-gage-bg'),
      front:   load_image('score-gage-front'),
      a_left:  load_image('score-gage-a-left'),
      a_right: load_image('score-gage-a-right'),
      b_left:  load_image('score-gage-b-left'),
      b_right: load_image('score-gage-b-right'),
      c_left:  load_image('score-gage-c-left'),
      c_right: load_image('score-gage-c-right'),
      none:    load_image('score-gage-none'),
      s:       load_image('score-gage-s'),
    }

    def initialize(max_life, score_borders)
      @life_gage = LifeGage.new(max_life)
      @score_gage = ScoreGage.new(score_borders)
      @stop_button = Sprite.new(*STOP_BUTTON_POSITION, load_image('stop-button'))
    end

    # 現時点のスコアを返す
    def score
      @score_gage.score_num
    end

    # ライフゲージを減らす
    # @param [Integer] num 減算する数
    def reduce_life(num)
      @life_gage.reduce(num)
    end

    # スコアを加算する
    # @param [Integer] num 加算する数
    def add_score(num)
      @score_gage.add(num)
    end

    def to_a
      [@score_gage.to_a, @life_gage.to_a, @stop_button]
    end

    # ライフゲージの表現とライフの管理を担うクラス
    class LifeGage
      POSITION = [17, 15]
      RELATIVE_POS = {
        gage: [31, 2],
        heart: [6, 3],
      }

      def initialize(max_life)
        @max_life = max_life
        @current_life = max_life
        @bg    = Sprite.new(*POSITION, LIFE_GAGE_IMAGES[:bg])
        @front = Sprite.new(*POSITION, LIFE_GAGE_IMAGES[:front])
        gage_x = RELATIVE_POS[:gage][0] + POSITION[0]
        gage_y = RELATIVE_POS[:gage][1] + POSITION[1]
        @gage  = Sprite.new(gage_x, gage_y, LIFE_GAGE_IMAGES[:green])
        heart_x = RELATIVE_POS[:heart][0] + POSITION[0]
        heart_y = RELATIVE_POS[:heart][1] + POSITION[1]
        @heart  = Sprite.new(heart_x, heart_y, LIFE_GAGE_IMAGES[:heart_green])
        # ライフの増減をX軸方向への拡大縮小で表現する
        # このとき拡大縮小の起点が左端になるようcenter_xを設定しておく
        @gage.center_x = 0
      end

      # ライフゲージを減らす
      # @param [Integer] num 減算する数
      def reduce(num)
        @current_life -= num
        @gage.scale_x = @current_life.to_f / @max_life
      end

      def to_a
        [@bg, @heart, @gage, @front]
      end
    end

    # スコアゲージの表現とスコアの管理を担うクラス
    class ScoreGage
      POSITION = [210, 15]
      RELATIVE_POS = {
        gage:         [4, 3],
        score_string: [55, 15],
      }
      SCORE_STRING_OPTIONS = {
        color: [255, 100, 100],
        edge: true,
        edge_color: [255, 255, 255],
        edge_width: 3,
        edge_level: 4,
      }
      NEXT_GRADE = {
        S:    nil,
        A:    :S,
        B:    :A,
        C:    :B,
        NONE: :C,
      }

      attr_reader :score_num

      # 引数score_bordersは次のような形式のハッシュ
      # { S: 7000, A: 6000, B: 5000, C: 4000 }
      def initialize(score_borders)
        @score_borders = score_borders
        @score_num = 0
        @score_font = CFONT[:w][20]
        score_str_x = RELATIVE_POS[:score_string][0] + POSITION[0]
        score_str_y = RELATIVE_POS[:score_string][1] + POSITION[1]
        @score_string = Sprite.new(score_str_x, score_str_y, Image.new(120, 20))
        rebuild_score_string
        @bg = Sprite.new(*POSITION, SCORE_GAGE_IMAGES[:bg])
        @front = Sprite.new(*POSITION, SCORE_GAGE_IMAGES[:front])
        @current_grade = nil
        build_gages
      end

      def build_gages
        gage_x = RELATIVE_POS[:gage][0] + POSITION[0]
        gage_y = RELATIVE_POS[:gage][1] + POSITION[1]
        position = [gage_x, gage_y]
        @grade_gages = {
          S:    Sprite.new(*position, SCORE_GAGE_IMAGES[:s]),
          A:    [Sprite.new(*position, SCORE_GAGE_IMAGES[:a_left]),
                 Sprite.new(*position, SCORE_GAGE_IMAGES[:a_right])],
          B:    [Sprite.new(*position, SCORE_GAGE_IMAGES[:b_left]),
                 Sprite.new(*position, SCORE_GAGE_IMAGES[:b_right])],
          C:    [Sprite.new(*position, SCORE_GAGE_IMAGES[:c_left]),
                 Sprite.new(*position, SCORE_GAGE_IMAGES[:c_right])],
          NONE: Sprite.new(*position, SCORE_GAGE_IMAGES[:none])
        }
        change_gage(:NONE)
      end

      def rebuild_score_string
        @score_string.image.clear
        str = '%07d' % @score_num
        @score_string.image.draw_font_ex(5, 0, str, @score_font, SCORE_STRING_OPTIONS)
      end

      # スコアを加算する
      # @param [Integer] num 加算する数
      def add(num)
        @score_num += num
        update_gage
        rebuild_score_string
      end

      def update_gage
        # ゲージの画像の変更
        @score_borders.each do |grade, border|
          break if @current_grade == grade
          if @score_num >= border
            change_gage(grade)
            break
          end
        end
        return if @current_grade == :S

        # ゲージの横の長さの変更
        next_grade_score = @score_borders[NEXT_GRADE[@current_grade]]
        current_grade_score = @score_borders[@current_grade]
        if current_grade_score
          @elastic_gage.scale_x = (@score_num - current_grade_score) /
                                  (next_grade_score - current_grade_score)
        else
          @elastic_gage.scale_x = @score_num / next_grade_score
        end
      end

      # ゲージの画像を引数で渡したgradeに適したものに変更する
      def change_gage(grade)
        @current_grade = grade
        @gage = @grade_gages[grade]
        return if @current_grade == :S
        if @gage.is_a?(Array)
          @elastic_gage = @gage.last
          @elastic_gage.x = @gage.first.x + @gage.first.image.width
        else
          @elastic_gage = @gage
        end
        @elastic_gage.center_x = 0
        @elastic_gage.scale_x = 0
      end

      def to_a
        [@bg, @gage, @front, @score_string]
      end
    end
  end
end
