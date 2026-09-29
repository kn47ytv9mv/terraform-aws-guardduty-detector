resource "aws_guardduty_detector" "resource" {
  enable                       = var.enable
  finding_publishing_frequency = var.finding_publishing_frequency

  tags = var.tags
}

resource "aws_guardduty_detector_feature" "resource" {
  for_each = { for feature in var.features : feature.name => feature }

  detector_id = aws_guardduty_detector.resource.id
  name        = each.value.name
  status      = each.value.status
}

output "id" {
  description = "The ID of the detector. There is one per account per region, and a second apply in the same region will fail rather than create another."
  value       = aws_guardduty_detector.resource.id
}

output "arn" {
  description = "The ARN of the detector."
  value       = aws_guardduty_detector.resource.arn
}

output "account_id" {
  description = "The account the detector belongs to."
  value       = aws_guardduty_detector.resource.account_id
}
