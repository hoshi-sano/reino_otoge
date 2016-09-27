module ReinoOtoge
  # 楽曲用のデータをまとめるクラス
  # 特定のディレクトリに楽曲に関するファイルを配置し、それらを読み込むことで
  # ゲーム中で扱う楽曲データとしてオブジェクト化できる
  class MusicData
    include HelperMethods

    LANE_NUM_RANGE = 0..4
    PARAMETERS = {
      title:    'タイトル',
      lyrics:   '作詞',
      music:    '作曲',
      note:     '備考',
      lv:       '楽曲Lv',
      spending: '消費',
      speed:    'スピード',
    }
    SINGLE_NOTE_CHAR  = 'o'
    LONG_NOTE_CHAR    = '0'
    L_FLICK_NOTE_CHAR = '<'
    R_FLICK_NOTE_CHAR = '>'
    NOTE_CHAR_TO_CLASS_MAP = {
      SINGLE_NOTE_CHAR  => Note,
      LONG_NOTE_CHAR    => LongNote,
      L_FLICK_NOTE_CHAR => LeftFlickNote,
      R_FLICK_NOTE_CHAR => RightFlickNote,
    }
    FINISH_FLICK_CHAR = '.'
    COMMENT_CHAR = '#'
    # 成績境界計算や目標アピール値計算に利用する倍率
    SCORE_GRADE_RATIOS = {
      S: 0.6,
      A: 0.5,
      B: 0.4,
      C: 0.3,
    }
    # 固有の背景画像を持たない場合に利用する共通背景画像
    COMMON_BG_IMAGE = load_image('default-live-back')

    class << self
      # 楽曲ディレクトリに配置されている楽曲データを全て読み込んで返す
      # 通常ディレクトリとカスタマイズディレクトリに重複した番号の楽曲
      # が存在する場合、カスタマイズディレクトリの方を優先する
      def all
        [
          File.join(CUSTOM_MUSIC_DIR, "[0-9][0-9][0-9]_*"),
          File.join(MUSIC_DIR, "[0-9][0-9][0-9]_*"),
        ].map do |pattern|
          Dir.glob(pattern).map do |path|
            path.split(File::Separator).last.match(/[0-9]{3}/)[0].to_i
          end
        end.flatten.uniq.sort.map { |idx| new(idx) }
      end
    end

    attr_accessor *PARAMETERS.keys
    attr_reader :lanes, :bg_image, :artwork_image

    # 楽曲ディレクトリに配置されている楽曲データのうち、引数で指定した
    # 番号を持つ楽曲を読み込んでオブジェクト化する
    # 通常ディレクトリとカスタマイズディレクトリに重複した番号の楽曲
    # が存在する場合、カスタマイズディレクトリの方を優先する
    # @param [Integer] idx 楽曲のインデックス
    def initialize(idx)
      @idx = idx
      raise "music '#{'%03d' % idx}' does not exist" unless music_dir_path
      load_music_info
      @speed ||= DEFAUTL_SPEED
      @lanes = LANE_NUM_RANGE.to_a.map { |num| Lane.new(num, self) }
      load_images
      load_notes
    end

    def music_dir_path
      return @music_dir_path if @music_dir_path
      pattern = File.join(CUSTOM_MUSIC_DIR, "#{'%03d' % @idx}_*")
      @music_dir_path = Dir.glob(pattern).first
      return @music_dir_path if @music_dir_path
      pattern = File.join(MUSIC_DIR, "#{'%03d' % @idx}_*")
      @music_dir_path = Dir.glob(pattern).first
    end

    def length
      @length ||= @lanes.first.length
    end

    # フルコンボのコンボ数
    def full_combo_note_count
      @full_combo_note_count ||= @lanes.map(&:note_count).inject(&:+)
    end

    # スコアの成績別境界
    def score_grade_border
      @score_grade_border ||=
        SCORE_GRADE_RATIOS.map { |grade, ratio|
          [grade, @lv * 10000 * ratio]
        }.to_h
    end

    # 目標アピール値
    # NOTE: 現状特に根拠なし、根拠ある計算をすべし
    def target_appeal
      @target_appeal ||= (score_grade_border[:S] / 3.0).to_i
    end

    # 譜面が定義されているファイルのパスを返す
    def note_file_path
      File.join(@music_dir_path, 'chart')
    end

    # ライブシーンの背景画像ファイルのパスを返す
    def bg_image_file_path
      File.join(@music_dir_path, 'back.png')
    end

    # 楽曲のアートワーク(ジャケット)用画像ファイルのパスを返す
    def artwork_image_file_path
      File.join(@music_dir_path, 'artwork.png')
    end

    # 楽曲のメイン音楽ファイルのパスを返す
    def bgm_file_path
      File.join(@music_dir_path, 'bgm.mp3')
    end

    # 楽曲のプレビュー音楽ファイルのパスを返す
    def preview_file_path
      path = File.join(@music_dir_path, 'preview.mp3')
      File.exists?(path) ? path : bgm_file_path
    end

    # 楽曲情報を保管したyamlファイルのパスを返す
    def info_file_path
      File.join(@music_dir_path, 'info.yml')
    end

    # 楽曲のメイン音楽ファイルを読み込む
    def load_bgm
      @bgm = Ayame.new(bgm_file_path)
      @bgm.prefetch
      @bgm.predecode
      @bgm.set_volume(100, 1)
    end

    # 楽曲のプレビュー音楽ファイルを読み込む
    def load_preview
      @preview = Ayame.new(preview_file_path)
      @preview.prefetch
      @preview.predecode
      @preview.set_volume(100, 1)
    end

    # メイン音楽の再生を開始する
    def play_music
      @bgm.play(1, 1)
    end

    # メイン音楽の再生を停止する
    def stop_music(dispose = true)
      @bgm.stop(0)
      @bgm.dispose if dispose
    end

    # プレビュー音楽の再生を開始する
    def play_preview
      load_preview
      @preview.play(0, 2)
    end

    # プレビュー音楽の再生を停止する
    def stop_preview(dispose = true)
      @preview.stop(0)
      @preview.dispose if dispose
    end

    def music_finished?
      @bgm.finished?
    end

    # ライブシーンで利用する画像を読み込みオブジェクトを生成する
    def load_images
      if File.exists?(bg_image_file_path)
        @bg_image = Image.load(bg_image_file_path)
      else
        @bg_image = COMMON_BG_IMAGE
      end
      @artwork_image = Image.load(artwork_image_file_path)
      @artwork_image = resize(@artwork_image, 190, 190)
    end

    def load_music_info
      @info = YAML.load_file(info_file_path)
      PARAMETERS.keys.each do |key|
        send("#{key}=", @info[key.to_s])
      end
    end

    # 譜面の定義ファイルを読み込みオブジェクトを生成する
    def load_notes
      File.open(note_file_path) do |f|
        f.readlines.reverse.each do |str|
          # 行の先頭が '#' だった場合はコメント行なのでskip
          next if str[0] == COMMENT_CHAR
          notes_per_line = []
          # 行の末尾が数字だった場合、数字の回数分だけその行を繰り返す
          matched = str.match(/.{5}(\d+)\Z/)
          repeat_num = matched ? matched[1].to_i : 1
          repeat_num.times do |i|
            @lanes.each do |lane|
              char = str[lane.line_number]
              raise "each line must be at least 5 characters: #{str}" unless char
              lane.finish_flick! if char == FINISH_FLICK_CHAR
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
            # 1行ごとの後処理
            @lanes.each(&:post_read_proc)
          end
        end
        raise 'not finished long note exists' if @lanes.any?(&:down?)
      end
    end
  end
end
