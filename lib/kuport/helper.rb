require 'uri'
require 'nkf'
require 'io/console'

class Kuport
  module Helper
    def to_abs_url(base, part)
      uri = URI.parse(part)
      uri = URI.join(base, uri) if URI::Generic === uri
      uri.to_s
    end

    def escape_filename(filename)
      File.basename(filename.strip)
    end

    def color_str(color_num, str)
      "\e[38;5;#{color_num}m#{str}\e[00m"
    end

    def get_page_doc(page)
      Nokogiri::HTML.parse(page.content.toutf8)
    end

    def input_num(str)
      print str
      gets.to_i rescue nil
    rescue Interrupt
      exit 1
    end

    def input_passwd
      $stderr.print 'Password> '
      pass = STDIN.noecho(&:gets).chomp rescue nil # &.chomp
      puts
      return pass
    rescue Interrupt
      exit 2
    end

    def quit(mes, ret=false)
      warn mes
      exit ret
    end

    def get_proxy_env_var
      keys = %w[ http_proxy https_proxy all_proxy ].map{|s| [s, s.upcase]}.flatten
      keys.each do |key|
        return ENV[key] if ENV.key?(key)
      end
      return nil
    end

    def parse_proxy_str(str)
      str = 'http://' + str if str !~ /\A\w+:\/\//
      u = URI.parse(str)
      [u.host, u.port]
    end
  end

  module ClassExtensions
    refine Object do
      def blank?
        true
      end
    end

    refine String do
      def to_half_str
        NKF.nkf('-m0Z1 -w -W', self)
      end

      def url?
        self =~ /\A#{URI::regexp}\z/
      end

      def blank?
        self.empty?
      end
    end

    refine Hash do
      def take_with_keys(*keys)
        ret = {}
        keys.each{|k| ret[k] = self.delete(k) if self.key?(k)}
        return ret.empty? ? nil : ret
      end
    end

    refine Nokogiri::XML::Node do
      def br_to_return
        self.search('br').each{|br| br.replace("\n")}
      end
    end

    refine File do
      def self.basename_noext(path)
        File.basename(path, File.extname(path))
      end
    end
  end
end
