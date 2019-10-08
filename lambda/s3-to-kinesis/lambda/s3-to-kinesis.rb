require 'bundler/setup'
require 'logger'
require 'aws-sdk-s3'
require 'aws-sdk-kinesis'
require 'json'
require 'securerandom'
require 'cgi'


def lambda_handler(event:, context:)
  logger = Logger.new(STDOUT)
  logger.debug("#{event}")
  event['Records'].each do |record|
    bucket = record['s3']['bucket']['name']
    key = CGI::unescape(record['s3']['object']['key'])
    stream_name = ENV.fetch('KINESIS_STREAM_NAME') { 'xxxx' }
    s3 = Aws::S3::Client.new
    kinesis = Aws::Kinesis::Client.new
    logger.info("loading s3 object s3://#{bucket}/#{key}")
    object = s3.get_object(bucket: bucket, key: key)
    logger.info("pushing object to stream kinesis://#{stream_name}")
    kinesis.put_record({
      stream_name: stream_name,
      data: object.body.read,
      partition_key: SecureRandom.hex(128),
    })
    #logger.info("deleting s3 object s3://#{bucket}/#{object}")
    #s3.delete_object({bucket: bucket, key: key})
  end
end

## main method ##
#file = File.read('event.json')
#event = JSON.parse(file)
#lambda_handler(event: event, context: nil)
