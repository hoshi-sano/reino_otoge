module ReinoOtoge
  # アイドル(キャラクター)を表現するクラス
  class Idol < Sprite
    include HelperMethods

    PARAMETERS = {
      lv:          'Lv',
      life:        'ライフ',
      vocal:       'ボーカル',
      visual:      'ビジュアル',
      performance: 'ダンス',
      name:        '名前',
      name_kana:   'ふりがな',
      age:         '年齢',
      messages:    'メッセージ',
    }
    # ライブシーンでのサムネイル生成用マスク画像
    # NOTE: マスク画像を別途用意するようにし、マスク画像が存在し
    #       ない場合はnoteを使うようにしたほうが柔軟性が高そう
    HIT_THUMBNAIL_MASK = resize(load_image('note'), 45, 45)
    THUMBNAIL_FRAME_IMAGE = load_image('thumbnail-frame')
    # 固有背景を持たないキャラクター用の共通背景
    COMMON_BACK = load_image('default-idol-back')

    attr_accessor *PARAMETERS.keys
    attr_reader :deformed, :portrait, :back, :thumbnail

    # @param [Integer] idx アイドルのインデックス
    def initialize(idx)
      @idol_dir_path = find_dir_path(idx)
      load_images
      load_data
    end

    # メッセージ一覧からひとつランダムで返す
    def random_message
      (@messages || []).sample
    end

    # ライブシーンで表示する打鍵部分のサムネイルを生成して返す
    # @return [Image]
    def hit_thumbnail
      return @hit_thumbnail if @hit_thumbnail
      mask = HIT_THUMBNAIL_MASK
      orig = resize(thumbnail_image, mask.width, mask.height)
      res = orig.slice(0, 0, mask.width, mask.height)
      mask.height.times do |y|
        mask.width.times do |x|
          # サムネイル用画像をマスク画像のサイズで切り出し、
          # マスク側の画素のアルファが0(完全な透明)な箇所を透明にする
          res[x, y] = [0, 0, 0, 0] if mask[x, y][0] == 0
        end
      end
      @hit_thumbnail = res
    end

    private

    # 画像やステータスを定義したファイルの配置ディレクトリへのパスを返す
    # このときカスタマイズディレクトリを優先する
    def find_dir_path(idx)
      name = "#{'%03d' % idx}_*"
      patterns = [CUSTOM_IDOL_DIR, IDOL_DIR].map { |d| File.join(d, name) }
      res = patterns.map { |ptn| Dir.glob(ptn).first }.compact.first
      raise "Directory does not exist: #{patterns.join(', ')}" unless res
      res
    end

    # デフォルメされたキャラ画像のパスを返す
    def deformed_image_file_path
      File.join(@idol_dir_path, 'deformed.png')
    end

    # 立ち絵画像のパスを返す
    def portrait_image_file_path
      File.join(@idol_dir_path, 'portrait.png')
    end

    # サムネイル画像のパスを返す
    def thumbnail_image_file_path
      File.join(@idol_dir_path, 'thumbnail.png')
    end

    # 背景画像のパスを返す
    def back_image_file_path
      File.join(@idol_dir_path, 'back.png')
    end

    # 各種データが定義されているファイルのパスを返す
    def data_file_path
      File.join(@idol_dir_path, 'data.yml')
    end

    def load_images
      @deformed = Image.load(deformed_image_file_path)
      self.image = @deformed

      if File.exist?(portrait_image_file_path)
        @portrait = Image.load(portrait_image_file_path)
      else
        @portrait = @deformed
      end

      @thumbnail = thumbnail_image.draw(0, 0, THUMBNAIL_FRAME_IMAGE)

      if File.exist?(back_image_file_path)
        @back = Image.load(back_image_file_path)
      else
        @back = COMMON_BACK
      end
    end

    def thumbnail_image
      if File.exist?(thumbnail_image_file_path)
        Image.load(thumbnail_image_file_path)
      else
        Image.new(70, 70, C_GREEN)
      end
    end

    def load_data
      @data = YAML.load_file(data_file_path)
      PARAMETERS.keys.each do |key|
        send("#{key}=", @data[key.to_s])
      end
    end
  end
end
