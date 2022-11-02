# MAGIA

![magia](./ logo.png)

Magiaは究極のカスタマイズ性と処理速度を誇るプロのためのNFTジェネレーター。



## インストール



Makefile

```shell
make install
```



Mint🌱

```shell
mint install GeneralD/Magia
```





## 機能



主にNFTの生成に関して次の機能を提供する。

- 無数のレイヤーを合成する
  - 各レイヤーはアニメーションさせることができる
  - 各レイヤーのパーツごとの抽選の当選率を設定する
  - 各レイヤー内のパーツの抽選順序とレイヤーの重ね順を個別に指定できる
  - パーツ同士の組み合わせの可否をレイヤーを跨いでルールづけできる
- GIFもしくはPNG画像ファイルを出力する
  - テスト目的のウォータードロップ付きの画像を出力できる
  - トークンID（連番）を任意のフォントで印字できる
- OpenSeaのMetadata Standardに沿ったメタデータファイルを出力できる
  - 使用されたパーツごとにTraitを持たせられる
  - Traitの順序を指定できる（マーケットプレース内での表示に反映されるとは限らない）
- その他
  - ERC721AなどでどうしてもURIが連番になりがちなときの先読み防止策の提供
  - 読み込むアセットフォルダー内の重複する不要なファイルを掃除する



## アセットの準備



### スタート

入力する素材画像群を準備しよう。

まずはフォルダを1つ作る。（以後これをアセットフォルダと呼ぶ）

その中にフォルダを必要なレイヤーの数だけ作る。（以後、これらをレイヤーフォルダと呼ぶ）

例えば、頭、体、脚を組み合わせて作るNFTならレイヤーは4つではないだろうか。おそらく背景も必要だから。

実際は帽子を被っていたり、アイテムを持っていたりするから現実的には10個くらいになると思う。

各フォルダーには分かりやすい名前を付けておこう。



### 中身の準備

#### 静止画像を作る場合 (GIF / PNG)

各レイヤーフォルダ内にパーツを配置しよう。

たとえば、`head`というレイヤーフォルダに頭のパーツをたくさん入れておく。

この時、画像は背景透過を使うことになることが殆どなのでPNG形式などで準備しておく。背景画像など透過部分がない場合はこの限りではない。

同様に`body`や`item`など他のレイヤーフォルダの中にも画像を入れていこう。



#### 動く画像を作る場合（Animated GIF / Animated PNG）

各レイヤーフォルダ内に更にフォルダを配置しよう。これはレイヤーごとの必要なパーツの数だけ作っていくことになる。

たとえば、`item`というレイヤーフォルダに`energy_drink`や`cigarettes`のようなフォルダを作る。（以後、それらをパーツフォルダと呼ぶ）

そして各パーツフォルダに画像を入れていく。

ここで複数枚の画像を入れた場合、そのレイヤーはそれらの画像をフレームとするアニメーションレイヤーとなる。（以後、それらをフレーム画像と呼ぶ）

しかし、すべてのレイヤーに均等な枚数の画像を入れる必要はない。アニメーションしなくて良いレイヤーはパーツフォルダの中に一枚だけ入れておけば良い。

仕組みを説明すると、最終的に各レイヤーフォルダから1つずつ抽選で選ばれたパーツフォルダの中から、最も画像の枚数が多いものが、出力される画像のフレーム数となる。

なので、フレーム数が24となる場合、フレーム画像が1枚しかないパーツはその1枚を24フレーム繰り返すので静止部分となる。



## 画像生成実行



基本的な使い方

```shell
magia summon [アセットフォルダ] -o [出力先]
```



オプション

- `--name-format` ファイル名のフォーマットを指定できる
  - デフォルトは `%d` で番号がそのまま使用される
  - 拡張子は含めない





## 設定ファイルの書き方



ジェネラティブNFTの生成に於いて、大抵の場合全てのパーツを網羅的かつ完全なランダムに組み合わせるということはないはず。

出現率の偏りや組み合わせの制限など、いくつも制約を設けたくなるだろう。

まずは、 `config.yml` をアセットフォルダ内に配置しよう。

もしくは `config.json` でも良い。JSONフォーマットもサポートしているが、YAMLの方が短く簡潔に書けるので推奨。以下、YAMLで説明を進める。



## シリアルナンバーを印字する



トークンIDに基づいた連番を画像に印字したい場合があるはず。

その場合は以下のような設定を追記する。

```yaml
drawSerial:
  enabled: true
  color: "000000"
  font: M+ 1p black
  format: "#%05d"
  offsetX: 40
  offsetY: 14.5
  size: 38
```

- `drawSerial` に定義する。
  - `enabled` は `true` で良い。
    - デフォルトは `true`。
    - 一時的に印字をさせたくない場合は `false` にすれば切り替えられる。
  - `color` はHTMLカラーコードで指定できる。ただし `#` は無くても可。
    - デフォルトは `000000`。
  - `font` はmacOSのシステムに認識されているフォント（Libray/Fonts以下配置）なら全て指定することができる。
    - アセットフォルダ直下に置かれたフォントも指定することができる。
  - `format` はシリアルナンバー（整数値）を印字する際のフォーマットを指定する。
    - 例えば`#%05d` なら `123` は `#00123` となる。
    - デフォルトは`%03d`。
  - `offsetX` は画像左からの印字位置までの距離。
    - デフォルトは`0`。
  - `offsetY` は画像下からの印字位置までの距離。
    - デフォルトは`0`。
  - `size` はフォントのサイズ。
    - デフォルトは`14`。



## 各パーツの当選確率（レア度）の調整



各レイヤーのパーツごとの当選確率を設定する。ただし確率は重み（`weight`）の比重によって行う。全パーツの重みの初期値は`1`。正規表現で指定した名前に適合するパーツに対しては重みが掛け合わされていく。



`divideByMatches` によって`weight` をマッチした数で割ることもできる。

例えば、赤いニット帽、青いニット帽、黄色のニット帽、黒いヘルメット、白いヘルメットの中から1つを抽選する場合を考える。

ニット帽が出る確率を70%、ヘルメットが出る確率を30%としたいとする。

`weight` は重み、つまり比率を表すのでニット帽は0.7、ヘルメットは0.3と設定すれば良い。（7と3でも構わない）

しかしこうすると各ニット帽が0.7なので、いずれかのニット帽が出る比率は2.1。同様に計算するとヘルメットは0.6となる。この時、ニット帽が出る確率は 2.1 / (2.1 + 0.6) = 0.7777... となるので、およそ78%となってしまう。

そこで、`divideByMatches` を`true` にするとこの問題を簡単に解決できる。

`true` のとき、正規表現でニット帽にマッチするものが3つ場合、`weight` の値は3で割られる。ヘルメットなら2で割る。

こうすると、ニットの重みの合計は0.7となる。ヘルメットの合計は0.3。したがって、いずれかのニット帽が出る確率は 0.7 / (0.7 + 0.3) = 0.7 (70%) となる。

余談だが、この時の赤いニット帽が出る確率は0.7 / 3 = 0.2333... で黒いヘルメットが出る確率は 0.3 / 2 = 0.15 となるが、`divideByMatches` を `true` にすることでこのような煩雑な計算を意識しなくても良いことになる。



```yaml
randomization:
  probabilities:
  - target:
      layer: cap
      name: "^.*_knit$"
    weight: 0.7
    divideByMatches: true
  - target:
      layer: cap
      name: "^.*_hardhat$"
    weight: 0.3
    divideByMatches: true
```

- `randomization` に定義する。
  - `probabilities` はパーツの当選確率についての定義を配列に列挙する。
    - `target` は当選確率を設定する対象。
      - `layer` はパーツが属するレイヤーフォルダ。
      - `name` は対象をマッチさせる正規表現。

    - `weight` は重み。
      - デフォルトは`1`

    - `divideByMatches` は`weight` をマッチした数で割ったものを用いるかどうか。
      - デフォルトは`false`




## パーツの組み合わせの制約



あらゆる組み合わせが存在するからこそジェネラティブは面白くなるものだが、中には厳格な組み合わせの制限を設けたいこともあるだろう。

あくまで例えばの話だが、鷹に耳やツノを付けたくない場合もある。

ヘルメットを突き破ってツノが生えるのが嫌な場合もあるだろう。



動物のNFTを作っているケースを考えよう。

胴体の抽選でキリンの胴体が出たとする。その後、服や帽子、目の抽選が行われるとする。

まず服に関して、首が長いキリンはパーカーのフードを被るデザインには的確では無い。この場合は正規表現の否定を用いるなどして対象を除外する。

また、このキリンというキャラクターは少しおちゃめで、顔が画像に収まっていないという趣向のものだとした場合、目や帽子は描画する必要がないので（そもそも他の動物と共用パーツだと描画位置がおかしくなる）`name` を空欄にすることで、そのパーツの抽選をスキップさせることが出来る。



ちなみに前述の「当選確率」との兼ね合いは、組み合わせの制約によって抽選対象に残ったものだけで `weight` を用いた計算が行われる。

```yaml
combinations:
- target:
    layer: body
    name: "^(?=.*_giraffe_).*$"
  dependencies:
  - layer: cloth
    name: "[^hoody]"
  - layer: eye
    name:
  - layer: cap
    name:
```

- `combinations` に定義する。
  - `target` はルールを設定する対象。
    - `layer` は対象のレイヤー。
    - `name` はパーツをマッチさせる正規表現。
  - `dependencies` は組み合わせの制限を定義する。
    - `layer` は制限する対象のレイヤー。
    - `name` は抽選対象に残したいパーツ全てをマッチさせる正規表現。
      - よくある使い方は以下。
        - その対象が対応しないパーツのみを否定する正規表現。
        - その対象は他と対応できる組み合わせが排他的に異なるので、専用に用意された対象を網羅する正規表現。



## レイヤーの重ね順と抽選順

この設定がなければレイヤーの重ね順と抽選順はレイヤーフォルダ名で辞書順となる。

設定なしでレイヤーフォルダ名だけで解決する場合は先頭に番号を付けると明瞭だ。

それでもやはり色々なバリエーションの画像を作ろうと試していると入れ替えは頻繁に発生するので設定を書いてしまおう。

パーツの組み合わせの依存関係の兼ね合いで抽選順の設定が必要なこともある。

例えば、`03_hand` のパーツが `04_item` のパーツに制約を与える場合、`03_hand` が先に抽選される必要がある。

もちろんレイヤーの重ね順と抽選順が同じになるとは限らないので、設定は分けられている。

```yaml
order:
  layerDepth:
  - background
  - body
  - hand
  - handheld
  - hair
  - facegear
  - headgear
  - eye
  - cloth
  - ear
  selection:
  - background
  - body
  - hand
  - handheld
  - cloth
  - hair
  - facegear
  - headgear
  - eye
  - ear
```

- `order` に定義する。
  - `layerDepth`はレイヤーの重ね順を配列に列挙する。

  - `selection`は抽選順を配列に列挙する。




## Metadata Generation

```yaml
metadata:
  backgroundColor: f7cc1b
  defaultDescriptionFormat: "First collections of ANIM.JP. Serial number is %05d."
  defaultNameFormat: ANIM.JP#%05d
  externalUrlFormat: https://anim.jp
  baseUrl: https://nft.com
  traitOrder:
  - Family
  - Fortune
  - Intelligence
  - Talent
  data:
  - conditions:
    - layer: 02_body
      name: "^(?=.*_cat_).*$"
    traits:
    - type: label
      trait: Family
      value: Cat
    - type: rankedNumber
      trait: Fortune
      value: 42
    - type: rankedNumber
      trait: Intelligence
      value: 39
    - type: rankedNumber
      trait: Talent
      value: 37
```

