# dxruby.soファイルが配置されているディレクトリを返す
def dxruby_so_dir
  $LOAD_PATH.each do |path|
    dxruby_so_path = File.join(path, 'dxruby.so')
    return path if File.exists?(dxruby_so_path)
  end
  raise 'cannot find dxruby.so'
end

def next_music_index
  music_dir = File.join(ROOT, 'data', 'music')
  pattern = File.join(music_dir, "[0-9][0-9][0-9]_*")
  max_idx =
    Dir.glob(pattern).map { |path|
      path.split(File::Separator).last.match(/[0-9]{3}/)[0].to_i
    }.max
  max_idx ? (max_idx + 1) : 0
end

namespace :dev do
  desc 'ayame.soファイルをdxruby.soファイルと同じディレクトリに配置する'
  task :put_ayame_so, :ayame_so_path do |task, args|
    dir = dxruby_so_dir
    if File.exist?(File.join(dir, 'ayame.so'))
      puts "already exists: #{File.join(dir, 'ayame.so')}"
    else
      puts "copy #{args[:ayame_so_path]} to #{dir}"
      FileUtils.copy(args[:ayame_so_path], dir)
    end
  end

  desc '新規プレイ楽曲を生成する'
  task :gen_music, :dir_name do |task, args|
    idx = next_music_index
    raise 'too big music directory index' if idx > 999
    new_dir_name = ["%03d" % idx, '_', args[:dir_name] || 'new'].join
    new_dir_path = File.join(ROOT, 'data', 'music', new_dir_name)
    music_template = File.join(ROOT, 'templates', 'music')
    FileUtils.cp_r(music_template, new_dir_path)
    puts "generate #{new_dir_path}"
  end
end
