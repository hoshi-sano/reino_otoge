module ReinoOtoge
  # イベント告知などを表示するためのクラス
  # 現状表示以外に特に用途なし
  class EventNoifier < Sprite
    include HelperMethods

    POSITION = [35, 270]
    WINDOW_IMAGE = load_image('event-thumbnail-window')
    RIBBON_IMAGE = load_image('event-thumbnail-ribbon')
    EVENT_IMAGE = load_image('event-thumbnail')
    RELATIVE_POSITIONS = {
      ribbon:    [6, 6],
      thumbnail: [13, 12],
    }

    def initialize
      super(*POSITION, WINDOW_IMAGE.dup)
      @ribbon = Sprite.new(self.x + RELATIVE_POSITIONS[:ribbon][0],
                           self.y + RELATIVE_POSITIONS[:ribbon][1], RIBBON_IMAGE)
      @event_thumbnail = Sprite.new(self.x + RELATIVE_POSITIONS[:thumbnail][0],
                                    self.y + RELATIVE_POSITIONS[:thumbnail][1], EVENT_IMAGE)
      @components = [@event_thumbnail, @ribbon]
    end

    def draw
      super
      Sprite.draw(@components)
    end
  end
end
