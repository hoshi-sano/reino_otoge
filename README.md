# reino-otoge

## 概要

TODO

## 開発環境の用意

[DXRuby](http://dxruby.osdn.jp/)を利用しているため、Windows環境のみが対象となります。
32bit版のRuby 2.3.0以上が利用可能な環境で以下を実行してください。

```
  $ gem install bundler
  $ git clone https://github.com/hoshi-sano/reino_otoge.git
  $ cd reino_otoge
  $ bundle install
```

https://github.com/mirichi/dxruby-doc/wiki よりAyame/Rubyを入手し、以下のコマンド等を利用してAyame.dllとayame.soをそれぞれ適切な位置に配置してください。(`/path/to/`の箇所は取得・展開したファイルが実際に置かれているパスに適宜変更してください。)

```
  $ cd reino_otoge
  $ cp /path/to/Ayame.dll .
  $ rake dev:put_ayame_so[/path/to/ayame.so] # 引数で指定したファイルをdxruby.soと同じディレクトリに配置します
```

以下を実行し、問題なくゲームが開始されれば準備完了です。

```
  $ cd reino_otoge
  $ ruby main.rb
```

## パッケージング

### 参考情報

* [Ruby製ゲームをパッケージングするあたらしい方法](http://blog.aotak.me/post/135851139476/ruby%E8%A3%BD%E3%82%B2%E3%83%BC%E3%83%A0%E3%82%92%E3%83%91%E3%83%83%E3%82%B1%E3%83%BC%E3%82%B8%E3%83%B3%E3%82%B0%E3%81%99%E3%82%8B%E3%81%82%E3%81%9F%E3%82%89%E3%81%97%E3%81%84%E6%96%B9%E6%B3%95)
* [Ruby 2.2 と 2.3 でスクリプトを Ocra を使わずにスタンダロンアプリケーション化する](http://blog.aotak.me/post/144865493601/ruby-22-%E3%81%A8-23-%E3%81%A7%E3%82%B9%E3%82%AF%E3%83%AA%E3%83%97%E3%83%88%E3%82%92-ocra-%E3%82%92%E4%BD%BF%E3%82%8F%E3%81%9A%E3%81%AB%E3%82%B9%E3%82%BF%E3%83%B3%E3%83%80%E3%83%AD%E3%83%B3%E3%82%A2%E3%83%97%E3%83%AA%E3%82%B1%E3%83%BC%E3%82%B7%E3%83%A7%E3%83%B3%E5%8C%96%E3%81%99%E3%82%8B)

### 手順

上記を参考にstandaloneruby230をビルドもしくは入手し、binにPATHを通した上で以下を実行します。

```
  $ cd reino-otoge
  $ rpk main.rb
```
