module "cloudwatch_label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  delimiter   = "/"
  label_order = var.label_orders.cloudwatch

  context = module.this.context
}

resource "aws_cloudwatch_metric_alarm" "milliseconds_behind" {
  count = module.this.enabled ? 1 : 0

  alarm_description   = var.alarm_description
  alarm_name          = "${module.this.id}-kinsumer-${var.kinsumer_name}-milliseconds-behind"
  period              = var.period
  evaluation_periods  = var.evaluation_periods
  datapoints_to_alarm = var.datapoints_to_alarm
  comparison_operator = "GreaterThanThreshold"
  threshold           = var.threshold_seconds_behind * 1000
  treat_missing_data  = "breaching"

  namespace   = module.cloudwatch_label.id
  metric_name = "MillisecondsBehind"
  dimensions = {
    StreamName = var.kinsumer_stream_name
  }
  statistic = "Maximum"

  alarm_actions = [var.alarm_topic_arn]
  ok_actions    = [var.alarm_topic_arn]

  tags = module.this.tags
}
