module ReinoOtoge
  module HomeManager
    include HelperMethods

    module ModuleMethods
      HOME_BUTTON_IDS = %i(notice friend mission present)
      HOME_BUTTON_XY = [420, 365]

      def init
        @favorite_unit = PlayerData.favorite
        # センターアイドルが初期表示
        @current_index = Unit::CENTER_INDEX
        @current_idol_sprite = Sprite.new(0, 0)
        reset_current_idol_image
        @idol_message_window = HomeIdolMessageWindow.new(current_idol)
        # ホーム画面のアイコンボタン群
        @home_buttons = HOME_BUTTON_IDS.map.with_index do |button_id, n|
          HomeIconButton.new(button_id, n).tap do |button|
            count = PlayerData.notifications[button_id]
            button.show_badge(count) if count > 0
          end
        end
        @event_notifier = EventNoifier.new
        @components = [@current_idol_sprite, @idol_message_window,
                       @home_buttons, @event_notifier]
      end

      def current_idol
        @favorite_unit[@current_index]
      end

      def reset_current_idol_image
        @current_idol_sprite.image = current_idol.portrait
        @current_idol_sprite.x = (WINDOW_WIDTH / 2) - (current_idol.portrait.width / 2)
        @current_idol_sprite.y = WINDOW_HEIGHT - current_idol.portrait.height
      end

      def change_current_idol(direction)
        @current_index += direction
        @current_index = @current_index % @favorite_unit.size
        reset_current_idol_image
        @idol_message_window.idol = current_idol
        SE.play(:change)
      end

      def update_components
        @idol_message_window.update
      end

      def draw_components
        Window.draw(0, 0, current_idol.back)
        Sprite.draw(@components)
      end

      def check_keys
        if Input.key_push?(K_LEFT)
          change_current_idol(-1)
        elsif Input.key_push?(K_RIGHT)
          change_current_idol(1)
        end
      end

      def check_click
        # アイドル画像をクリックするとメッセージを更新する
        @idol_message_window.reset if @current_idol_sprite === MOUSE_POINTER
      end
    end
    extend ModuleMethods
  end
end
