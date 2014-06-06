# -*- coding: utf-8 -*-

module Plugin::Gtk
  module ToolbarGenerator

    # ツールボタンを得る
    def self.create_standard_toolbutton(command, event)
      face = command[:show_face] || command[:name] || command[:slug].to_s
      name = if defined? face.call then lambda{ |x| face.call(event) } else face end
      item = ::Gtk::Button.new
      item.add(::Gtk::WebIcon.new(command[:icon], 16, 16))
      item.tooltip(name)
      item.relief = ::Gtk::RELIEF_NONE 
      item end

    # ツールバーに表示するボタンを _container_ にpackする。
    # 返された時点では空で、後からボタンが入る(showメソッドは自動的に呼ばれる)。
    # ==== Args
    # [container] packするコンテナ
    # ==== Return
    # container
    def self.generate(container, event, role)
      Thread.new{
        Plugin.filtering(:command, {}).first.values.select{ |command|
          command[:icon] and command[:role] == role and command[:condition] === event }
      }.next{ |commands|
        commands.each{ |command|
          result = Plugin.filtering(:toolbar_custom_widget, command, event, role, nil)

          toolitem = if result[3]
            result[3]
          else
            item = create_standard_toolbutton(command, event)

            item.ssc(:clicked){
              command[:exec].call(event) }

            item
          end

          container.closeup(toolitem) }
        #container.ssc(:realize, &:queue_resize)
        container.show_all if not commands.empty?
      }.trap{ |e|
        error "error on command toolbar:"
        error e
      }.terminate
      container end
  end
end
