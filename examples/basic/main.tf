module "example" {
  source = "../../"

  alarm_description        = "Kinsumer milliseconds behind alarm"
  kinsumer_name            = "my-kinsumer"
  period                   = 300
  evaluation_periods       = 2
  datapoints_to_alarm      = 2
  threshold_seconds_behind = 60
  kinsumer_stream_name     = "my-stream"

  alarm_topic_arn = "arn:aws:sns:us-east-1:123456789012:my-topic"
}
