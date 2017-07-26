class Kuport::Materials
  using Kuport::ClassExtensions
  attr_reader :trs, :base_url

  def initialize(page)
    @trs = page.at_css('.portlet_module > table').css('tr')
    trs.shift
    @base_url = page.uri
  end

  def materials
    @materials ||= trs.map{|tr| parse_table_line(tr)}.freeze
  end

  def parse_table_line(tr)
    tds = tr.css('td')
    {subject: tds[1].text,
     teacher: tds[2].text,
     title:   tds[3].text,
     period:  tds[4].text,
     state:   tds[5].text,
     links:   tds[6].css('li').map{|li| parse_link(li)},}.freeze
  end

  def parse_link(link)
    {name: Kuport.escape_filename(link.text),
     path: Kuport.to_abs_url(base_url, link.at_css('a')[:href]),}.freeze
  end

  def to_h
    materials
  end

  def to_s
    @materials_s ||= materials.to_s
  end

  def to_json(*a)
    @materials_json ||= to_h.to_json(*a)
  end
end
