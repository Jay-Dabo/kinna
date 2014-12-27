# PDF mimetype is already specified in action_dispatch
# Mime::Type.register "application/pdf", :pdf
WickedPdf.config = {
  wkhtmltopdf: Rails.root.join('bin', 'wkhtmltopdf-local').to_s,
  #exe_path: "bundle exec #{Rails.root.join('bin', 'wkhtmltopdf-local')}",
  exe_path: "#{Rails.root.join('bin', 'wkhtmltopdf-local')}",
}

puts "wkhtmltopdf path: #{WickedPdf.config[:wkhtmltopdf]}"
raise RuntimeError, "cant find wkhtmltopdf" unless File.exists?("#{WickedPdf.config[:wkhtmltopdf]}")
