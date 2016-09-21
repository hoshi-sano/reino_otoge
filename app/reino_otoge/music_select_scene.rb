module ReinoOtoge
  # 楽曲選択シーン
  class MusicSelectScene < Scene
    use_menu_header
    use_menu_footer
    manager_module MusicSelectManager

    def post_process
      super
      MusicSelectManager.selected_music.stop_preview
    end
  end
end
