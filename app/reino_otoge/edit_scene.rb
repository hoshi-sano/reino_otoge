require 'fileutils'

module ReinoOtoge
  # 譜面作成用のシーン
  class EditScene
    include HelperMethods

    KEYS = Config.live_keys
    LONG_NOTE_THRESHOLD = 10
    BUNDLE_THRESHOLD = 5
    NONE = '-'
    DOWN = 'o'
    LONG_NOTE = '0'
    CONTINUE = '|'
    FONT = CFONT[20]
    FONT_OPTIONS = {
      color: C_BLACK,
      edge: true,
      edge_color: C_WHITE,
      edge_width: 5,
      edge_level: 5,
    }
    MESSAGES = {
      start: 'Enter: 譜面作成を開始します',
      stop:  'Enter: 譜面作成を終了します',
      test:  'T: 作成した内容をテストプレーします',
      write: 'W: 作成した内容をファイルに書き出します',
      read:  'R: ファイルから譜面を読み込んでテストプレーします',
      read_error: '譜面の読み込みに失敗しました。ファイルの内容を確認してください。',
    }
    BLACK_SQUARE = Sprite.new(500, 30, Image.new(100, 100, C_BLACK))
    STOP_SQUARE = Sprite.new(525, 55, Image.new(50, 50, C_RED))
    RECORDING_CIRCLE = Sprite.new(525, 55,
                                  Image.new(100, 100).tap {|img|
                                    img.circle_fill(25, 25, 25, C_RED)
                                  })
    HIT_BAR_IMAGE = load_image('hit-bar')
    HIT_BAR_POSITION = [(WINDOW_WIDTH / 2) - (HIT_BAR_IMAGE.width / 2),
                        (WINDOW_HEIGHT / 2) - (HIT_BAR_IMAGE.height / 2)]
    HIT_BAR = Sprite.new(*HIT_BAR_POSITION, HIT_BAR_IMAGE)
    BLACK_IMAGE = Image.new(WINDOW_WIDTH, WINDOW_HEIGHT, [100, 0, 0, 0])
    BLACK_CURTAIN = Sprite.new(0, 0, BLACK_IMAGE)
    DOWN_EFFECTS = (0..4).to_a.map do |i|
      img = Image.new(50, 50).tap { |i| i.circle_fill(25, 25, 25, C_YELLOW) }
      Sprite.new(100 * i + 100, 216, img)
    end

    # @param [String] music_data_dir 譜面作成対象の楽曲データのディレクトリ名または番号
    def initialize(music_data_dir)
      @music_data = load_music_data(music_data_dir)
      @music_data.load_bgm
      @recording = false
      @delay = (KEY_LINE_Y - NOTE_GENERATE_Y) / @music_data.speed
      reset
      @recording_info_draw_method = self.method(:draw_start_recording)
      @sprites = [BLACK_CURTAIN, HIT_BAR]
    end

    # @param [String] music_data_dir 譜面作成対象の楽曲データのディレクトリ名または番号
    def load_music_data(music_data_dir)
      matched = music_data_dir.match(/\d+/)
      raise "cannot find music data for: #{music_data_dir}" unless matched
      idx = matched[0]
      MusicData.new(idx)
    end

    def reset
      @chart = [[], [], [], [], []]
      @frame_count = -@delay
      @error_message_count = 0
      @written = false
    end

    def play
      Window.draw(0, 0, @music_data.bg_image)
      Sprite.draw(@sprites)
      show_recording_info
      check_keys
      return unless @recording

      if @frame_count < 0
        @frame_count += 1
        return
      end
      @music_data.play_music if @frame_count == 0

      KEYS.each_with_index do |key, i|
        if Input.key_down?(key)
          char = DOWN
          DOWN_EFFECTS[i].draw
        else
          char = NONE
        end
        @chart[i][@frame_count] = char
      end
      @frame_count += 1
    end

    def fade_out
      true
    end

    def check_keys
      # ENTERキー押下で記録の開始/停止
      if Input.key_push?(K_RETURN)
        @recording ? finish_recording : start_recording
      end
      # Wキー押下で記録内容のファイルへの書き出し
      if Input.key_push?(K_W) && !@written
        write_chart_file
      end
      # Tキー押下で記録内容のテストプレー
      if Input.key_push?(K_T)
        goto_test_play
      end
      # Rキー押下でファイルを読み込んでテストプレー
      if Input.key_push?(K_R)
        goto_test_play(true)
      end
    end

    def show_recording_info
      @recording_info_draw_method.call
    end

    def draw_stop_recording
      Window.draw_font_ex(30, 30, MESSAGES[:stop], FONT, FONT_OPTIONS)
      BLACK_SQUARE.draw
      STOP_SQUARE.draw
    end

    def draw_start_recording
      Window.draw_font_ex(30, 30, MESSAGES[:start], FONT, FONT_OPTIONS)
      Window.draw_font_ex(30, 60, MESSAGES[:read], FONT, FONT_OPTIONS)
      if @frame_count > 0
        Window.draw_font_ex(30, 90, MESSAGES[:test], FONT, FONT_OPTIONS)
        unless @written
          Window.draw_font_ex(30, 120, MESSAGES[:write], FONT, FONT_OPTIONS)
        end
      end
      if @error_message_count > 0
        @error_message_count -= 1
        Window.draw_font_ex(30, 180, MESSAGES[:read_error], FONT, FONT_OPTIONS)
      end
      BLACK_SQUARE.draw
      RECORDING_CIRCLE.draw
    end

    def toggle_recording_info
      if @recording_info_draw_method.name == :draw_start_recording
        name = :draw_stop_recording
      else
        name = :draw_start_recording
      end
      @recording_info_draw_method = method(name)
    end

    def start_recording
      toggle_recording_info
      reset
      @recording = true
      @music_data.load_bgm
    end

    def finish_recording
      toggle_recording_info
      @recording = false
      @music_data.stop_music
    end

    def write_chart_file
      # 既にファイルが存在する場合は上書きしないようmvする
      write_path = @music_data.note_file_path
      if File.exists?(write_path)
        time_str = Time.now.strftime('%Y%m%d%H%M%S')
        old_file_path = [write_path, 'old', time_str].join('.')
        FileUtils.copy_file(write_path, old_file_path)
      end
      chart = parse_chart_ary(@chart)
      File.open(write_path, 'w') do |f|
        prev_line = nil
        repeat_count = 0
        (0..@frame_count).to_a.reverse.each do |i|
          chart_line = (0...KEYS.size).to_a.map { |j| chart[j][i] }.join
          next if chart_line.empty?
          if chart_line != prev_line
            puts_line(f, prev_line, repeat_count)
            prev_line = chart_line
            repeat_count = 1
          else
            repeat_count += 1
          end
        end
        puts_line(f, prev_line, repeat_count)
      end
      @written = true
    end

    # strに渡した文字列をrepeat_count分だけfileに行出力する
    # repeat_countに渡した数値がBUNDLE_THRESHOLDの値以上であった場合は省略記法を
    # 使ってファイルに出力する
    def puts_line(file, str, repeat_count)
      if repeat_count > BUNDLE_THRESHOLD
        BUNDLE_THRESHOLD.times { file.puts(str) }
        file.puts(str + (repeat_count - BUNDLE_THRESHOLD).to_s)
      else
        repeat_count.times { file.puts(str) }
      end
    end

    def parse_chart_ary(chart_ary)
      down_start = nil
      down_end = nil
      chart_ary.map do |chart|
        parsed_chart = []
        chart.each_with_index do |note, idx|
          if note == DOWN
            down_start ||= idx
            down_end = idx
          else
            if down_start
              if (down_end - down_start) > LONG_NOTE_THRESHOLD
                parsed_chart[down_start] = LONG_NOTE
                parsed_chart[down_end] = LONG_NOTE
                ((down_start + 1)...down_end).each { |i| parsed_chart[i] = CONTINUE }
              else
                parsed_chart[down_start] = DOWN
                ((down_start + 1)..down_end).each { |i| parsed_chart[i] = NONE }
              end
            end
            parsed_chart[idx] = NONE
            down_start = nil
            down_end = nil
          end
        end
        parsed_chart
      end
    end

    def goto_test_play(read_file = false)
      if read_file
        lanes = @music_data.lanes
        begin
          @music_data.reset_lanes!
          @music_data.load_notes
        rescue => e
          @error_message_count = 120
          puts e.message
          puts e.backtrace.join("\n")
          return
        end
      else
        @music_data.load_notes_from_meomory(parse_chart_ary(@chart))
      end
      unit = Unit.new(3, 2, 0, 1, 4)
      test_play_scene = LiveScene.new(unit, @music_data)
      ReinoOtoge.change_scene(test_play_scene)
    end
  end
end
