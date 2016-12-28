class Kuport::Message
  using Kuport::ClassExtensions
  attr_reader :agent, :base_url, :title, :body, :links

  # return [Message,...]
  def self.parse_page(agent, page)
    doc = Kuport.get_page_doc(page)
    doc.css('.message > li').map{|mes| self.new(agent, mes, page.uri)}
  end

  def initialize(agent, doc, base_url)
    @agent = agent
    @base_url = base_url
    @title = parse_title(doc)

    doc_mes = get_message_doc(doc)

    if doc_mes
      @body = get_body_text(doc_mes)
    else
      # When message is link
      doc_mes = get_linked_page_doc(doc)
      @body = get_body_text(get_message_doc(doc_mes))
    end

    @links = parse_links(doc_mes)
  end

  def parse_title(doc)
    doc.children.select(&:text?).join.strip + doc.at_css('a').text.freeze
  end

  def get_message_doc(doc)
    doc.at_xpath(".//*[contains(@class, 'message')]")
  end

  def get_body_text(doc)
    doc.text.strip.gsub(/\r\n/, "\n").freeze rescue "Error in #{title}"
  end

  # Call if message is link
  def get_linked_page_doc(doc)
    link = parse_link(doc.at_css('a'))[:path]
    doc_new = Kuport.get_page_doc(agent.get(link))
    doc_new.at_css('.portlet_module')
  end

  def parse_links(doc_mes)
    doc_mes.css('a').map{|elem| parse_link(elem)}.freeze rescue [{name: "Error in #{title}", path: ''}]
  end

  def parse_link(elem)
    {name: elem.text, path: Kuport.to_abs_url(base_url, elem[:href])}.freeze
  end

  def to_h
    @data_hash ||= {title: title, body: body, links: links}.freeze
  end

  def to_s
    @data_str ||= ("#{title}\n\n#{body}\n\n" + links.map{|l| l[:name]}.join("\n")).freeze
  end

  def to_json(*a)
    @data_json ||= to_h.to_json(*a)
  end

  def inspect
    "title: #{title}\nbody: #{body}\nlinks: #{links}".freeze
  end
end
