class Kuport
  module Helper
    def basename_noext(path)
      File.basename(path, File.extname(path))
    end

    def br_to_return(element)
      element.search('br').each{|br| br.replace("\n")}
    end

    def to_abs_url(base, part)
      uri = URI.parse(part)
      uri = URI.join(base, uri) if URI::Generic === uri
      uri.to_s
    end

    def color_str(color_num, str)
      "\e[38;5;#{color_num}m#{str}\e[00m"
    end

    def get_page_doc(page)
      Nokogiri::HTML.parse(page.content.toutf8)
    end

    def to_half_str(str)
      NKF.nkf('-m0Z1 -w -W', str)
    end

    def url?(str)
      str =~ /\A#{URI::regexp}\z/
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

    def blank?(var)
      var.nil? || var.empty?
    end
  end
end
