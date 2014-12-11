module ApplicationHelper

  # @todo make currency a setting.
  # we currently only support one currency, with the format of 5600 = 56.00 SEK
  def as_sek(integer_number, unit = 'SEK')
    number_to_currency(integer_number / 100.0, precision: 2, format: "%n %u", unit: unit)
  end

  # Prints a delete link button
  # depends that the object responds to a .can_delete? method
  def delete_button_for(obj, other_path = nil)
    p = other_path || obj
    return unless obj.can_delete?
    link_to delete_icon, p, method: :delete, data: { confirm: 'Are you Sure?' }
  end

  def delete_modal_for(obj, other_path = nil)
    return unless obj.can_delete?
    path = other_path || url_for(obj)
    link_to delete_icon(obj), '#', :ng_click =>"open_delete($event, 'sm','deleteContent', '#{path}')"
  end

  # @todo Refactor this into an module or something.
  # A couple of short hand methods to make the html a bit nicer.
  # To short to be in a partial, but doesn't belong in a helper...
  def settings_icon
    "<i class=\"glyphicon glyphicon-cog settings-icon\"> </i>".html_safe
  end

  def delete_icon(obj = nil)
    if obj
      # Downcase and remove 'decorator' from the class name.
      obj_origin_class_name = obj.class.name.downcase.gsub('decorator','')
      extra_css_class = "#{obj_origin_class_name}-#{obj.id}"
    end
    glyphicon('trash', "delete-icon #{extra_css_class}")
  end

  def refresh_icon
    glyphicon('refresh', 'refresh-icon')
  end

  def plus_icon
    "<i class=\"glyphicon glyphicon-plus-sign plus-icon\"> </i>".html_safe
  end
  def list_icon
    "<i class=\"glyphicon glyphicon-align-justify\"> </i>".html_safe
  end
  def search_icon
    "<i class=\"glyphicon glyphicon-search search_icon\"> </i>".html_safe
  end
  def status_icon
    "<i class=\"glyphicon glyphicon-flag status_icon\"> </i>".html_safe
  end
  def ok_icon
    "<i class=\"glyphicon glyphicon-ok ok_icon\"> </i>".html_safe
  end
  def doc_icon
    "<i class=\"glyphicon glyphicon-file file_icon\"> </i>".html_safe
  end
  def edit_icon
    "<i class=\"glyphicon glyphicon-edit edit_icon\"> </i>".html_safe
  end

  def envelope_icon
    "<i class=\"glyphicon glyphicon-envelope envelope_icon\"> </i>".html_safe
  end

  def glyphicon(icon_name, extra_css_classes = '')
    class_string = "glyphicon glyphicon-#{icon_name} #{extra_css_classes}"
    content_tag(:i, ' ', class: class_string)
  end

  def nav_link link_text, link_path
    if current_page? link_path
      content_tag(:li, class: 'active') { link_to link_text, link_path }
    else
      content_tag(:li) { link_to link_text, link_path }
    end
  end

  def form_submit(sform, text = nil)
    content_tag(:div, class: 'form-group') do
      if text
        sform.button :submit, class: "btn btn-primary", value: text
      else
        sform.button :submit, class: "btn btn-primary"
      end
    end
  end

  def labelify(str, label_state)
    content_tag :span, class: "label label-#{label_state}" do
      str
    end
  end

  def months_list
    a = []
    (2011..Time.now.year).each do |year|
      (1..12).each do |month|
        a << [sprintf('%d %02d', year, month), sprintf('%d-%02d', year, month)]
      end
    end
    a.reverse
  end
end
