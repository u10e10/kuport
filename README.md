# Kuport

キューポートからデータを取ってきてJSONにするライブラリとコマンド    

## Installation

```bash
$ gem install kuport
```

## Usage

### Command

```bash
# 個人宛メッセージ取得
kuport --id jx91234 -m


# 個人宛メッセージ(既読)取得
kuport --id jx91234 -m read


# ログインのみ(一度ログインするとCookieがキャッシュされる)
kuport --id jx91234


# URLをダウンロードしてNAMEとして保存
kuport --download NAME:URL


# メッセージの添付ファイルをまとめてダウンロード
kuport --id jx91234 -m | kuport --download


# 動的にダウンロードするファイルを選択
kuport --id jx91234 -m | jid | kuport --download


# 時間割取得
kuport -t


# 電子教材から科目指定でダウンロード
kuport --materials | kuport --filter='subject:線形代数' | kuport --download

```

一度ログインすればキャッシュが効くので、しばらくは`--id`とパスワード入力は不要。  

`--download`はJSONから`name`と`path`を持つ辞書を再帰的に探索してダウロードできる。  
`[{name: 'Name', path: 'https://~~'}, ...]`  


端末でjsonを読むには`jid`がおすすめ。  

```bash
$ go get github.com/simeji/jid/cmd/jid
$ cat sample.json | jid
```

プロキシの設定は環境変数`HTTP_PROXY`, `HTTPS_PROXY`,`ALL_PROXY`から読み込む。  
`--proxy`でも設定可能。  



### Library
```ruby
require 'kuport'
kp = Kuport.new
kp.login('jx91234')

messages = kp.messages
timetable = kp.timetable
materials = kp.materials

m = messages[0]
puts m.title, m.body, m.links
puts m.json
puts messages.to_json

timetable.compact
puts timetable.to_json

puts materials.to_json

kp.download(name, url)
kp.download_with_json("[{name: 'File.pdf', path: 'https://example.com/file.pdf'}]")

kp.cookies_clear
```

## Configure file

~/.kuportrc.json

```json
{
  "id": "jx91234"
}
```

## Formats

### message

```
[
  {
    "title": "おしらせ その1",
    "body": "内容",
    "links": [
      {
        "name": "詳細.pdf",
        "path": "https://example.com/file.pdf"
      },
      {
        "name": "画像.png",
        "path": "https://example.com/img/image1.png"
      }
    ]
  },
  {
    "title": "おしらせ その2",
    "body": "内容",
    "links": []
  }
]

```


### timetable

| 要素    | 中身                     |
|---------|--------------------------|
| year    | 時間割の年               |
| dates   | その週の日付けや祝日情報 |
| table   | 月曜から土曜の時間割     |
| special | 集中講義など             |


```
{
  "year": "2022年",
  "dates": [
    {
      "date": "12月19日 月",
      "special": null
    },
    .
    .
    .
    {
      "date": "12月24日 土",
      "special": null
    }
  ],
  "table": {
    "mon": [
      {
        "name": "Math",
        "room": "11-2",
        "period": "QC",
        "status": []
      },
      {
        "name": null,
        "room": null,
        "period": null,
        "status": []
      },
      .
      .
      .
      {
        "name": null,
        "room": null,
        "period": null,
        "status": []
      }
    ],
    "tue"
    . 
    .
    .
    "sat"
  },
  "special": ""
}

```

### materials

| キー       | 値                               |
|------------|----------------------------------|
| subject    | String 科目名                    |
| teacher    | String 教員名                    |
| title      | String 資料タイトル              |
| period     | String 公開期間                  |
| downloaded | Boolean ダウンロード状態         |
| links      | [{name, path}, ...] ファイル一覧 |


```
[
  {
    "subject": "世界一スゴイ講義",
    "teacher": "スゴイ先生",
    "title": "第100回目資料",
    "period": "2117/04/04 〜 2117/08/20",
    "downloaded": true,
    "links": [
      {
        "name": "講義資料.pdf",
        "path": "http://example.com/abc.pdf"
      }
      .
      .
      .
    ]
  },
  .
  .
  .
]
```

### download

| 形式     | 説明                         | 例                                                        |
|----------|------------------------------|-----------------------------------------------------------|
| NAME:URL | URLをNAMEとして保存          | file.pdf:"http://example.com/file.pdf"                    |
| JSON     | pathをnameとして保存(再帰的) | {"name": "abc.pdf", "path": "http://example.com/abc.pdf"} |


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
