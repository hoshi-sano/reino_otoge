# デモ用に各種挙動を変更するためのパッチ
# ノートの当たり判定用オブジェクトをPERFECT判定になるもののみにし、
# かつキー入力を問わず常に判定を有効にしておくことで全てのノートに
# おいてPERFECTとなるようにする
module ReinoOtoge
  class HitboxGroup
    def initialize(lane, speed)
      @lane = lane
      @lane.hitbox_group = self
      @hit_effect = @lane.hit_effect
      @hitboxes = [ Perfect.new(self, 0, speed) ]
      @hit_map = HIT_MAP.dup
    end
  end

  class FlickNote
    # 打鍵後の後処理
    # デモモードの場合はキーを離した際のLane#finish_long_down!
    # が呼ばれず、長押しの最後がフリックの場合に長押しエフェクトが
    # 継続してしまうため後処理で常にLane#finish_long_down!を呼ぶ
    def post_proc(lane)
      super
      self.visible = false
      @lane.finish_long_down!
    end
  end

  module LiveManager
    module ModuleMethods
      def check_keys_in_live
        @keys.values.each do |hitbox_group|
          hitbox_group.enable!
          hitbox_group.draw if ReinoOtoge.debug?
        end
        Sprite.check(@keys.values.map(&:to_a), @notes, :shot, :hit)
        @lanes.map(&:judge!)
      end
    end
  end
end
