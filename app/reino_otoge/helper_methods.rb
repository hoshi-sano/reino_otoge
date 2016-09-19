module ReinoOtoge
  module HelperMethods
    def self.included(base)
      # 以下で定義するメソッドをインスタンスメソッドとしても
      # クラスメソッドとしても利用可能にする
      base.extend(self)
    end

    def find_file(dirs, name, exts)
      res = nil
      name_pattern = "#{name}.{#{exts.join(',')}}"
      Array(dirs).each do |dir|
        pattern = File.join(dir, name_pattern)
        res = Dir.glob(pattern).first
        break if res
      end
      res
    end

    # 画像配置用ディレクトリから指定した名前の画像ファイルを読み込む
    # @param [String] name ファイル名(拡張子除く)
    def load_image(name)
      path = find_file([CUSTOM_IMAGE_DIR, IMAGE_DIR], name, %w(png jpg))
      Image.load(path)
    end

    # 画像配置用ディレクトリから指定した名前の画像ファイルを読み込み、
    # 指定した数で分割し配列で返す
    # @param [String] name ファイル名(拡張子除く)
    # @param [Integer] x_count X軸分割数
    # @param [Integer] y_count Y軸分割数
    def load_image_tiles(name, x_count, y_count)
      path = find_file([CUSTOM_IMAGE_DIR, IMAGE_DIR], name, %w(png jpg))
      Image.load_tiles(path, x_count, y_count)
    end

    # 音声配置用ディレクトリから指定した名前の音声ファイルを読み込み、
    # Ayameオブジェクトを返す
    # 指定した名前の音声ファイルが存在しない場合、空音声ファイルを読み
    # 込んだAyameオブジェクトを返す
    # @param [String] name ファイル名(拡張子除く)
    # @return [Ayame]
    def load_sound(name)
      path = find_file([CUSTOM_SOUND_DIR, SOUND_DIR], name, %w(wav ogg mp3))
      path = find_file(SOUND_DIR, 'silent', %w(wav)) unless path
      Ayame.new(path)
    end

    # 引数imageで指定するImageオブジェクトを、引数wとhで指定したサイズに
    # 拡大、縮小して返す
    # @param [Image]   image サイズ変更対象のImageオブジェクト
    # @param [Integer] w     サイズ変更後の横幅
    # @param [Integer] h     サイズ変更後の高さ
    # @return [Image]
    def resize(image, w, h)
      return image if (image.width == w) && (image.height == h)
      rt = RenderTarget.new(w, h)
      sp = Sprite.new(0, 0, image)
      sp.target = rt
      sp.center_x = 0
      sp.center_y = 0
      sp.scale_x = w.to_f / image.width
      sp.scale_y = h.to_f / image.height
      sp.draw
      rt.to_image
    end
  end
end
