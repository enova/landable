require 'figgy'

module Landable
  class Configuration < Hash
    attr_accessor :api_url, :public_url, :amqp_configuration, :sitemap_host
    attr_writer :api_namespace, :public_namespace
    attr_writer :api_host, :public_host
    attr_writer :categories
    attr_writer :screenshots_enabled
    attr_writer :traffic_enabled
    attr_writer :sitemap_exclude_categories, :sitemap_protocol, :sitemap_additional_paths
    attr_writer :reserved_paths, :partials_to_templates, :database_schema_prefix
    attr_writer :publicist_url, :audit_flags
    attr_writer :blank_user_agent_string, :untracked_paths
    attr_writer :dnt_enabled, :amqp_event_mapping, :amqp_site_segment
    attr_writer :amqp_service_enabled, :amqp_messaging_service

    def initialize(config_path = nil)
      begin
        # let's keep this feature optional. Not all apps
        # will be using external configs for landable
        app_config = Figgy.build do |config_data|
          config_data.root = config_path

          config_data.define_overlay :default, nil
          config_data.define_overlay(:environment) { Rails.env }
        end

        # map our new configs into our local object.
        config_keys(config_path).each do |key|
          self[key] = app_config[key] unless app_config[key].nil?
        end
      end unless config_path.nil?
    end

    def amqp_configuration
      @amqp_configuration ||= {}
    end

    def authenticators
      @authenticators || fail('No Landable authenticator configured.')
    end

    def authenticators=(authenticators)
      @authenticators = Array(authenticators)
    end

    alias_method :authenticator=, :authenticators=

    def publicist_url
      @publicist_url ||= 'publicist.dev'
    end

    def api_uri
      @api_uri ||= URI(api_url) if api_url.present?
    end

    def api_host
      @api_host ||= api_uri.try(:host)
    end

    def api_namespace
      @api_namespace ||= (api_uri.try(:path).presence || '/api/landable')
    end

    def public_uri
      @public_uri ||= URI(public_url) if public_url.present?
    end

    def public_host
      @public_host ||= public_uri.try(:host)
    end

    def audit_flags
      @audit_flags ||= []
    end

    def public_namespace
      @public_namespace ||= (public_uri.try(:path).presence || '')
    end

    def database_schema_prefix
      @database_schema_prefix ||= ''
    end

    def database_schema_prefix=(val)
      @database_schema_prefix = "#{val}_" if val.present?
    end

    def categories
      # default categories
      @categories ||= {
        'Affiliates' => '',
        'PPC' => 'Pay-per-click',
        'SEO' => 'Search engine optimization',
        'Social' => '',
        'Email' => '',
        'Traditional' => ''
      }
    end

    def partials_to_templates
      @partials_to_templates ||= []
    end

    def reserved_paths
      @reserved_paths ||= []
    end

    def sitemap_exclude_categories
      @sitemap_exclude_categories ||= []
    end

    def sitemap_additional_paths
      @sitemap_additional_paths ||= []
    end

    def sitemap_protocol
      @sitemap_protocol ||= 'http'
    end

    def screenshots_enabled
      @screenshots_enabled ||= false
    end

    def traffic_enabled
      @traffic_enabled ||= false
    end

    def traffic_enabled=(val)
      fail(ArgumentError, 'Landable::Configuration#traffic_enabled accepts false, true, :all or :html') unless [true, false, :all, :html].include? val
      @traffic_enabled = val
    end

    def cors
      @cors ||= CORS.new
    end

    def cors=(bool)
      fail(ArgumentError, "Landable::Configuration#cors should be assigned 'false' to disable CORS support") if bool != false
      cors.origins = []
    end

    class CORS
      def enabled?
        origins.any?
      end

      def origins
        @origins ||= []
      end

      def origins=(origins)
        @origins = Array(origins)
      end
    end

    def screenshots
      @screenshots ||= Screenshots.new
    end

    def blank_user_agent_string
      @blank_user_agent_string ||= 'blank'
    end

    def untracked_paths
      @untracked_paths ||= []
    end

    def dnt_enabled
      return true if @dnt_enabled.nil?
      @dnt_enabled
    end

    def amqp_site_segment
      @amqp_site_segment ||= Rails.application.class.parent_name
    end

    def amqp_event_mapping
      @amqp_event_mapping ||= {}
    end

    def amqp_service_enabled
      amqp_configuration[:enabled] && amqp_configuration[:messaging_service]
    end

    class Screenshots
      attr_accessor :autorun
      attr_accessor :browserstack_username, :browserstack_password

      def initialize
        @autorun = true
      end
    end

    private

    DOTFILE_MATCHER_REGEXP = /^\.[[[:alnum:]]\.]*$/
    EXPECTED_FILETYPES = ['yml', 'yaml', 'json']
    EXPECTED_FILETYPES_REGEXP = /\.(#{ EXPECTED_FILETYPES.join('|') })\z/

    def config_keys(base_path)
      files = Dir.entries(base_path)
      keys = []

      files = remove_dotfiles(files)

      files.each do |filename|
        filename = File.join(base_path, filename)
        new_key = filename_to_key(filename)

        if File.file?(filename)
          keys.push(new_key)
        elsif File.directory?(filename) && new_key == Rails.env
          # only folders matching our environment!
          keys = keys.concat(config_keys(filename))
        end
      end

      keys.uniq
    end

    def filename_to_key(filename)
      File.basename(filename).sub(EXPECTED_FILETYPES_REGEXP, '')
    end

    def remove_dotfiles(filelist)
      filelist.delete_if do |filename|
        !DOTFILE_MATCHER_REGEXP.match(File.basename(filename)).nil?
      end
    end
  end
end
