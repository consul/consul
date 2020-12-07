module FormHelper
  def form_for(record, options = {}, &block)
    html_options = { novalidate: true }.merge(options[:html] || {})

    super(record, options.merge(html: html_options), &block)
  end
end
