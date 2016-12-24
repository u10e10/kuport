# Kuport

キューポートからデータを取ってきてJSONにするライブラリとコマンド    

## Installation

```shell
$ gem install kuport
```

## Usage

###Command

端末でjsonを読むには`jid`がおすすめ。   

``` 
$ go get github.com/simeji/jid/cmd/jid
$ cat sample.json | jid
```

決め打ちで処理するなら`jq`などを使用。  

一度ログインすればキャッシュが効くので、暫くは`--id`とパスワード入力は不要。  


```shell 
# 個人宛メッセージ取得
$ kuport --id jx91234 -m


# 個人宛メッセージ(既読)取得
$ kuport --id jx91234 -m read


# ログインのみ(一度ログインするとCookieがキャッシュされる)
$ kuport --id jx91234


# キューポートからファイルをダウンロード
$ kuport --download URL --output-file FILE


# メッセージの添付ファイルをまとめてダウンロード(jqでjsonパース)
$ json="$(kuport --id jx91234 -m | jq '.[0].links')"
$ kuport --download "$json"


# 動的にダウンロードするファイルを選択
$ kuport --download "$(kuport --id jx91234 -m | jid)"


# 時間割取得
$ kuport -t
```

###Library
```ruby 
require 'kuport' 
kp = Kuport.new 
kp.login('jx91234')

messages = kp.messages
timetable = kp.timetable

m = messages[0]
puts m.title, m.body, m.links
puts m.json
puts messages.to_json

timetable.compact
puts timetable.to_json

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

