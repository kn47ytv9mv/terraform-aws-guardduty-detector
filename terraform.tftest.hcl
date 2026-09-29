mock_provider "aws" {}

run "an_unknown_publishing_frequency_is_rejected" {
  command = plan

  variables {
    finding_publishing_frequency = "HOURLY"
  }

  expect_failures = [var.finding_publishing_frequency]
}

run "defaults_are_enabled_and_prompt" {
  command = apply

  assert {
    condition     = aws_guardduty_detector.resource.enable
    error_message = "The detector should be enabled by default."
  }

  assert {
    condition     = aws_guardduty_detector.resource.finding_publishing_frequency == "FIFTEEN_MINUTES"
    error_message = "Findings should publish every fifteen minutes, not on AWS's six-hour default - a detection delivered six hours late is a report, not an alert."
  }

  assert {
    condition     = length(aws_guardduty_detector_feature.resource) == 0
    error_message = "No extra protection features should be enabled unless asked for, because each is billed separately."
  }
}

run "features_can_be_enabled" {
  command = plan

  variables {
    features = [
      { name = "S3_DATA_EVENTS" },
      { name = "EKS_AUDIT_LOGS" },
      { name = "EBS_MALWARE_PROTECTION", status = "DISABLED" },
    ]
  }

  assert {
    condition     = length(aws_guardduty_detector_feature.resource) == 3
    error_message = "Every listed feature should produce a feature resource."
  }

  assert {
    condition     = aws_guardduty_detector_feature.resource["S3_DATA_EVENTS"].status == "ENABLED"
    error_message = "A feature with no status should default to ENABLED."
  }

  assert {
    condition     = aws_guardduty_detector_feature.resource["EBS_MALWARE_PROTECTION"].status == "DISABLED"
    error_message = "An explicit status should be honoured, so a feature can be pinned off."
  }
}

run "the_detector_can_be_paused" {
  command = plan

  variables {
    enable = false
  }

  assert {
    condition     = aws_guardduty_detector.resource.enable == false
    error_message = "Setting enable to false should pause analysis while keeping the detector."
  }
}
