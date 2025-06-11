require 'ipaddr'
require 'uri'

# Validates whether a user-provided URL is valid and non-malicious.
class UrlValidationService
  def initialize(url)
    @url = url
  end

  def valid?
    return false unless valid_url?
    return false unless ip_allowed?

    true
  end

  private

  def ip_allowed?
    host = uri.hostname
    return false if host.nil?

    # Remove brackets from IPv6 addresses
    host.gsub!(/^\[|\]$/, '')

    # Check if the host is a valid IP address
    ip_addr = IPAddr.new(host)
    private_ranges = [
      IPAddr.new('10.0.0.0/8'),
      IPAddr.new('172.16.0.0/12'),
      IPAddr.new('192.168.0.0/16'),
      IPAddr.new('127.0.0.0/8'),
      IPAddr.new('fc00::/7')
    ]
    private_ranges.none? { |range| range.include?(ip_addr) }
  rescue IPAddr::InvalidAddressError
    # `ipaddr` throws this error when trying to parse a host name that is
    # not a valid IP (e.g. "example.com"). We've already validate the URL is
    # of valid format, so if it's not an IP address there's nothing further
    # to be verified - return true.
    true
  rescue URI::InvalidURIError
    false
  end

  def uri
    @uri ||= URI.parse(@url)
  end

  def valid_url?
    URI::DEFAULT_PARSER.regexp[:ABS_URI] =~ uri.to_s &&
      %w[http https].include?(uri.scheme)
  rescue URI::InvalidURIError
    false
  end
end
