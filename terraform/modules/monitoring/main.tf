# SNS Topic para alarmes
resource "aws_sns_topic" "alarms" {
  name = "${var.organization_name}-${var.environment}-alarms"
}

resource "aws_sns_topic_subscription" "alarm_email" {
  topic_arn = aws_sns_topic.alarms.arn
  protocol  = "email"
  endpoint  = var.alarm_email
}

# Alarme para erros 5xx
resource "aws_cloudwatch_metric_alarm" "http_5xx_errors" {
  alarm_name          = "${var.organization_name}-${var.environment}-5xx-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name        = "5xx"
  namespace          = "AWS/HttpApi"
  period             = 300  # 5 minutos
  statistic          = "Sum"
  threshold          = var.error_rate_threshold
  alarm_description  = "Este alarme será acionado quando a taxa de erros 5xx exceder ${var.error_rate_threshold}%"
  alarm_actions      = [aws_sns_topic.alarms.arn]
  ok_actions         = [aws_sns_topic.alarms.arn]
  treat_missing_data = "notBreaching"

  dimensions = {
    ApiId = var.api_id
  }
}

# Alarme para latência alta
resource "aws_cloudwatch_metric_alarm" "high_latency" {
  alarm_name          = "${var.organization_name}-${var.environment}-high-latency"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name        = "Latency"
  namespace          = "AWS/HttpApi"
  period             = 300  # 5 minutos
  statistic          = "Average"
  threshold          = var.latency_threshold
  alarm_description  = "Este alarme será acionado quando a latência média exceder ${var.latency_threshold} segundos"
  alarm_actions      = [aws_sns_topic.alarms.arn]
  ok_actions         = [aws_sns_topic.alarms.arn]
  treat_missing_data = "notBreaching"

  dimensions = {
    ApiId = var.api_id
  }
}
