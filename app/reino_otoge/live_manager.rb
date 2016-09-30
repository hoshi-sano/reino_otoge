module ReinoOtoge
  module LiveManager
    module ModuleMethods
      include HelperMethods

      COMBO_COUNT_METHODS = {
        perfect: :chain!,
        great:   :chain!,
        nice:    :break!,
        bad:     :break!,
        miss:    :break!,
      }
      # スコアの判定倍率
      GRADE_TO_RATIOS = {
        perfect: 1.0,
        great:   0.7,
        nice:    0.4,
        bad:     0.1,
        miss:    0,
      }
      BLACK_IMAGE = Image.new(WINDOW_WIDTH, WINDOW_HEIGHT, [75, 0, 0, 0])
      HIT_BAR_IMAGE = load_image('hit-bar')
      HIT_BAR_POSITION = [(WINDOW_WIDTH / 2) - (HIT_BAR_IMAGE.width / 2),
                          KEY_LINE_Y - (HIT_BAR_IMAGE.height / 2)]
      SURPLUS = 180

      # ライブ開始用の前処理
      # ライブ開始時に1回だけ呼び出す
      #
      # @param [ReinoOtoge::Unit] unit ライブに参加するユニット
      # @param [ReinoOtoge::MusicData] music_data 選択した楽曲のデータ
      def init(unit, music_data)
        @unit = unit
        @idols = unit.idols
        @idol_thumbnails = unit.generate_hit_thumbnails
        @music_data = music_data
        @speed = @music_data.speed
        @lanes = @music_data.lanes
        @bg_image = @music_data.bg_image
        @black_curtain = Sprite.new(0, 0, BLACK_IMAGE)
        @hit_bar = Sprite.new(*HIT_BAR_POSITION, HIT_BAR_IMAGE)
        @keys = {
          Config.live_keys[0] => HitboxGroup.new(@lanes[0], @speed),
          Config.live_keys[1] => HitboxGroup.new(@lanes[1], @speed),
          Config.live_keys[2] => HitboxGroup.new(@lanes[2], @speed),
          Config.live_keys[3] => HitboxGroup.new(@lanes[3], @speed),
          Config.live_keys[4] => HitboxGroup.new(@lanes[4], @speed),
        }
        @notes = []
        @frame_cnt = 0
        @gen_cnt = 0
        @rating = Rating.new
        @combo = ComboCounter.new(500, 60)
        @ui = LiveUi.new(@idols.map(&:life).inject(&:+), @music_data.score_grade_border)
        @grades = { perfect: 0, great: 0, nice: 0, bad: 0, miss: 0 }

        @delay = (KEY_LINE_Y - NOTE_GENERATE_Y) / @speed
        @music_data.load_bgm

        @live_start_effect = LiveStartEffect.new(@music_data)
        @live_finish_effect = LiveFinishEffect.new
        @full_combo_effect = FullComboEffect.new

        @current_update_method = method(:update_components_in_ready)
        @current_draw_method = method(:draw_components_in_ready)
        @current_check_key_method = Proc.new {} # 空処理
        @current_check_click_method = Proc.new {} # 空処理

        @finish_count = @music_data.length + @delay + SURPLUS
        @full_combo_count = @music_data.full_combo_note_count
        @score_base = (@unit.appeal * (@music_data.lv / 10.0) / @full_combo_count).to_i
      end

      # 1打鍵あたりのスコア計算
      #
      # @param [Symbol] type 判定を表すシンボル(:perfect, :great, ...)
      def calc_score(type)
        (@score_base * GRADE_TO_RATIOS[type] * combo_ratio).to_i
      end

      # コンボ倍率
      def combo_ratio
        1 + (@combo.count / @full_combo_count.to_r)
      end

      def hit!(type)
        @grades[type] += 1
        @combo.send(COMBO_COUNT_METHODS[type])
        @ui.add_score(calc_score(type))
        @rating.show(type)
        @full_combo_effect.show if @combo.count == @full_combo_count
      end

      def miss!
        @grades[:miss] += 1
        @combo.break!
        @rating.show(:miss)
        @ui.reduce_life(10) # TODO: 適切なダメージ値を決める
      end

      def check_keys
        @current_check_key_method.call
      end

      def check_keys_in_live
        @keys.each do |key, hitbox_group|
          if Input.key_push?(key)
            hitbox_group.enable!
          elsif Input.key_release?(key)
            hitbox_group.lane.down? ? hitbox_group.enable! : hitbox_group.disable!
            hitbox_group.lane.finish_long_down!
          else
            hitbox_group.disable!
          end
          hitbox_group.draw if ReinoOtoge.debug?
        end
        Sprite.check(@keys.values.map(&:to_a), @notes, :shot, :hit)
        @lanes.map(&:judge!)
      end

      def check_click
        @current_check_click_method.call
      end

      def check_click_in_live
        # TODO
      end

      def update_components
        @current_update_method.call
      end

      def draw_components
        @current_draw_method.call
      end

      def update_components_in_ready
        @live_start_effect.update
        if @live_start_effect.finished?
          @current_update_method = method(:update_components_in_live)
          @current_draw_method = method(:draw_components_in_live)
          @current_check_key_method = method(:check_keys_in_live)
          @current_check_click_method = method(:check_click_in_live)
        end
      end

      def update_components_in_live
        @lanes.each do |lane|
          @notes << lane.fetch_note
        end
        Sprite.update([@notes, @rating, @lanes.map(&:effects),
                       @full_combo_effect])
        Sprite.clean(@notes)
        @frame_cnt += 1
        @music_data.play_music if @frame_cnt == @delay
        if music_finished?
          @music_data.stop_music
          @combo.update_max_combo!
          @current_update_method = method(:update_components_in_succeed)
          @current_draw_method = method(:draw_components_in_succeed)
          @current_check_key_method = Proc.new {}
          @current_check_click_method = Proc.new {}
          SE.play(:cheer)
        end
      end

      def update_components_in_succeed
        @live_finish_effect.update
        go_to_next_scene if @live_finish_effect.finished?
      end

      def draw_components_in_ready
        Window.draw(0, 0, @bg_image)
        Sprite.draw([@idols, @black_curtain, @ui.to_a, @idol_thumbnails, @hit_bar])
        @live_start_effect.draw
      end

      def draw_components_in_live
        Window.draw(0, 0, @bg_image)
        Sprite.draw([@idols, @black_curtain, @ui.to_a, @idol_thumbnails,
                     @hit_bar, @notes, @rating, @lanes.map(&:effects),
                     @full_combo_effect])
        @combo.draw
      end

      def draw_components_in_succeed
        Window.draw(0, 0, @bg_image)
        Sprite.draw([@idols, @ui.to_a, @idol_thumbnails, @hit_bar, @live_finish_effect])
      end

      def music_finished?
        # TODO: テスト用に後者の判定をコメントアウトしているが、有効にすること
        (@frame_cnt > @finish_count) # && @music_data.music_finished?
      end

      def go_to_next_scene
        next_scene = LiveResultScene.new(@grades, @ui.score, @ui.score_grade,
                                         @combo.max, @unit, @music_data)
        ReinoOtoge.change_scene(next_scene)
      end
    end
    extend ModuleMethods
  end
end
