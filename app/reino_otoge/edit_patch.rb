# 譜面作成用に各種挙動を変更するためのパッチ
module ReinoOtoge
  class MusicData
    def reset_lanes!
      @lanes = LANE_NUM_RANGE.to_a.map { |num| Lane.new(num, self) }
    end

    # 譜面の定義ファイルを読み込みオブジェクトを生成する
    def load_notes_from_meomory(chart)
      reset_lanes!
      (0...chart.first.size).to_a.each do |i|
        chart_line = LANE_NUM_RANGE.to_a.map { |j| chart[j][i] }.join
        next if chart_line.empty?
        notes_per_line = []
        @lanes.each do |lane|
          char = chart_line[lane.line_number]
          raise "each line must be at least 5 characters: #{line}" unless char
          klass = NOTE_CHAR_TO_CLASS_MAP[char]
          unless klass
            lane.add_nil
            next
          end
          notes_per_line << lane.add_note(klass)
        end
        # 同じタイミングで出現するノートは表示の都合でペアにする
        if notes_per_line.size > 1
          notes_per_line[0].synchro_note = notes_per_line[1]
        end
      end
    end
  end

  class LiveScene
    QUIT_MESSAGE = 'Enter: 編集画面に戻ります'
    FONT = CFONT[20]
    FONT_OPTIONS = {
      color: C_BLACK,
      edge: true,
      edge_color: C_WHITE,
      edge_width: 5,
      edge_level: 5,
    }

    def play
      if Input.key_push?(K_RETURN)
        @manager.instance_variable_get(:@music_data).stop_music
        ReinoOtoge.change_scene(EDIT_SCENE)
      end
      @manager.update_components
      @manager.draw_components
      @manager.check_keys
      Window.draw_font_ex(30, 70, QUIT_MESSAGE, FONT, FONT_OPTIONS)
    end
  end

  module LiveManager
    module ModuleMethods
      def update_components_in_succeed
        ReinoOtoge.change_scene(EDIT_SCENE)
      end
    end
  end

  module BGMManager
    module ModuleMethods
      def init; end
      def play(id); end
      def stop; end
    end
  end
end
