# Kuport

キューポートからデータを取ってきてJSONにするライブラリとコマンド    

## Installation

```bash
$ gem install kuport
```

## Usage

### Command

端末でjsonを読むには`jid`がおすすめ。   

```bash 
$ go get github.com/simeji/jid/cmd/jid
$ cat sample.json | jid
```

決め打ちで処理するなら`jq`などを使用。  

一度ログインすればキャッシュが効くので、暫くは`--id`とパスワード入力は不要。  

`--download`で複数のファイルを一括で落とすにはjqなどで上手くフィルタして`name`と`path`を含むディクショナリのリストを取り出す必要がある。  
`[{name: 'Name', path: 'https://~~'}, ...]`  

```bash 
# 個人宛メッセージ取得
kuport --id jx91234 -m


# 個人宛メッセージ(既読)取得
kuport --id jx91234 -m read


# ログインのみ(一度ログインするとCookieがキャッシュされる)
kuport --id jx91234


# キューポートからファイルを1つダウンロード
kuport --download URL --output-file FILE


# メッセージの添付ファイルをまとめてダウンロード(jqでjsonパース)
kuport --id jx91234 -m | jq '.[0].links' | kuport --download


# 動的にダウンロードするファイルを選択
kuport --id jx91234 -m | jid | kuport --download


# 時間割取得
kuport -t


# 電子教材の特定の科目をダウンロード
kuport --materials | jq 'map(select( .["subject"] | test("^線形代数") ).links | .[])' | kuport --download

```

###Library
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

kp.download(url, name)
kp.download([{name: 'File.pdf', path: 'https://example.com/file.pdf'}, ])

kp.cookies_clear
```

##Formats

###message

```json 
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
        "path": "https://example.com/img/image1.pdf"
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


###timetable 

| 要素    | 中身                     |
|---------|--------------------------|
| year    | 時間割の年               |
| dates   | その週の日付けや祝日情報 |
| table   | 月曜から土曜の時間割     |
| special | 集中講義など             |


```json 
{
  "year": "2022年",
  "dates": [
    {
      "date": "12月19日 月",
      "special": null
    },
    {
      "date": "12月20日 火",
      "special": null
    },
    {
      "date": "12月21日 水",
      "special": null
    },
    {
      "date": "12月22日 木",
      "special": null
    },
    {
      "date": "12月23日 金",
      "special": "天皇誕生日"
    },
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
      {
        "name": "English",
        "room": "13-8",
        "period": "Q2",
        "status": []
      },
      {
        "name": null,
        "room": null,
        "period": null,
        "status": []
      },
      {
        "name": "IT",
        "room": "QA",
        "period": null,
        "status": []
      },
      {
        "name": null,
        "room": null,
        "period": null,
        "status": []
      },
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

###download 
### materials

```
[
  {
    "subject": "世界一スゴイ講義",
    "teacher": "スゴイ先生",
    "title": "第100回目資料",
    "period": "2117/04/04 〜 2117/08/20",
    "state": "未ダウンロード",
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

| 形式       | 説明          | 例                                                               |
|------------|---------------|------------------------------------------------------------------|
| URL        | ファイルのURL | "http://example.com/file.pdf"                                    |
| JSON       | 単一の要素    | {"name": "file.pdf", "path": "http://example.com/abc.pdf"}       |
| JSON(配列) | 複数の要素    | [{"name": "img.png", "path": "http://example.com/efg.png"}, ...] |  


## Contributing

バグがあったらお気軽にどうぞ。  
コントリビューター募集中。  


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

