module ReinoOtoge
  # ホーム画面を表現するシーン
  class HomeScene < Scene
    use_menu_header
    use_menu_footer
    manager_module HomeManager

    def play
      super
      if Input.key_push?(K_RETURN)
        go_to_next_scene
      end
    end

    def go_to_next_scene
      next_scene = MusicSelectScene.new
      ReinoOtoge.change_scene(next_scene)
    end
  end
end
