# frozen_string_literal: true

module ExcelinatorRuby3
  # register as rails module
  module Rails
    def self.setup
      require 'action_controller'

      Mime::Type.register ExcelinatorRuby3::MIME_TYPE, :xls

      add_renderer if ::Rails::VERSION::MAJOR >= 3
    end

    def self.add_renderer
      ActionController::Renderers.add :xls do |filename, options|
        send_xls_data(filename, options)
      end
    end

    # Not rails module
    module ACMixin
      def send_xls_data(filename, options = {})
        content = render_to_string(options)
        xls_content = ExcelinatorRuby3.convert_content(content)
        send_data(xls_content, filename:, type: ExcelinatorRuby3::MIME_TYPE, disposition: 'inline')
      end
    end
  end
end
