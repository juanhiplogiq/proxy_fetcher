module ProxyFetcher
  class Document
    class OgaAdapter < AbstractAdapter
      def self.install_requirements!
        require 'oga'
      end

      def self.parse(data)
        new(::Oga.parse_html(data))
      end

      class Node < ProxyFetcher::Document::Node
        def attr(*args)
          clear(node.attribute(*args).value)
        end

        def content
          clear(node.text)
        end

        def html
          node.to_xml
        end
      end
    end
  end
end
