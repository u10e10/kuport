# TODO
class KuportView < Kuport
  def show_menu
    @@menu_items.each_with_index do |(key,value), i|
      print "%1d %s\n" % [i, value]
    end
  end

  def select_menu
    show_menu
    num = input_num("[0..#{@@menu_items.size-1}]> ")
    send(menu[num]) rescue nil
  end

  def show_messages
    messages.each_with_index do |mes, i|
      print "%3d %s\n" % [i, mes]
    end
  end
end
