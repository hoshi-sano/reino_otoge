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
        @idol_message_window = HomeIdolMessageWindow.new(current_idol)
        # ホーム画面のアイコンボタン群
        @home_buttons = HOME_BUTTON_IDS.map.with_index do |button_id, n|
          HomeIconButton.new(button_id, n).tap do |button|
            count = PlayerData.notifications[button_id]
            button.show_badge(count) if count > 0
          end
        end
        @event_notifier = EventNoifier.new
        @components = [@idol_message_window, @home_buttons, @event_notifier]
      end

      def current_idol
        @favorite_unit[@current_index]
      end

      def change_current_idol(direction)
        @current_index += direction
        @current_index = @current_index % @favorite_unit.size
        @idol_message_window.idol = current_idol
      end

      def update_components
        @idol_message_window.update
      end

      def draw_components
        Window.draw(0, 0, current_idol.back)
        Window.draw((WINDOW_WIDTH / 2) - (current_idol.portrait.width / 2),
                    WINDOW_HEIGHT - current_idol.portrait.height,
                    current_idol.portrait)
        Sprite.draw(@components)
      end

      def check_keys
        if Input.key_push?(K_LEFT)
          change_current_idol(-1)
        elsif Input.key_push?(K_RIGHT)
          change_current_idol(1)
        end
      end
    end
    extend ModuleMethods
  end
end
