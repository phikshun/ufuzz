module UFuzz
  module Errors

    class Error < StandardError; end
    class StubNotFound < StandardError; end

    class SocketError < Error
      attr_reader :socket_error

      def initialize(socket_error=nil)
        if socket_error.message =~ /certificate verify failed/
          super("Unable to verify certificate")
        else
          super("#{socket_error.message} (#{socket_error.class})")
        end
        set_backtrace(socket_error.backtrace)
        @socket_error = socket_error
      end
    end

    class Timeout < Error; end

    class ProxyParseError < Error; end

    class ProxyConnectionError < Error; end

    class HTTPStatusError < Error
      attr_reader :request, :response

      def initialize(msg, request = nil, response = nil)
        super(msg)
        @request = request
        @response = response
      end
    end

    class Continue < HTTPStatusError; end                     # 100
    class SwitchingProtocols < HTTPStatusError; end           # 101
    class OK < HTTPStatusError; end                           # 200
    class Created < HTTPStatusError; end                      # 201
    class Accepted < HTTPStatusError; end                     # 202
    class NonAuthoritativeInformation < HTTPStatusError; end  # 203
    class NoContent < HTTPStatusError; end                    # 204
    class ResetContent < HTTPStatusError; end                 # 205
    class PartialContent < HTTPStatusError; end               # 206
    class MultipleChoices < HTTPStatusError; end              # 300
    class MovedPermanently < HTTPStatusError; end             # 301
    class Found < HTTPStatusError; end                        # 302
    class SeeOther < HTTPStatusError; end                     # 303
    class NotModified < HTTPStatusError; end                  # 304
    class UseProxy < HTTPStatusError; end                     # 305
    class TemporaryRedirect < HTTPStatusError; end            # 307
    class BadRequest < HTTPStatusError; end                   # 400
    class Unauthorized < HTTPStatusError; end                 # 401
    class PaymentRequired < HTTPStatusError; end              # 402
    class Forbidden < HTTPStatusError; end                    # 403
    class NotFound < HTTPStatusError; end                     # 404
    class MethodNotAllowed < HTTPStatusError; end             # 405
    class NotAcceptable < HTTPStatusError; end                # 406
    class ProxyAuthenticationRequired < HTTPStatusError; end  # 407
    class RequestTimeout < HTTPStatusError; end               # 408
    class Conflict < HTTPStatusError; end                     # 409
    class Gone < HTTPStatusError; end                         # 410
    class LengthRequired < HTTPStatusError; end               # 411
    class PreconditionFailed < HTTPStatusError; end           # 412
    class RequestEntityTooLarge < HTTPStatusError; end        # 413
    class RequestURITooLong < HTTPStatusError; end            # 414
    class UnsupportedMediaType < HTTPStatusError; end         # 415
    class RequestedRangeNotSatisfiable < HTTPStatusError; end # 416
    class ExpectationFailed < HTTPStatusError; end            # 417
    class UnprocessableEntity < HTTPStatusError; end          # 422
    class InternalServerError < HTTPStatusError; end          # 500
    class NotImplemented < HTTPStatusError; end               # 501
    class BadGateway < HTTPStatusError; end                   # 502
    class ServiceUnavailable < HTTPStatusError; end           # 503
    class GatewayTimeout < HTTPStatusError; end               # 504

    # Messages for nicer exceptions, from rfc2616
    def self.status_error(request, response)
      @errors ||= {
        100 => [UFuzz::Errors::Continue, 'Continue'],
        101 => [UFuzz::Errors::SwitchingProtocols, 'Switching Protocols'],
        200 => [UFuzz::Errors::OK, 'OK'],
        201 => [UFuzz::Errors::Created, 'Created'],
        202 => [UFuzz::Errors::Accepted, 'Accepted'],
        203 => [UFuzz::Errors::NonAuthoritativeInformation, 'Non-Authoritative Information'],
        204 => [UFuzz::Errors::NoContent, 'No Content'],
        205 => [UFuzz::Errors::ResetContent, 'Reset Content'],
        206 => [UFuzz::Errors::PartialContent, 'Partial Content'],
        300 => [UFuzz::Errors::MultipleChoices, 'Multiple Choices'],
        301 => [UFuzz::Errors::MovedPermanently, 'Moved Permanently'],
        302 => [UFuzz::Errors::Found, 'Found'],
        303 => [UFuzz::Errors::SeeOther, 'See Other'],
        304 => [UFuzz::Errors::NotModified, 'Not Modified'],
        305 => [UFuzz::Errors::UseProxy, 'Use Proxy'],
        307 => [UFuzz::Errors::TemporaryRedirect, 'Temporary Redirect'],
        400 => [UFuzz::Errors::BadRequest, 'Bad Request'],
        401 => [UFuzz::Errors::Unauthorized, 'Unauthorized'],
        402 => [UFuzz::Errors::PaymentRequired, 'Payment Required'],
        403 => [UFuzz::Errors::Forbidden, 'Forbidden'],
        404 => [UFuzz::Errors::NotFound, 'Not Found'],
        405 => [UFuzz::Errors::MethodNotAllowed, 'Method Not Allowed'],
        406 => [UFuzz::Errors::NotAcceptable, 'Not Acceptable'],
        407 => [UFuzz::Errors::ProxyAuthenticationRequired, 'Proxy Authentication Required'],
        408 => [UFuzz::Errors::RequestTimeout, 'Request Timeout'],
        409 => [UFuzz::Errors::Conflict, 'Conflict'],
        410 => [UFuzz::Errors::Gone, 'Gone'],
        411 => [UFuzz::Errors::LengthRequired, 'Length Required'],
        412 => [UFuzz::Errors::PreconditionFailed, 'Precondition Failed'],
        413 => [UFuzz::Errors::RequestEntityTooLarge, 'Request Entity Too Large'],
        414 => [UFuzz::Errors::RequestURITooLong, 'Request-URI Too Long'],
        415 => [UFuzz::Errors::UnsupportedMediaType, 'Unsupported Media Type'],
        416 => [UFuzz::Errors::RequestedRangeNotSatisfiable, 'Request Range Not Satisfiable'],
        417 => [UFuzz::Errors::ExpectationFailed, 'Expectation Failed'],
        422 => [UFuzz::Errors::UnprocessableEntity, 'Unprocessable Entity'],
        500 => [UFuzz::Errors::InternalServerError, 'InternalServerError'],
        501 => [UFuzz::Errors::NotImplemented, 'Not Implemented'],
        502 => [UFuzz::Errors::BadGateway, 'Bad Gateway'],
        503 => [UFuzz::Errors::ServiceUnavailable, 'Service Unavailable'],
        504 => [UFuzz::Errors::GatewayTimeout, 'Gateway Timeout']
      }

      error, message = @errors[response.status] || [UFuzz::Errors::HTTPStatusError, 'Unknown']

      message = "http error #{response} #{message})"

      error.new(message, request, response)
    end

  end
end