module ReinoOtoge
  # ユニット(複数のアイドルによるグループ)を表現するクラス
  class Unit
    CENTER_INDEX = 2
    # ライブシーンにおけるキャラの立ち位置の基準点
    STAND_POSTIONS = [
      [135, 310], # 左端
      [230, 310],
      [325, 310], # センター
      [420, 310],
      [515, 310], # 右端
    ]
    THUMBNAIL_MARGIN = 20

    attr_reader :idols

    def initialize(*idols)
      if idols.all? { |i| i.is_a?(Idol) }
        @idols = idols
      elsif idols.all? { |i| i.is_a?(Integer) }
        @idols = idols.map { |num| Idol.new(num) }
      else
        raise "arguments must be Integer or Idol: #{idols}"
      end
      set_idol_xy
    end

    # TODO: ユニット名を指定可能にする
    def name
      'ユニット１'
    end

    %i(life vocal visual performance).each do |idol_attr|
      define_method("sum_#{idol_attr}") do
        @idols.map { |idol| idol.public_send(idol_attr) }.inject(&:+)
      end
    end

    # 総アピール値
    def appeal
      sum_vocal + sum_visual + sum_performance
    end

    def center
      @idols[CENTER_INDEX]
    end

    def size
      @idols.size
    end

    def [](idx)
      @idols[idx]
    end

    def []=(idx, idol)
      @idols[idx] = idol
    end

    # ユニット内の全員分のサムネイルを1枚の画像にまとめて返す
    # @return [Image]
    def thumbnails
      return @thumbnails if @thumbnails
      sample = @idols.first.thumbnail
      img = Image.new(sample.width * size + THUMBNAIL_MARGIN * (size-1),
                      sample.height,
                      [0, 0, 0, 0])
      @idols.each_with_index do |idol, idx|
        img.draw(sample.width * idx + THUMBNAIL_MARGIN * idx, 0, idol.thumbnail)
      end
      @thumbnails = img
    end

    # ライブシーンで表示する打鍵部分のサムネイルを生成し配列で返す
    # @return [Array<Sprite>]
    def generate_hit_thumbnails
      @idols.map.with_index do |idol, idx|
        Sprite.new(0, 0, idol.hit_thumbnail).tap do |spr|
          spr.x = HIT_POSITION_CENTERS[idx][0] - spr.image.width / 2
          spr.y = HIT_POSITION_CENTERS[idx][1] - spr.image.height / 2
        end
      end
    end

    private

    # デフォルメキャラの表示位置を決定する
    def set_idol_xy
      @idols.each_with_index do |idol, i|
        base_x, base_y = STAND_POSTIONS[i]
        idol.x = base_x - idol.image.width / 2
        idol.y = base_y - idol.image.height
      end
    end
  end
end
