module ReinoOtoge
  module MusicSelectManager
    module ModuleMethods
      def init
        @music_data_ary = MusicData.all
        @music_data_display = MusicDataDisplay.new(@music_data_ary)
        selected_music.play_preview
        @unit_select_display = UnitSelectDisplay.new
        @unit_select_display.hide!(false)
        @music_data_display.finish_hiding_callback = Proc.new do
          @unit_select_display.music_data = selected_music
          @unit_select_display.show!
        end
        @live_header_menu = LiveHeaderMenuBar.new
      end

      # 現在選択中の楽曲データを返す
      def selected_music
        @music_data_display.selected
      end

      # 現在選択中のユニットを返す
      def selected_unit
        @unit_select_display.selected
      end

      # 現在選択中の楽曲データを変更する
      # @param [Integer] direction 変更の方向(1または-1を指定する)
      def change_selected_music(direction)
        SE.play(:scratch)
        selected_music.stop_preview
        @music_data_display.change(direction)
        selected_music.play_preview
      end

      def update_components
        @music_data_display.update
        @unit_select_display.update
      end

      def draw_components
        @music_data_display.draw_bg_image
        @music_data_display.draw
        @unit_select_display.draw
        @live_header_menu.draw
      end

      def check_keys
        # TODO: リファクタリング
        if @music_data_display.show?
          if Input.key_push?(K_LEFT)
            change_selected_music(-1)
          elsif Input.key_push?(K_RIGHT)
            change_selected_music(1)
          elsif Input.key_push?(K_RETURN)
            SE.play(:ok)
            @music_data_display.hide!
          end
        elsif @unit_select_display.show?
          # TODO: ユニット選択をさせる
          if Input.key_push?(K_BACK)
            @unit_select_display.finish_hiding_callback =
              -> { @music_data_display.show! }
            @unit_select_display.hide!
          elsif Input.key_push?(K_RETURN)
            SE.play(:ok)
            @unit_select_display.finish_hiding_callback =
              -> { go_to_next_scene }
            @unit_select_display.hide!
          end
        end
      end

      def check_click
        @live_header_menu.check_click
      end

      def go_to_next_scene
        selected_music.stop_preview
        next_scene = LiveScene.new(selected_unit, selected_music)
        ReinoOtoge.change_scene(next_scene)
      end
    end
    extend ModuleMethods
  end
end
