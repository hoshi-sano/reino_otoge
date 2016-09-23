module ReinoOtoge
  # ライブの結果(スコアやコンボ数)表示を表現するシーン
  # TODO: Managerを導入してSceneクラスを継承する
  class LiveResultScene
    include HelperMethods

    OK_BUTTON_POSITION = [500, 410]

    # @param [Hash] grades 各評価ごとのノートヒット数
    # @param [Integer] score ライブの総スコア
    # @param [Symbol] score_grade ライブの総スコアに対する評価(:NONE/:C/:B/:A/:S)
    # @param [Integer] max_combo 最大コンボ数
    # @param [ReinoOtoge::Unit] unit ライブに参加したユニット
    # @param [ReinoOtoge::MusicData] music_data プレイした楽曲のデータ
    def initialize(grades, score, score_grade, max_combo, unit, music_data)
      @live_success_effect = LiveSuccessEffect.new
      @grade_window = LiveGradeDisplay.new(grades, score, score_grade,
                                           max_combo, unit.center, music_data)
      @ok_button = Sprite.new(*OK_BUTTON_POSITION, load_image('ok-button'))
      @ok_button.visible = false
    end

    def play
      @live_success_effect.update
      @grade_window.update

      @grade_window.draw
      @live_success_effect.draw
      @ok_button.draw

      if @grade_window.finished?
        @ok_button.visible = true
        if Input.key_push?(K_RETURN)
          go_to_next_scene
        end
      end
    end

    # シーン切替時の前処理
    def pre_process
      # BGMの再生はLiveSuccessEffectが開始する
    end

    # シーン切替時の後処理
    def post_process
      BGM.stop
    end

    def fade_out
      true
    end

    def go_to_next_scene
      next_scene = MusicSelectScene.new
      ReinoOtoge.change_scene(next_scene)
    end
  end
end
