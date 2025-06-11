require 'sinatra_helper'

RSpec.describe UrlValidationService, type: :service do
  [
    #
    # VALID URLS
    #
    # https URL
    ['https://baking.com/avocado-toast', true],
    # http URL
    ['http://baking.com/avocado-toast', true],
    # Trailing Slash
    ['https://baking.com/avocado-toast/', true],
    # Query Params
    ['https://baking.com/avocado-toast?foo=bar', true],
    # Subdomain
    ['https://www.baking.com/avocado-toast', true],
    # IPV4 host
    ['https://56.128.12.9/avocado-toast', true],
    # IPV4 host with port
    ['https://56.128.12.9:8080/avocado-toast', true],
    # IPV6 host
    ['https://[2607:5300:120:11d:120:11c::]/', true],
    # IPV6 host with port
    ['https://[2607:5300:120:11d:120:11c::]:8080/', true],
    #
    # INVALID URLS
    #
    # Invalid URL format
    ['some-string', false],
    # Invalid scheme
    ['file://www.baking.com/avocado-toast', false],
    # Missing Host
    ['https:///avocado-toast', false],
    # Private IPV4 hosts
    ['10.0.0.1', false],
    ['172.16.0.1', false],
    ['192.168.0.1', false],
    ['127.0.0.1', false],
    # Private IPV6 hosts
    ['https://[fd12:3456:789a:1::1]/', false]
  ].each do |(url, result)|
    it "URL '#{url}' should #{'NOT ' unless result}be valid" do
      expect(UrlValidationService.new(url).valid?).to eq(result)
    end
  end
end
