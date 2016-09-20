module ReinoOtoge
  module MusicSelectManager
    module ModuleMethods
      attr_reader :music_data_window, :unit_select_window

      def init
        @music_data_ary = MusicData.all
        @music_data_window = MusicDataWindow.new(@music_data_ary)
        selected_music.play_preview
        @unit_select_window = UnitSelectWindow.new
        @unit_select_window.hide!(false)
        @music_data_window.finish_hiding_callback = Proc.new do
          @unit_select_window.music_data = selected_music
          @unit_select_window.show!
        end
        @live_header_menu = LiveHeaderMenuBar.new
      end

      # 現在選択中の楽曲データを返す
      def selected_music
        @music_data_window.selected
      end

      # 現在選択中のユニットを返す
      def selected_unit
        @unit_select_window.selected
      end

      # 現在選択中の楽曲データを変更する
      # @param [Integer] direction 変更の方向(1または-1を指定する)
      def change_selected_music(direction)
        SE.play(:scratch)
        selected_music.stop_preview
        @music_data_window.change(direction)
        selected_music.play_preview
      end

      def update_components
        @music_data_window.update
        @unit_select_window.update
      end

      def draw_components
        @music_data_window.draw_bg_image
        @music_data_window.draw
        @unit_select_window.draw
        @live_header_menu.draw
      end

      def check_keys
        @music_data_window.check_keys
        @unit_select_window.check_keys
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
