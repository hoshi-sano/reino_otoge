module ReinoOtoge
  class FlickNote < Note
    TRACING_IMAGE = Image.new(1, 1, image_avrg_color)

    attr_accessor :next_note

    def update
      return unless visible
      super
      return unless @next_note
      @next_note = nil if self.y >= KEY_LINE_Y
    end

    # 打鍵後の後処理
    # 長押しの末尾に配置される可能性もあるため、
    # vanishしつつinvisibleにもする
    def post_proc(lane)
      super
      self.visible = false
    end

    def hit
      SE.play(:flick)
    end

    def draw
      if @next_note
        # 軌跡の表示
        Window.draw_morph(@next_note.current_left_x,
                          @next_note.y + (@next_note.center_y),
                          @next_note.current_right_x,
                          @next_note.y + (@next_note.center_y),
                          self.current_right_x, self.y + (self.center_y),
                          self.current_left_x,   self.y + (self.center_y),
                          TRACING_IMAGE, alpha: 150)
      end
      super
    end
  end

  class LeftFlickNote < FlickNote
    IMAGE = load_image('flick-note-left')
  end

  class RightFlickNote < FlickNote
    IMAGE = load_image('flick-note-right')
  end
end
