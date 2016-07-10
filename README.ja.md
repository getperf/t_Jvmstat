Java VM 統計(Jvmstat)モニタリングテンプレート
======================================

Jvmstat モニタリング
-----------------

ローカルサーバ上の JavaVM インスタンスのヒープ使用率、GC統計情報を採取します。

**注意事項**

1. Java 1.5 以上をサポートします
2. Java仮想マシン(JVM)の統計情報採取コマンド [jstat](https://docs.oracle.com/javase/jp/6/technotes/tools/share/jstat.html) と類似のコマンドで情報採取をします

ファイル構成
-------

テンプレートに必要な設定ファイルは以下の通りです。

|            ディレクトリ           |        ファイル名        |                  用途                 |
|-----------------------------------|--------------------------|---------------------------------------|
| lib/agent/Jvmstat/conf/           | iniファイル              | エージェント採取設定ファイル          |
| lib/agent/Jvmstat/script/         | jstatmモジュール         | エージェント採取スクリプト            |
| lib/Getperf/Command/Site/Jvmstat/ | pmファイル               | データ集計スクリプト                  |
| lib/graph/Jvmstat/                | jsonファイル             | グラフテンプレート登録ルール          |
| lib/cacti/template/0.8.8g/        | xmlファイル              | Cactiテンプレートエクスポートファイル |
| script/                           | create_graph_template.sh | グラフテンプレート登録スクリプト      |

メトリック
-----------

パフォーマンス統計グラフなどの監視項目定義は以下の通りです。

|          Key           |              Description              |
|------------------------|---------------------------------------|
| **パフォーマンス統計** | **JavaVM ヒープ使用率、GC統計グラフ** |
| jstat                  | **ヒープ使用量**<br> Heap usage       |
|                        | **GC統計**<br> GC 回数 / GC ビジー率  |

Install
=====

Jvmstat テンプレートのビルド
-------------------

Git Hub からプロジェクトをクローンします

	(git clone してプロジェクト複製)

プロジェクトディレクトリに移動して、--template オプション付きでサイトの初期化をします

	cd t_Jvmstat
	initsite --template .

Cacti グラフテンプレート作成スクリプトを順に実行します

	./script/create_graph_template__Jvmstat.sh

Cacti グラフテンプレートをファイルにエクスポートします

	cacti-cli --export Jvmstat

集計スクリプト、グラフ登録ルール、Cactiグラフテンプレートエクスポートファイル一式をアーカイブします

	sumup --export=Jvmstat --archive=$GETPERF_HOME/var/template/archive/config-Jvmstat.tar.gz

Jvmstat テンプレートのインポート
---------------------

前述で作成した $GETPERF_HOME/var/template/archive/config-Jvmstat.tar.gz がJvmstatテンプレートのアーカイブとなり、
監視サイト上で以下のコマンドを用いてインポートします

	cd {モニタリングサイトホーム}
	tar xvf $GETPERF_HOME/var/template/archive/config-Jvmstat.tar.gz

Cacti グラフテンプレートをインポートします。

	cacti-cli --import Jvmstat

インポートした集計スクリプトを反映するため、集計デーモンを再起動します

	sumup restart

jstatmコンパイル
--------------------

jvmstat API を用いた、Java アプリを使用します。Java 実行環境に応じて、Javaアプリをコンパイルしてください。
コンパイルの詳細は、以下 README を参照してください。

	lib/agent/Jvmstat/src/jstat/README.md

使用方法
=====

エージェントセットアップ
--------------------

以下のエージェント採取設定ファイルを監視対象サーバにコピーして、エージェントを再起動してください。

	cd {サイトホーム}/lib/agent/Jvmstat/
	scp -rp * {監視対象サーバユーザ}@{監視対象サーバ}@~/ptune/

採取スクリプトjstatm.sh 内の JAVA_HOME 環境変数の設定を編集します。実行環境に合わせてパスをしてください。

* Linux の場合

script/jstatm.sh　スクリプト内の以下の行を編集します。

```
grep JAVA_HOME= ~/ptune/script/jstatm.sh
JAVA_HOME=/usr/lib/jvm/java; export JAVA_HOME
```

* Windows の場合

script/jstatm.bat　スクリプト内の以下の行を編集します。

```
grep JAVA_HOME= ~/ptune/script/jstatm.bat
set JAVA_HOME=C:\jdk1.7.0_79
```

設定を反映するためエージェントを再起動します。

	~/ptune/bin/getperfctl stop
	~/ptune/bin/getperfctl start

データ集計のカスタマイズ
--------------------

上記エージェントセットアップ後、データ集計が実行されると、サイトホームディレクトリの lib/Getperf/Command/Master/ の下に Jvmstat.pm ファイルが生成されます。
本ファイルは監視対象のJava VM インスタンスのマスター定義ファイルで、Java VMインスタンス の用途を記述します。
同ディレクトリ下の Jvmstat.pm_sample を例にカスタマイズしてください。

グラフ登録
-----------------

上記エージェントセットアップ後、データ集計が実行されると、サイトホームディレクトリの node の下にノード定義ファイルが出力されます。
出力されたファイル若しくはディレクトリを指定してcacti-cli を実行します。

	cacti-cli node/Jvmstat/{Java VM インスタンス}/

AUTHOR
-----------

Minoru Furusawa <minoru.furusawa@toshiba.co.jp>

COPYRIGHT
-----------

Copyright 2014-2016, Minoru Furusawa, Toshiba corporation.

LICENSE
-----------

This program is released under [GNU General Public License, version 2](http://www.gnu.org/licenses/gpl-2.0.html).
