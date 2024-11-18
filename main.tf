locals {
  alarm_topic_arn = var.alarm_topic_arn != null ? var.alarm_topic_arn : "arn:aws:sns:${module.this.aws_region}:${module.this.aws_account_id}:${module.this.environment}-alarms"

  alarm_levels = {
    warning = {
      alarm_priority      = var.alarm_priority_warning
      datapoints_to_alarm = var.datapoints_to_alarm
      evaluation_periods  = var.evaluation_periods
    }
    high = {
      alarm_priority      = var.alarm_priority_high
      datapoints_to_alarm = floor(3600 / var.period)
      evaluation_periods  = floor(3600 / var.period)
    }
  }
}

module "cloudwatch_label" {
  source  = "justtrackio/label/null"
  version = "0.26.0"

  delimiter   = "/"
  label_order = var.label_orders.cloudwatch

  context = module.this.context
}

resource "aws_cloudwatch_metric_alarm" "default" {
  for_each = module.this.enabled ? local.alarm_levels : {}

  alarm_description = jsonencode(merge({
    Priority = each.value.alarm_priority
  }, jsondecode(var.alarm_description)))
  alarm_name          = "${module.this.id}-kinsumer-${var.kinsumer_name}-milliseconds-behind-${each.key}"
  datapoints_to_alarm = each.value.datapoints_to_alarm
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = each.value.evaluation_periods
  threshold           = var.threshold * 1000
  treat_missing_data  = "breaching"

  namespace   = module.cloudwatch_label.id
  metric_name = "MillisecondsBehind"
  dimensions = {
    StreamName = var.kinsumer_stream_name
  }
  statistic = "Maximum"

  alarm_actions = [local.alarm_topic_arn]
  ok_actions    = [local.alarm_topic_arn]

  tags = module.this.tags
}
