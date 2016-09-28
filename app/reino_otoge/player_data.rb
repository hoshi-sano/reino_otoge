module ReinoOtoge
  module PlayerData
    module ModuleMethods
      ACCESSABLE_PARAMS = %i(
        lv current_exp next_exp
        current_stamina max_stamina
        money stone score favorite
      )

      ACCESSABLE_PARAMS.each do |param|
        define_method(param) do
          instance_variable_get("@#{param}")
        end
      end

      # NOTE: 暫定的に固定値を保持
      def init
        @lv = 115
        @current_exp = 1200
        @next_exp = 3300
        @current_stamina = 75
        @max_stamina = 75
        @money = 32_000_000
        @stone = 22500
        @score = 798
        @favorite = Unit.new(3, 2, 0, 1, 4)
      end

      def spend_stamina(val)
        @current_stamina -= val
        ReinoOtoge.update_header_menu_bar
      end

      def recover_stamina(val = 1)
        @current_stamina += val
        @current_stamina = @max_stamina if @current_stamina > @max_stamina
        ReinoOtoge.update_header_menu_bar
      end

      # NOTE: 暫定的に固定値を返す
      def notifications
        {
          notice: 0,
          friend: 1,
          mission: 0,
          present: 3,
        }
      end
    end
    extend ModuleMethods
  end
end
