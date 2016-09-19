module ReinoOtoge
  # 各シーンのベースとなるクラス
  class Scene
    BLACK_CURTAIN = Sprite.new(0, 0, Image.new(WINDOW_WIDTH, WINDOW_HEIGHT, C_BLACK))

    class << self
      # このシーンで利用するManagerモジュールを指定するためのメソッド
      def manager_module(mod)
        @manager_module = mod
      end

      # このシーンで共通ヘッダメニューを利用する場合はこのメソッドを利用する
      def use_menu_header
        @use_menu_header = true
      end

      # このシーンで共通フッタメニューを利用する場合はこのメソッドを利用する
      def use_menu_footer
        @use_menu_footer = true
      end

      # 共通ヘッダメニュー、フッタメニューの更新/描画用のProcを返す
      # ヘッダメニュー、フッタメニューを利用しない場合は空Procを返す
      def header_footer_proc
        if @use_menu_header && @use_menu_footer
          Proc.new do
            ReinoOtoge.update_footer_menu_bar
            ReinoOtoge.draw_footer_menu_bar
            ReinoOtoge.draw_header_menu_bar
            ReinoOtoge.check_footer_click
          end
        elsif @use_menu_header
          Proc.new do
            ReinoOtoge.draw_header_menu_bar
          end
        elsif @use_menu_footer
          Proc.new do
            ReinoOtoge.update_footer_menu_bar
            ReinoOtoge.draw_footer_menu_bar
            ReinoOtoge.check_footer_click
          end
        else
          Proc.new {}
        end
      end
    end

    def initialize(*args)
      @manager = self.class.instance_variable_get(:@manager_module)
      args.any? ? @manager.init(*args) : @manager.init
      BLACK_CURTAIN.alpha = 0
      @header_footer_proc = self.class.header_footer_proc
    end

    def play
      @manager.update_components
      @manager.draw_components
      @manager.check_keys
      @header_footer_proc.call
    end

    # シーン切替時のフェードアウト処理
    # キー入力のチェックを行わないことでフェードアウト中の操作を禁止している
    # @return [Boolean] 次のシーンに遷移可能か否か
    def fade_out
      @manager.update_components
      @manager.draw_components
      @header_footer_proc.call
      BLACK_CURTAIN.alpha += (BLACK_CURTAIN.alpha > 225) ? 1 : 10
      BLACK_CURTAIN.draw
      BLACK_CURTAIN.alpha >= 255
    end
  end
end
