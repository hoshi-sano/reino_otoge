module ReinoOtoge
  class HitboxGroup
    attr_reader :lane

    HIT_MAP = {
      perfect: nil,
      great:   nil,
      nice:    nil,
      bad:     nil,
    }

    def initialize(lane, speed)
      @lane = lane
      @lane.hitbox_group = self
      @hit_effect = @lane.hit_effect
      @hitboxes = [
        Perfect.new(self, 0, speed),
        Great.new(self,   0, speed),
        Nice.new(self,    0, speed),
        Bad.new(self,     0, speed),
      ]
      @current_index = 0
      @hit_map = HIT_MAP.dup
    end

    # 判定を有効にする
    def enable!
      return unless @hitboxes[@current_index]
      @hitboxes[@current_index].enable!
    end

    # 判定を無効にする
    def disable!
      @hitboxes.each(&:disable!)
    end

    def change!
      @current_index += 1
      @current_index = @current_index % (@hitboxes.size + 1)
      disable!
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
      def self.image(img_height)
        raise NotImplementedError
      end

      def initialize(group, order, speed)
        @group = group
        @type = self.class.name.split('::').last.downcase.to_sym
        h = speed * 2
        x = (@group.lane.line_number + 1) * ReinoOtoge::KEY_SPACING
        y = ReinoOtoge::KEY_LINE_Y + (order * h)
        super(x, y, self.class.image(h))
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
      def self.image(img_height)
        Image.new(50, img_height, [255, 0, 0])
      end
    end

    class Great < Base
      def self.image(img_height)
        Image.new(50, img_height, [0, 255, 0])
      end
    end

    class Nice < Base
      def self.image(img_height)
        Image.new(50, img_height, [0, 0, 255])
      end
    end

    class Bad < Base
      def self.image(img_height)
        Image.new(50, img_height, [255, 255, 255])
      end
    end
  end
end
