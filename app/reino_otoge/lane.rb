module ReinoOtoge
  class Lane
    NOTE_KLASS_TO_ADDITION_METHOD_NAMES = {
      ReinoOtoge::Note => :add_single_note,
      ReinoOtoge::LongNote => :add_long_note,
      ReinoOtoge::LeftFlickNote => :add_flick_note,
      ReinoOtoge::RightFlickNote => :add_flick_note,
    }

    attr_reader :line_number, :hit_effect, :down_effect, :effects, :notes
    attr_accessor :hitbox_group

    def initialize(line_number, music_data)
      @line_number = line_number
      @music_data = music_data
      @speed = @music_data.speed
      @notes = []
      @hit_effect = HitEffect.new(@line_number)
      @down_effect = DownEffect.new(@line_number)
      @effects = [@hit_effect, @down_effect]
    end

    # ノートの数
    def note_count
      @notes.compact.size
    end

    # フレーム数
    def length
      @notes.size
    end

    def fetch_note
      note = @notes.shift
      note
    end

    # 譜面読み込み時に利用するメソッド
    def add_note(klass)
      @prev_flicking = !!@flicking
      name = NOTE_KLASS_TO_ADDITION_METHOD_NAMES[klass]
      method(name).call(klass)
    end

    # 譜面読み込み時に利用するメソッド
    def add_single_note(klass)
      note = klass.new(self, @speed)
      @notes.push(note)
      note
    end

    # 譜面読み込み時に利用するメソッド
    def add_long_note(klass)
      if down?
        add_end_long_note(klass)
      else
        add_start_long_note(klass)
      end
    end

    # 譜面読み込み時に利用するメソッド
    def add_flick_note(klass)
      # フリックノートの連結を実現するために3種のフラグを利用する
      # * flickingフラグ: 最後に追加されたノートがフリック系の場合trueになる
      # * prev_flickingフラグ: 直前に追加されたノートがフリック系の場合trueになる
      #                        最後に追加されたノートが非フリック系だが、その前の
      #                        ノートを他のフリックノートと連結したい場合の目印となる
      # * changed_to_flickingフラグ: 現在処理している行(=フレーム)でフリック系の
      #                              ノートが追加された場合にtrueになる
      #                              処理順の都合でflickingフラグが立ったが、当該
      #                              レーンの直前のノートはこの行のフリックノートと
      #                              連結すべきでない場合に目印になる
      # NOTE: もっとスマートな方法ないかな...
      @flicking = true
      @changed_to_flicking = true
      if down?
        add_end_long_note(klass)
      else
        added = add_single_note(klass)
        prev_note = find_prev_flick_note(added)
        if prev_note
          prev_note.next_note = added
          prev_note.lane.finish_flick!
        end
        added
      end
    end

    # 譜面読み込み時に利用するメソッド
    def add_start_long_note(klass)
      note = add_single_note(klass)
      start_long_note!(note)
      note
    end

    # 譜面読み込み時に利用するメソッド
    def add_end_long_note(klass)
      note = add_single_note(klass)
      @current_long_note.end_note = note
      end_long_note!
      note
    end

    # 譜面読み込み時に利用するメソッド
    def add_nil
      @notes.push(nil)
    end

    # 譜面読み込み時に利用するメソッド
    def find_prev_flick_note(note)
      formers = @music_data.lanes[0...@line_number].select(&:prev_or_now_flicking?)
      latters = @music_data.lanes[(@line_number + 1)..-1].select(&:flicking?)
      case note
      when LeftFlickNote
        flicking_lane = (latters + formers).first
      when RightFlickNote
        flicking_lane = (formers + latters).first
      end
      if flicking_lane
        range = (flicking_lane.line_number > @line_number) ? 0..-1 : 1..-1
        res = flicking_lane.notes.reverse[range].find { |n| !n.nil? }
        res.kind_of?(FlickNote) ? res : nil
      else
        nil
      end
    end

    # 譜面読み込み時に利用するメソッド
    def finish_flick!
      @prev_flicking = false
      @flicking = false
    end

    # 譜面読み込み時に利用するメソッド
    def flicking?
      !!@flicking
    end

    # 譜面読み込み時に利用するメソッド
    def prev_or_now_flicking?
      !!(@prev_flicking || @flicking) && !@changed_to_flicking
    end

    def post_read_proc
      @changed_to_flicking = false
    end

    # 特定のノートを削除する
    # 長押しの始点終点のように、始点がミスになった時点で終点も一緒に消えるような
    # 場合に利用するメソッド
    def remove_note(note)
      note.vanish
      if idx = @notes.index(note)
        @notes[idx] = nil
      end
    end

    def judge!
      # 当たりのあったノートの優先度を考慮した判定
      @hitbox_group.judge!
      # LongNoteの判定
      judge_long_note_fail!
    end

    # LongNoteの失敗判定と長押し終了処理を行う
    #
    # 長押し開始後(@current_long_noteがnilでない場合)で、
    # かつ現在長押しをしていない状態(@downがnil)の場合、
    # 以下の処理を実施する
    # 1. LongNoteの終点が当たり判定されていない(visibleである)なら失敗とみなす
    # 2. LongNoteの始点と終点を無効化する(画面からの削除対象とする)
    def judge_long_note_fail!
      return if @down
      if @current_long_note
        end_note = @current_long_note.end_note
        LiveManager.miss! if end_note && end_note.visible
        @current_long_note.vanish
        end_note.vanish
      end
      end_long_note!
    end

    # 長押しの開始
    def start_long_note!(long_note)
      @down = true
      @current_long_note = long_note
      @down_effect.show!
    end

    # 長押しの終了
    def finish_long_down!
      @down = false
    end

    def end_long_note!
      @down = false
      @current_long_note = nil
      @down_effect.hide!
    end

    # 長押し中か否か
    def down?
      !!@down
    end
  end
end
