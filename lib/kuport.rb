require 'mechanize'
require 'nokogiri'
require 'open-uri'
require 'fileutils'
require 'json'

require 'kuport/helper'

# TODO make test

class Kuport
  extend Kuport::Helper
  using Kuport::ClassExtensions

  class DownloadError < StandardError; end

  # Need last slash in url
  @@base_url = 'https://kuport.sc.kogakuin.ac.jp/ActiveCampus/'.freeze
  @@base_module = 'module/'.freeze
  @@modules = { login: 'Login.php', menu: 'Menu.php', messages: 'Message.php',
                messages_read: 'Message.php?mode=read',
                messages_backno: 'Message.php?mode=backno',
                timetable: 'Jikanwari.php',
                materials: 'Kyozai.php',
              }
  @@menu_items = {messages: '個人宛お知らせ',
                  messages_read: '個人宛お知らせ(既読)',
                  timetable: '時間割',
                  materials: '電子教材',
                  }

  @@cache_dir = File.join(Dir.home, '.cache', 'kuport').freeze
  @@cookies_file = File.join(@@cache_dir, 'cookies.jar')
  FileUtils.mkdir_p(@@cache_dir)

  def initialize(proxy: nil)
    agent.html_parser = self.class
    cookies_load

    proxy ||= Kuport.get_proxy_env_var
    if proxy
      agent.set_proxy(*Kuport.parse_proxy_str(proxy))
    end
  end

  def agent
    @agent ||= Mechanize.new
  end

  def self.module_url(*parts)
    URI.join(@@base_url, @@base_module, *parts)
  end

  def get_module(symb)
    agent.get(self.class.module_url(@@modules[symb]))
  end

  def menu_links
    @menu_links ||= get_module(:menu).links.reject{|l| l.text.empty? }
  end

  def cookies_save
    File.open(@@cookies_file, 'w'){|f| agent.cookie_jar.save(f, {session: true})}
  end

  def cookies_load
    File.open(@@cookies_file, 'r'){|f| agent.cookie_jar.load(f) } rescue nil
  end

  def cookies_clear
    agent.cookie_jar.clear!
    FileUtils.rm(@@cookies_file) if File.exist?(@@cookies_file)
  end

  def loggedin?
    nil != get_module(:login).form.has_value?('Logout')
  end

  def login_cookie
    return false unless cookies_load
    return true if loggedin?
    agent.cookie_jar.clear!
    false
  end

  def login_passwd(id, passwd)
    get_module(:login).form_with(name: 'login_form') do |f|
      f.login = id
      f.passwd = passwd
    end.submit

    return false unless loggedin?
    cookies_save
    true
  end

  def login(id)
    return true if login_cookie
    Kuport.quit('Please student id', 4) if id.blank?

    3.times do
      return true if login_passwd(id, Kuport.input_passwd)
      warn 'Login failed'
    end

    warn 'Login error'
    return false
  end

  def messages
    @messages ||= Message.parse_page(agent, get_module(:messages))
  end

  def messages_read
    @messages_read ||= Message.parse_page(agent, get_module(:messages_read))
  end

  def messages_backno
    raise NotImplementedError.new('Kuport#messages_backno') # TODO
  end

  def timetable
    @timetable ||= Timetable.new(get_module(:timetable))
  end

  def materials
    raise NotImplementedError.new('Kuport#materials') # TODO
  end

  def download_file(file_path, url)
    File.write(file_path, agent.get(url).content)
  rescue
    DownloadError.new(file_path)
  end

  # url_or_json is "http://....", {name:, path:}, or [{name:, path:}, ...]
  # If url_or_json is URL, need file_path
  def download(url_or_json, file_path=nil)
    if url_or_json.url?
      download_file(file_path, url_or_json)
      return
    end

    json = JSON.parse(url_or_json, {symbolize_names: true})
    if Array === json
      json.each{|link| download_file(link[:name], link[:path])}
    else
      download_file(json[:name], json[:path])
    end

  rescue JSON::ParserError
    raise DownloadError.new("JSON parse error '#{url_or_json}'")
  end

  # html parser for Mechanize. force encode to UTF-8
  def self.parse(text, url = nil, encoding = nil, options = Nokogiri::XML::ParseOptions::DEFAULT_HTML, &block)
    Nokogiri::HTML::Document.parse(text.toutf8, url, 'UTF-8', options, &block)
  end
end

require 'kuport/message'
require 'kuport/timetable'
require 'kuport/view'
require 'kuport/version'
