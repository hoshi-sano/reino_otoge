module ReinoOtoge
  require 'date'

  # イベント告知などを表示するためのクラス
  # 現状表示以外に特に用途なし
  class EventNoifier < Sprite
    include HelperMethods

    POSITION = [35, 270]
    WINDOW_IMAGE = load_image('event-thumbnail-window')
    RIBBON_IMAGE = load_image('event-thumbnail-ribbon')
    RELATIVE_POSITIONS = {
      ribbon:    [6, 6],
      thumbnail: [13, 12],
    }

    class << self
      # イベントディレクトリに配置されているイベントデータから、
      # 引数に指定した日付に開催されるものを最初に見つかった1件の
      # pathを返す。該当するものが存在しない場合はnilを返す。
      def find_dir(date = Date.today)
        res = nil
        [
          File.join(CUSTOM_EVENT_DIR, "*"),
          File.join(EVENT_DIR, "*"),
        ].each do |pattern|
          res = Dir.glob(pattern).find do |path|
            yml_path = File.join(path, 'info.yml')
            next unless File.exist?(yml_path)
            info = YAML.load_file(yml_path)
            info[:start_date] <= date && info[:end_date] >= date
          end
          break if res
        end
        res
      end
    end

    def initialize
      super(*POSITION, WINDOW_IMAGE.dup)
      if @event_dir = self.class.find_dir
        @ribbon = Sprite.new(self.x + RELATIVE_POSITIONS[:ribbon][0],
                             self.y + RELATIVE_POSITIONS[:ribbon][1], RIBBON_IMAGE)
        @event_thumbnail = Sprite.new(self.x + RELATIVE_POSITIONS[:thumbnail][0],
                                      self.y + RELATIVE_POSITIONS[:thumbnail][1],
                                      event_thumbnail)
        @components = [@event_thumbnail, @ribbon]
      end
    end

    def event_thumbnail
      return nil unless @event_dir
      img_path = File.join(@event_dir, 'thumbnail.png')
      File.exist?(img_path) ? Image.load(img_path) : Image.new(1, 1)
    end

    def draw
      return unless @event_dir
      super
      Sprite.draw(@components)
    end
  end
end
