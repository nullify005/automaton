SparkleFormation.new(:stack, provider: :aws).load(:base).overrides do
  dynamic!(
    :sqs,
    :cdn_logging_trigger_sqs,
    queue_name: "infrastructure-cdn-logging-playpen.fifo",
    fifo_queue: true,
    message_retention_period: 345600  # 4 days (the default)
  )
  dynamic!(
    :repository,
    :fastly_serve_stale_ecr,
    repository_name: 'infrastructure/fastly-serve-stale',
    keep_images: 30,
    #disable_default_expiry_tags: true, # default is to expire tags with prefix ["0","1",...,"9"]
    #expire_tags: %w[0 1],
    expire_untagged: true # expire untagged images after 14 days
  )
  dynamic!(
    :bucket,
    :fastly_serve_stale_bucket,
    bucket_name: 'infrastructure-cdn-fastly-logging-playpen.apse2.ffx.io',
    access_control: 'Private',
    lifecycle_configuration: [
      {"Id": "Expire", "Status": "Enabled", "ExpirationInDays": "2"}
    ],
    notification_configuration: {
      "QueueConfigurations": [
        {
          "Event": "s3:ObjectCreated:*",
          "Filter": "",
          "Queue": ""
        }
      ]
    }
  )
  dynamic!(
    :bucket,
    :terraform_state_bucket,
    bucket_name: 'infrastructure-cdn-fastly-terraform-playpen.apse2.ffx.io',
    access_control: 'Private'
  )

end
