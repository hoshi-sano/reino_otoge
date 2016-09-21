module ReinoOtoge
  # ライブ(メインのリズムゲームモード)を表現するシーン
  class LiveScene < Scene
    manager_module LiveManager
    # @param [ReinoOtoge::Unit] unit ライブに参加するユニット
    # @param [ReinoOtoge::MusicData] music_data 選択した楽曲のデータ
    def initialize(unit, music_data)
     super
    end

    def pre_process
      super
      GC.start
      GC.disable
    end

    def post_process
      super
      GC.enable
      GC.start
    end
  end
end
