module ReinoOtoge
  class HitboxGroup
    attr_reader :lane

    HIT_MAP = {
      perfect: nil,
      great:   nil,
      nice:    nil,
      bad:     nil,
    }

    def initialize(lane)
      @lane = lane
      @lane.hitbox_group = self
      @hit_effect = @lane.hit_effect
      @hitboxes = [
        Bad.new(self,    -3),
        Nice.new(self,   -2),
        Great.new(self,  -1),
        Perfect.new(self, 0),
        Great.new(self,   1),
        Nice.new(self,    2),
        Bad.new(self,     3),
      ]
      @hit_map = HIT_MAP.dup
    end

    # 判定を有効にする
    def enable!
      @hitboxes.each(&:enable!)
    end

    # 判定を無効にする
    def disable!
      @hitboxes.each(&:disable!)
    end

    def draw
      Sprite.draw(@hitboxes)
    end

    def to_a
      @hitboxes
    end

    # @hit_mapにこのフレーム中に当たり判定されたノートを保存する
    def hit(type, note)
      @hit_map[type] = note
    end

    def judge!
      # 当たり判定されたノートの中から最も優先度が高いノートのみを抽出する
      shooted = @hit_map.values.find { |i| i }
      return unless shooted
      type = @hit_map.key(shooted)
      LiveManager.hit!(type)
      shooted.post_proc(@lane)
      @hit_effect.show!
      # @hit_mapをクリアする
      # clear(空ハッシュ)を使わないのは優先度を保持するため
      @hit_map = HIT_MAP.dup
    end

    class Base < Sprite
      def self.image
        raise NotImplementedError
      end

      def initialize(group, order)
        @group = group
        @type = self.class.name.split('::').last.downcase.to_sym
        x = (@group.lane.line_number + 1) * ReinoOtoge::KEY_SPACING
        y = ReinoOtoge::KEY_LINE_Y + (order * 10)
        super(x, y, self.class.image)
        self.collision_sync = false
        disable!
      end

      # 判定を有効にする
      def enable!
        self.collision_enable = true
        self.visible = true
      end

      # 判定を無効にする
      def disable!
        self.collision_enable = false
        self.visible = false
      end

      def shot(note)
        @group.hit(@type, note)
      end
    end

    class Perfect < Base
      def self.image
        Image.new(50, 10, [255, 0, 0])
      end
    end

    class Great < Base
      def self.image
        Image.new(50, 10, [0, 255, 0])
      end
    end

    class Nice < Base
      def self.image
        Image.new(50, 10, [0, 0, 255])
      end
    end

    class Bad < Base
      def self.image
        Image.new(50, 10, [255, 255, 255])
      end
    end
  end
end
