module ReinoOtoge
  class Note < Sprite
    include HelperMethods

    IMAGE = load_image('note')
    SYNCHRO_BAR_IMAGE = Image.new(1, 1, C_WHITE)

    attr_reader :lane
    attr_accessor :synchro_note

    class << self
      # 画像の平均色を[R, G, B]の形式で返す
      # 主に長押しノートなどの軌跡の色に利用する
      def image_avrg_color
        sum = { r: 0, g: 0, b: 0 }
        IMAGE.height.times do |j|
          IMAGE.width.times do |i|
            sum[:r] += IMAGE[i, j][1]
            sum[:g] += IMAGE[i, j][2]
            sum[:b] += IMAGE[i, j][3]
          end
        end
        pixel_num = IMAGE.width * IMAGE.height
        sum.values.map { |v| v / pixel_num }
      end
    end

    def initialize(lane, speed)
      @lane = lane
      line_number = @lane.line_number
      x = (line_number + 1) * ReinoOtoge::KEY_SPACING
      y = ReinoOtoge::NOTE_GENERATE_Y
      super(x, y, self.class.const_get(:IMAGE))
      @speed = speed

      update_scale
      self.collision_sync = false
      self.collision = [self.center_x, self.center_y]
    end

    def current_width
      self.image.width * scale_x
    end

    def current_height
      self.image.height * scale_y
    end

    def current_left_x
      self.x + self.center_x - (current_width / 2)
    end

    def current_right_x
      self.x + self.center_x + (current_width / 2)
    end

    def current_middle_y
      self.y + self.center_y
    end

    def update
      update_scale
      self.y += @speed
      return if self.y < KEY_LINE_Y
      @synchro_note = nil
      miss! if self.y > Window.height # TODO: MISSのラインを決める
    end

    def miss!
      LiveManager.miss!
      vanish
    end

    def update_scale
      self.scale_x = self.scale_y = Math.log10((self.y / 300.0) * 10)
    end

    # 打鍵時の処理
    # 優先度を考慮した評価判定はLane#judge!とHitboxGroup#judge!で
    # 行うため、現状ここでは何もしない
    def hit
      SE.play(:hit)
    end

    # 打鍵後の後処理
    # 単純なノートの場合はただ画面から消すだけ
    def post_proc(lane)
      vanish
    end

    def draw
      # 同時出現のノートとの連結バーを表示する
      if @synchro_note && !@synchro_note.vanished?
        Window.draw_morph(self.current_right_x,          self.current_middle_y          - 4,
                          @synchro_note.current_left_x,  @synchro_note.current_middle_y - 4,
                          @synchro_note.current_left_x,  @synchro_note.current_middle_y + 4,
                          self.current_right_x,          self.current_middle_y          + 4,
                          SYNCHRO_BAR_IMAGE, alpha: 150)
      end
      super
    end
  end
end
