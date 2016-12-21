class Kuport::Timetable
  attr_reader :year, :dates, :table, :special

  def initialize(doc)
    period_line = doc.at_css('.portlet_module > .ac > table').css('tr')
    parse_dates(period_line.shift)
    parse_special(period_line.pop)
    parse_table(period_line)
  end

  # 集中講義(1週間共通)
  def parse_special(special_doc)
    @special = special_doc.css('td')[1].text
    @special = '' if @special == '-'
  end

  def parse_dates(dates_doc)
    Kuport.br_to_return(dates_doc)
    tds = dates_doc.css('td')
    @year = tds.shift.text

    @dates = tds.map do |td|
      # 月日曜, 祝
      date,special = td.text.sub("\n", ' ').split("\n")
      {date: date, special: special}
    end
  end

  def parse_table(period_line)
    @table = {mon: [], tue: [], wed: [], thurs: [], fri: [], sat: []}

    period_line.each do |tr|
      tds = tr.css('td')
      tds.shift # 横枠破棄(1~7時限 集中講義等)

      tds.zip(@table).each do |(td, day)| # 各曜日のn限
        Kuport.br_to_return(td)
        name,room,period = parse_class_text(td.text)

        # 休講とか (kyuko)
        status = td.css('img').map{|img| Kuport.basename_noext(img['src'])}
        day[1] << {name: name, room: room, period: period, status: status}
      end
    end
  end

  def parse_class_text(text)
    text.strip!
    text = '' if text == '-'
    text = Kuport.to_half_str(text)

    name,room,period = text.split("\n")
    name.sub!(/\[(.+)\]/, '\1') if name
    period.sub!(/\((\w+)\)/, '\1') if period
    [name,room,period]
  end

  def compact
    # 土曜日から連続して授業の無い日を消す
    table.reverse_each do |key, val|
      break unless val.all?{|elem| elem[:name].nil?}
      table.delete(key)
    end

    # 週を通してn時限目が無ければ消す
    6.downto(0).each do |i|
      break unless table.all?{|key, val| val[i][:name].nil?}
      table.each{|key, val| val.pop}
    end
  end

  def to_h
    @data_hash ||= {
      year: year,
      dates: dates,
      table: table,
      special: special,
    }
  end

  def to_s
    @data_str = to_h.to_s
  end

  def to_json
    @data_json ||= to_h.to_json
  end
end
