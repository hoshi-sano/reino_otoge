module ReinoOtoge
  require 'yaml'

  # 共通
  require 'reino_otoge/constants'
  require 'reino_otoge/config'
  require 'reino_otoge/helper_methods'
  require 'reino_otoge/player_data'
  require 'reino_otoge/scene'
  require 'reino_otoge/idol'
  require 'reino_otoge/unit'
  require 'reino_otoge/partial_view'
  require 'reino_otoge/sound_effect_manager'
  require 'reino_otoge/bgm_manager'

  # 楽曲データ関連
  require 'reino_otoge/note'
  require 'reino_otoge/long_note'
  require 'reino_otoge/flick_note'
  require 'reino_otoge/lane'
  require 'reino_otoge/music_data'

  # ライブ関連
  require 'reino_otoge/hitbox'
  require 'reino_otoge/rating'
  require 'reino_otoge/combo_counter'
  require 'reino_otoge/hit_effect'
  require 'reino_otoge/down_effect'
  require 'reino_otoge/live_ui'
  require 'reino_otoge/live_start_effect'
  require 'reino_otoge/live_finish_effect'
  require 'reino_otoge/full_combo_effect'
  require 'reino_otoge/live_manager'
  require 'reino_otoge/live_scene'

  # 曲選択画面関連
  require 'reino_otoge/live_header_menu_bar'
  require 'reino_otoge/music_data_window'
  require 'reino_otoge/unit_select_window'
  require 'reino_otoge/live_setting_window'
  require 'reino_otoge/music_select_manager'
  require 'reino_otoge/music_select_scene'

  # リザルト画面関連
  require 'reino_otoge/live_success_effect'
  require 'reino_otoge/live_grade_display'
  require 'reino_otoge/live_result_scene'

  # ホーム画面関連
  require 'reino_otoge/home_idol_message_window'
  require 'reino_otoge/home_icon_button'
  require 'reino_otoge/event_notifier'
  require 'reino_otoge/home_manager'
  require 'reino_otoge/home_scene'

  # 共通
  require 'reino_otoge/header_menu_bar'
  require 'reino_otoge/footer_menu_bar'

  if Object.const_defined?(:REINO_OTOGE_EDIT) && ::REINO_OTOGE_EDIT
    require 'reino_otoge/edit_patch'
    require 'reino_otoge/edit_scene'
  end

  MOUSE_POINTER = Sprite.new(0, 0, Image.new(1, 1, [0, 0, 0, 0]))
                  .tap { |mp| mp.collision_enable = false }

  module ModuleMethods
    def init
      Window.height = WINDOW_HEIGHT
      Window.width = WINDOW_WIDTH
      Window.frameskip = true
      PlayerData.init
      SoundEffectManager.init
      BGMManager.init
      @current_scene = HomeScene.new
      @footer_menu_bar = FooterMenuBar.new
      @header_menu_bar = HeaderMenuBar.new
      @play_method = method(:scene_play)
      @current_scene.pre_process
    end

    def current_scene
      @current_scene
    end

    def update_footer_menu_bar
      @footer_menu_bar.update
    end

    def draw_footer_menu_bar
      @footer_menu_bar.draw
    end

    def draw_header_menu_bar
      @header_menu_bar.draw
    end

    def check_footer_click
      @footer_menu_bar.check_click
    end

    def play
      @play_method.call
    end

    def scene_play
      Ayame.update
      @current_scene.play
      if Input.mouse_push?(M_LBUTTON)
        MOUSE_POINTER.collision_enable = true
        MOUSE_POINTER.x = Input.mouse_x
        MOUSE_POINTER.y = Input.mouse_y
      else
        MOUSE_POINTER.collision_enable = false
      end
    end

    # シーン切り替え中に複数回繰り返し呼ばれるメソッド
    # 切り替えが完了するとscene_playが呼ばれるようになる
    # @note 名前がわかりにくい
    def scene_change
      finish = @prev_scene.fade_out
      if finish
        @play_method = method(:scene_play)
        @current_scene.pre_process
      end
    end

    # シーン切替時に1度だけコールするメソッド
    def change_scene(scene)
      return if scene.class == @current_scene.class
      @current_scene.post_process
      @prev_scene = @current_scene
      @current_scene = scene
      @play_method = method(:scene_change)
      button_id =
        {
          HomeScene        => :home,
          MusicSelectScene => :live,
        }[@current_scene.class]
      @footer_menu_bar.select(button_id) if button_id
    end

    # デモ用のモードを有効にする
    def demo_mode!
      require 'reino_otoge/demo_patch'
    end

    # デバッグモードを有効にする
    def debug_mode!
      @debug = true
    end

    def debug?
      !!@debug
    end
  end
  extend ModuleMethods
end
