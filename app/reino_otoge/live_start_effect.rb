module ReinoOtoge
  # 楽曲のタイトル・作詞・作曲の表示やフェードアウト等を行うクラス
  class LiveStartEffect
    include HelperMethods

    READY_IMAGE = load_image('ready')
    MUSIC_TITLE_BACK_IMAGE = load_image('music-title-back')
    READY_POSITION = [(WINDOW_WIDTH / 2) - (READY_IMAGE.width / 2),
                      (WINDOW_HEIGHT / 2) - (READY_IMAGE.height / 2)]
    MUSIC_TITLE_BACK_POSITION = [
      (WINDOW_WIDTH / 2) - (MUSIC_TITLE_BACK_IMAGE.width / 2),
      (WINDOW_HEIGHT / 2) - (MUSIC_TITLE_BACK_IMAGE.height / 2) - 50,
    ]
    BLACK_IMAGE = Image.new(WINDOW_WIDTH, WINDOW_HEIGHT, [200, 0, 0, 0])
    TITLE_FONT = CFONT[32]
    DETAIL_FONT = CFONT[16]
    READY_SCALES = [3.0, 2.7, 2.4, 2.1, 1.9, 1.7, 1.5, 1.4, 1.3, 1.2, 1.1,
                    *([1.0] * 60),
                    0.9, 0.8, 0.7, 0.8, 0.9, 1.0, 1.2, 1.5, 2.0, 3.0]

    def initialize(music_data)
      @ready = Sprite.new(*READY_POSITION, READY_IMAGE)
      @ready.center_x = @ready.image.width / 2
      @ready.center_y = @ready.image.height / 2
      @ready.visible = false
      @title = Sprite.new(*MUSIC_TITLE_BACK_POSITION, MUSIC_TITLE_BACK_IMAGE.dup)
      set_music_detail(music_data)
      @black_curtain = Sprite.new(0, 0, BLACK_IMAGE)
      @count = 0
      @current_update_method = method(:update_for_show_title)
      @current_draw_method = method(:draw_for_show_title)
    end

    def set_music_detail(music_data)
      center_x = (@title.image.width / 2)
      title_str_width = TITLE_FONT.get_width(music_data.title)
      title_x = center_x - (title_str_width / 2)
      @title.image.draw_font_ex(title_x, 50, music_data.title, TITLE_FONT)
      lyric_str = "作詞: #{music_data.lyrics}"
      lyric_str_width = DETAIL_FONT.get_width(lyric_str)
      lyric_x = center_x - (lyric_str_width / 2)
      @title.image.draw_font_ex(lyric_x, 110, lyric_str, DETAIL_FONT)
      music_str = "作曲: #{music_data.music}"
      music_str_width = DETAIL_FONT.get_width(music_str)
      music_x = center_x - (music_str_width / 2)
      @title.image.draw_font_ex(music_x, 130, music_str, DETAIL_FONT)
      note_str = music_data.note.to_s
      note_str_width = DETAIL_FONT.get_width(note_str)
      note_x = center_x - (note_str_width / 2)
      @title.image.draw_font_ex(note_x, 150, note_str, DETAIL_FONT)
    end

    def update
      @current_update_method.call
      @count += 1
    end

    def draw
      @current_draw_method.call
    end

    # タイトル・作詞・作曲等を表示するフェーズで実行されるupdate処理
    def update_for_show_title
      if @count > 180
        @ready_scales = READY_SCALES.dup
        @current_update_method = method(:update_for_show_ready)
        @current_draw_method = method(:draw_for_show_ready)
        @ready.visible = true
      elsif @count > 120
        @title.alpha = @title.alpha - 4
        @black_curtain.alpha = @black_curtain.alpha - 3
      end
    end

    # タイトル・作詞・作曲等を表示するフェーズで実行されるdraw処理
    def draw_for_show_title
      @black_curtain.draw
      @title.draw
    end

    # 「READY」を表示するフェーズで実行されるupdate処理
    def update_for_show_ready
      scale = @ready_scales.shift
      if scale.nil?
        @finish = true
        return
      end
      @ready.scale_x = scale
      @ready.scale_y = scale
    end

    # 「READY」を表示するフェーズで実行されるdraw処理
    def draw_for_show_ready
      @ready.draw
    end

    # エフェクトが終了したかどうかの判定
    def finished?
      !!@finish
    end
  end
end
