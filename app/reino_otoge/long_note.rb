module ReinoOtoge
  class LongNote < Note
    IMAGE = load_image('long-note')
    TRACING_IMAGE = Image.new(1, 1, image_avrg_color)

    attr_accessor :end_note

    def update
      return unless visible
      super
      return unless @synchro_note
      @synchro_note = nil if self.y >= KEY_LINE_Y
    end

    def miss!
      super
      @lane.remove_note(@end_note)
    end

    # 打鍵後の後処理
    def post_proc(lane)
      # 打鍵後も軌跡を表示するためにvanishせずにinvisibleにするだけ
      # vanishはLane#judge_long_note_fail!にてまとめて行う
      self.visible = false
      self.collision_enable = false
      @synchro_note = nil
      if @end_note
        @lane.start_long_note!(self)
      else
        @lane.finish_long_down!
      end
    end

    def draw
      if @end_note
        # 軌跡の表示
        Window.draw_morph(@end_note.current_left_x,  @end_note.y + (@end_note.center_y),
                          @end_note.current_right_x, @end_note.y + (@end_note.center_y),
                          self.current_right_x,      self.y + (self.center_y),
                          self.current_left_x,       self.y + (self.center_y),
                          TRACING_IMAGE, alpha: 150)
      end
      super
    end
  end
end
