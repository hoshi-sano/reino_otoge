module ReinoOtoge
  # 楽曲選択画面における楽曲情報表示部
  class MusicDataWindow < PartialView
    include HelperMethods

    ARTWORK_FRAMES = [
      load_image('artwork-frame'),
    ]
    INFO_FRAME_IMAGE = load_image('music-data-frame')
    ARTWORK_FRAME_Y = 70
    ARTWORK_Y = 75
    INFO_FRAME_XY = [55, 275]
    INFO_XY = {
      title:    [80, 330],
      lv:       [200, 370],
      spending: [360, 370],
    }
    TITLE_FONT = CFONT[32]
    LV_SPENDING_FONT = CFONT[20]
    INFO_OPTIONS = {
      color: [0, 0, 0],
    }
    DUMMY_IMAGE = Image.new(1, 1, [200, 0, 0, 0])
    SLIDE_ANIMATION_FLAME_COUNT = 6

    attr_reader :selected

    def initialize(music_data_ary)
      super()
      @music_data_ary = music_data_ary
      @artwork_frame = Sprite.new(0, ARTWORK_FRAME_Y, ARTWORK_FRAMES[0])
      @artwork = Sprite.new(0, ARTWORK_Y, @music_data_ary[0].artwork_image)
      @artwork.x = (ReinoOtoge::WINDOW_WIDTH / 2) - (@artwork.image.width / 2)
      @prev_artwork = Sprite.new(0, ARTWORK_Y, DUMMY_IMAGE)
      @prev_artwork.scale_x = @prev_artwork.scale_y = 0.6
      @prev_artwork.x = @artwork.x - (@artwork.image.width)
      @next_artwork = Sprite.new(0, ARTWORK_Y, DUMMY_IMAGE)
      @next_artwork.scale_x = @next_artwork.scale_y = 0.6
      @next_artwork.x = @artwork.x + (@artwork.image.width)
      @info_frame = Sprite.new(*INFO_FRAME_XY, INFO_FRAME_IMAGE)
      set(0)
      [@artwork_frame, @artwork, @prev_artwork, @next_artwork, @info_frame].each do |spr|
        spr.target = @render_target
      end
    end

    # 現在選択中の楽曲データを変更する
    # @param [Integer] direction 変更の方向(1または-1を指定する)
    def change(direction)
      size = @music_data_ary.size
      prev_select_idx = @music_data_ary.index(@selected)
      select_idx = (prev_select_idx + direction) % size
      @prev_selected = @music_data_ary[prev_select_idx]
      set(select_idx, direction)
    end

    # 引数idxで指定した楽曲データを選択中の状態にセットする
    # 引数directionを指定した場合は指定した方向にアニメーションする
    # @param [Integer] idx 選択する楽曲のインデックス
    # @param [Integer] direction 変更の方向(1または-1を指定する)
    def set(idx, direction = nil)
      @selected = @music_data_ary[idx]
      if direction
        @animation_count = SLIDE_ANIMATION_FLAME_COUNT * (direction)
      else
        @animation_count = nil
        update_selected_artwork
        update_prev_and_next_artwork
      end
    end

    # 現在選択中の楽曲データに基いて、中央に表示する画像を更新する
    def update_selected_artwork
      # TODO: 楽曲に合わせたフレームを使えるようにする
      #       今はフレーム画像が1枚しかないので不変
      @artwork_frame.image = ARTWORK_FRAMES[0]
      @artwork_frame.x = (ReinoOtoge::WINDOW_WIDTH / 2) -
                         (@artwork_frame.image.width / 2)
      @artwork.image = @selected.artwork_image
      @artwork.x = (ReinoOtoge::WINDOW_WIDTH / 2) - (@artwork.image.width / 2)
    end

    # 現在選択中の楽曲データを基にその前後の楽曲データを取得し、
    # 選択中楽曲の両脇に表示する画像を更新する
    def update_prev_and_next_artwork
      idx = @music_data_ary.index(@selected)
      next_music = @music_data_ary[(idx + 1) % @music_data_ary.size]
      prev_music = @music_data_ary[idx - 1]
      if next_music && (next_music != @selected)
        @next_artwork.image = next_music.artwork_image
        @next_artwork.center_x = @next_artwork.image.width / 2
        @next_artwork.center_y = @next_artwork.image.height / 2
      else
        @next_artwork.image = DUMMY_IMAGE
      end
      if prev_music && (prev_music != @selected) && (prev_music != next_music)
        @prev_artwork.image = prev_music.artwork_image
        @prev_artwork.center_x = @prev_artwork.image.width / 2
        @prev_artwork.center_y = @prev_artwork.image.height / 2
      else
        @prev_artwork.image = DUMMY_IMAGE
      end
    end

    # 親クラスの挙動に加え、左右選択時、楽曲のアートワークがスライドする
    # アニメーションを行う
    def update
      super
      return unless @animation_count
      direction = @animation_count / @animation_count.abs
      # カウントは0に収束させる
      @animation_count += -direction
      @artwork.scale_x = @artwork.scale_y = (@artwork.scale_x - 0.05)
      @prev_artwork.scale_x = @prev_artwork.scale_y = (@prev_artwork.scale_x - 0.05 * direction)
      @next_artwork.scale_x = @next_artwork.scale_y = (@next_artwork.scale_x + 0.05 * direction)
      [@artwork, @prev_artwork, @next_artwork].each do |a|
        a.x -= @artwork.image.width / SLIDE_ANIMATION_FLAME_COUNT * direction
      end
      # カウントが0に達したらスライドアニメーション終了
      if @animation_count == 0
        update_selected_artwork
        update_prev_and_next_artwork
        @artwork.scale_x = @artwork.scale_y = 1.0
        @prev_artwork.scale_x = @prev_artwork.scale_y = 0.6
        @next_artwork.scale_x = @next_artwork.scale_y = 0.6
        @artwork.x = (ReinoOtoge::WINDOW_WIDTH / 2) - (@artwork.image.width / 2)
        @prev_artwork.x = @artwork.x - (@artwork.image.width)
        @next_artwork.x = @artwork.x + (@artwork.image.width)
        @animation_count = nil
      end
    end

    def draw
      return if hidden?
      draw_artworks
      draw_music_info
      Window.draw(0, 0, @render_target)
    end

    def draw_bg_image
      if @animation_count
        Window.draw(0, 0, @prev_selected.bg_image)
      else
        Window.draw(0, 0, @selected.bg_image)
      end
    end

    def check_keys
      return if hidden?
      if Input.key_push?(K_LEFT)
        MusicSelectManager.change_selected_music(-1)
      elsif Input.key_push?(K_RIGHT)
        MusicSelectManager.change_selected_music(1)
      elsif Input.key_push?(K_RETURN)
        SE.play(:ok)
        hide!
      end
    end

    private

    def draw_artworks
      Sprite.draw([@prev_artwork, @next_artwork, @artwork])
      @artwork_frame.draw unless @animation_count
    end

    def draw_music_info
      @info_frame.draw
      [
        [INFO_XY[:title],    @selected.title,         TITLE_FONT],
        [INFO_XY[:lv],       @selected.lv.to_s,       LV_SPENDING_FONT],
        [INFO_XY[:spending], @selected.spending.to_s, LV_SPENDING_FONT],
      ].each do |xy, str, font|
        @render_target.draw_font_ex(*xy, str, font, INFO_OPTIONS)
      end
    end
  end
end
