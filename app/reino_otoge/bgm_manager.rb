module ReinoOtoge
  module BGMManager
    module ModuleMethods
      include HelperMethods

      # BGMファイル名一覧
      BGM_FILE_NAMES = [
        :home,
        :live_result,
      ]

      def init
        @list = BGM_FILE_NAMES.map { |name|
          sound = load_sound(name.to_s)
          sound.predecode
          [name, sound]
        }.to_h
      end

      def play(id, loop = true)
        return if @now_playing == id
        stop if @now_playing && (@now_playing != id)
        @list[id].play(loop ? 0 : 1, 0)
        @now_playing = id
      end

      def stop
        @list[@now_playing].stop(1)
        @now_playing = nil
      end
    end
    extend ModuleMethods
  end
  # alias
  BGM = BGMManager
end
