module ReinoOtoge
  module SoundEffectManager
    module ModuleMethods
      include HelperMethods

      # 効果音ファイル名一覧
      SE_FILE_NAMES = [
        :beep,       # ビープ音 (適切な名称かどうかは要検討)
        :cancel,     # キャンセル音
        :cheer,      # 歓声
        :change,     # 切替音
        :flick,      # フリックノートを叩く音
        :full_combo, # フルコンボ達成時効果音
        :hit,        # 通常ノートを叩く音
        :next,       # サブ決定音
        :ok,         # 決定音
        :scratch,    # 楽曲選択時などの選択変更効果音
      ]

      def init
        @list = SE_FILE_NAMES.map { |name|
          sound = load_sound(name.to_s)
          sound.predecode
          [name, sound]
        }.to_h
      end

      def play(id)
        @list[id].play(1, 0)
        # 効果音とBGMの音量が相対関係にあるのか、効果音量が大きすぎると
        # BGMがかなり小さくなってしまう。逆も然り。そのため75としておく。
        @list[id].set_volume(75, 0)
      end
    end
    extend ModuleMethods
  end
  # alias
  SE = SoundEffectManager
end
