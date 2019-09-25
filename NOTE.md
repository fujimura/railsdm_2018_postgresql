# スライドの生成

`watch.js`でMarkdownのファイルをpandocでスライドに変換し、それをpuppeteerでPDFでに変換している。

```
$ yarn install
```

して

```
$ node watch.js
```

を実行しておくと、このディレクトリにあるMarkdownファイルがPDFのスライドに自動的に変換される。

# 実行環境

`psql`、`shp2pgsql`が必要なので、PostgreSQL、PostGISを適宜インストールする

## データベースを立ち上げる

```
$ docker-compose up -d
```

## 拡張を作成

```
./setup.sh
```

# データ投入

## データを入手

### 駅

http://www.ekidata.jp/ から「駅データ」をダウンロードし、CSVファイルを`data`ディレクトリに格納して、

```
$ psql -f insert_stations.sql

```

### 公園データ

http://nlftp.mlit.go.jp/ksj/gml/datalist/KsjTmplt-P13.html and から東京都のデータをダウンロードし、zipファイルを`data`ディレクトリに格納して、

```
$ unar -s ./data/P13-11_13_GML.zip -o ./data
$ shp2pgsql -W CP932 ./data/P13-11_13_GML/P13-11_13.shp p13 | psql
$ psql -f insert_parks.sql
```

# 発表内で実行したSQLの実行

```
$ psql -f window1.sql
$ psql -f window2.sql
$ psql -f trigger.sql
$ psql -f materialized_view.sql
$ psql -f st_distance.sql
$ psql -f park_count_ranking.sql
```

# 地図の作成

QGISをrailsdmデータベースに接続して、`stations.nearby`と`parks.geom`を表示する。`stations.nearby`はラベルを表示する。スタイルは適宜調整する。地図はQuickMapSerivicesのOSM Standardを利用。
