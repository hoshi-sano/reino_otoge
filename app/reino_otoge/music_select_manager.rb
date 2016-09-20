module ReinoOtoge
  module MusicSelectManager
    module ModuleMethods
      attr_reader :music_data_display, :unit_select_display

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
        @music_data_display.check_keys
        @unit_select_display.check_keys
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
