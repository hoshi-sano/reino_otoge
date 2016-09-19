module ReinoOtoge
  # シーン内で表示/非表示が切り替わる画面要素のベースとなるクラス
  class PartialView
    SHOW_HIDE_SPEED = 50

    attr_accessor :finish_hiding_callback

    def initialize
      # 要素の描画先をRenderTargetにすることで、表示する要素を一括で表示/非表示
      # 切り替えることを実現する。
      # 継承先のクラスでは以下のようなコードを実行する必要がある。
      #
      #   some_sprite.target = @render_target
      #
      @render_target = RenderTarget.new(WINDOW_WIDTH, WINDOW_HEIGHT, [0, 0, 0, 0])
    end

    # show!/hide!メソッドがanimationフラグONで呼ばれていた場合に全体をスライド
    # して登場/退場するようなアニメーションを行う。
    def update
      return if hidden?
      if moving?
        exec_finish_hiding_callback if finish_hiding?
        @render_target.ox += @hide ? -SHOW_HIDE_SPEED : SHOW_HIDE_SPEED
      end
    end

    def draw
      return if hidden?
      Window.draw(0, 0, @render_target)
    end

    # 画面左端に隠れた表示部を登場させる
    # animationフラグがfalseの場合は1フレームで登場する
    def show!(animation = true)
      @hide = false
      if animation
        # これが呼び水(moving?がtrue)となって全体がスライドする
        # アニメーションが行われる
        @render_target.ox += SHOW_HIDE_SPEED
      else
        @render_target.ox = 0
      end
    end

    # 表示部を画面左端に隠れさせる
    # animationフラグがfalseの場合は1フレームで隠れる
    def hide!(animation = true)
      @hide = true
      if animation
        # これが呼び水(moving?がtrue)となって全体がスライドする
        # アニメーションが行われる
        @render_target.ox -= SHOW_HIDE_SPEED
      else
        @render_target.ox = -WINDOW_WIDTH
      end
    end

    # 表示部分全体がスライド中か否かを返す
    def moving?
      @render_target.ox < 0 && @render_target.ox > -WINDOW_WIDTH
    end

    def show?
      !@hide && !moving?
    end

    def hidden?
      @hide && !moving?
    end

    # 次の移動で完全に非表示になる場合はtrueを返す
    def finish_hiding?
      @hide &&
        moving? &&
        ((@render_target.ox - SHOW_HIDE_SPEED) <= -WINDOW_WIDTH)
    end

    private

    def exec_finish_hiding_callback
      return unless @finish_hiding_callback
      @finish_hiding_callback.call
    end
  end
end

