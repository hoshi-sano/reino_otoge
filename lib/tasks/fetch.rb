namespace :fetch do
  MD_BASE_URL = 'http://maoudamashii.jokersounds.com'
  MD_PREVIEW_BASE_URL = File.join(MD_BASE_URL, 'music/song/preview')
  MD_SONG_BASE_URL    = File.join(MD_BASE_URL, 'music/song/mp3')
  MD_GAME_BASE_URL    = File.join(MD_BASE_URL, 'music/game/mp3')
  MD_ALBUMART_ZIP_URL = File.join(MD_BASE_URL, 'images/albumart/albumart.zip')
  SONG_LIST = [
    {
      dirname:  '000_kirakira',
      preview:  'song_minami_kirakira.mp3',
      mp3:      'short_song_minami_kirakira.mp3',
      albumart: 'song_03.png',
    },
    {
      dirname:  '001_distance',
      preview:  'song_izumi_distance.mp3',
      mp3:      'short_song_izumi_distance.mp3',
      albumart: 'song_05.png',
    },
    {
      dirname:  '002_sakurabiyori',
      preview:  'song_yuuri_sakurabiyori.mp3',
      mp3:      'short_song_yuuri_sakurabiyori.mp3',
      albumart: 'song_07.png',
    },
  ]
  BGM_LIST = {
    home:        'game_maoudamashii_5_town22.mp3',
    live_result: 'game_maoudamashii_4_vehicle02.mp3',
  }


  # 楽曲の試聴用MP3ファイルを取得し指定したディレクトリに配置する
  def fetch_md_preview(file_name, dist_dir)
    dist = File.join(dist_dir, 'preview.mp3')
    return if File.exists?(dist)
    url = File.join(MD_PREVIEW_BASE_URL, file_name)
    fetch_binary_file(url, dist)
  end

  # 楽曲のプレイ用MP3ファイルを取得し指定したディレクトリに配置する
  def fetch_md_song_mp3(file_name, dist_dir)
    dist = File.join(dist_dir, 'bgm.mp3')
    return if File.exists?(dist)
    url = File.join(MD_SONG_BASE_URL, file_name)
    fetch_binary_file(url, dist)
  end

  # 各シーンのBGM用ファイルを取得し指定したディレクトリに配置する
  def fetch_md_bgm(md_file_name, dist)
    return if File.exists?(dist)
    url = File.join(MD_GAME_BASE_URL, md_file_name)
    fetch_binary_file(url, dist)
  end

  def fetch_binary_file(url, dist)
    open(url) do |file|
      open(dist, 'wb') do |out|
        out.write(file.read)
        puts "got #{url}, and wrote #{dist}"
      end
    end
  end

  # 楽曲のアルバムイメージを取得し、それぞれのディレクトリに配置する
  # 取得先の負荷を減らすため、ZIPファイルへのアクセスは1回のみにしている
  def fetch_md_artwork(data_dir)
    list = SONG_LIST.map { |h|
      {
        entry_name: "albumart/#{h[:albumart]}",
        dist_file:  File.join(data_dir, h[:dirname], 'artwork.png')
      }
    }
    open(MD_ALBUMART_ZIP_URL) do |zf|
      Zip::File.open(zf.path) do |zipfile|
        list.each do |h|
          next if File.exists?(h[:dist_file])
          entry = zipfile.find_entry(h[:entry_name])
          entry.extract(h[:dist_file])
          puts "got #{entry.to_s}, and wrote #{h[:dist_file]}"
        end
      end
    end
  end

  desc '魔王魂さまよりプレイ楽曲等に必要なファイルを取得する'
  task :md do
    require 'zip'
    require 'open-uri'
    music_data_dir = File.join(ROOT, 'data', 'music')
    SONG_LIST.each do |h|
      dist_dir = File.join(music_data_dir, h[:dirname])
      fetch_md_preview(h[:preview], dist_dir)
      fetch_md_song_mp3(h[:mp3], dist_dir)
    end
    fetch_md_artwork(music_data_dir)
    sound_data_dir = File.join(ROOT, 'data', 'sound')
    BGM_LIST.each do |dist_file_name, md_file_name|
      ext = File.extname(md_file_name)
      dist = File.join(sound_data_dir, "#{dist_file_name}#{ext}")
      fetch_md_bgm(md_file_name, dist)
    end
  end
end
