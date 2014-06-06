#! coding: UTF-8

Plugin.create(:mikutter_toolbar_hardpoint) {
  require File.join(File.dirname(__FILE__), "toolbar_generator.rb")

  EventWithValue = Struct.new(:event, :widget, :messages, :value)

  # トグルボタン
  filter_toolbar_custom_widget { |command, event, role, widget|
    result = if command[:type] == :toggle_button
      face = command[:show_face] || command[:name] || command[:slug].to_s
      name = if defined? face.call then lambda{ |x| face.call(event) } else face end
     
      value = if command[:value].is_a?(Proc)
        command[:value].call(event)
      else
        command[:value]
      end

      item = ::Gtk::ToggleButton.new 
      item.add(::Gtk::WebIcon.new(command[:icon], 16, 16))
      item.tooltip(name)
      item.relief = ::Gtk::RELIEF_NONE

      if value
        item.active = true
      else
        item.active = false
      end

      item.ssc(:toggled){
        event2 = event.class.members.inject(EventWithValue.new) { |new_event, member|
          new_event[member] = event[member] 
          new_event
        }

        event2.value = item.active?
        command[:exec].call(event2) }

      item
    else
      widget
    end

    [command, event, role, result]
  }
}
