module ProxyFetcher
  module Providers
    class HideMyName < Base
      PROVIDER_URL = 'https://hidemy.name/en/proxy-list/?type=hs'.freeze

      class << self
        def load_proxy_list
          doc = Nokogiri::HTML(load_html(PROVIDER_URL))
          doc.xpath('//table[@class="proxy__t"]/tbody/tr')
        end
      end

      def parse!(html_entry)
        html_entry.xpath('td').each_with_index do |td, index|
          case index
          when 0
            set!(:addr, td.content.strip)
          when 1 then
            set!(:port, Integer(td.content.strip))
          when 2 then
            set!(:country, td.at_xpath('*//span[1]/following-sibling::text()[1]').content.strip)
          when 3
            response_time = Integer(td.at('p').content.strip[/\d+/])

            set!(:response_time, response_time)
            set!(:speed, speed_from_response_time(response_time))
          when 4
            set!(:type, parse_type(td))
          when 5
            set!(:anonymity, td.content.strip)
          else
            # nothing
          end
        end
      end

      private

      def parse_type(td)
        schemas = td.content.strip

        if schemas && schemas.downcase.include?('https')
          'HTTPS'
        else
          'HTTP'
        end
      end

      def speed_from_response_time(response_time)
        if response_time < 1500
          :fast
        elsif response_time < 3000
          :medium
        else
          :slow
        end
      end
    end

    ProxyFetcher::Configuration.register_provider(:hide_my_name, HideMyName)
  end
end