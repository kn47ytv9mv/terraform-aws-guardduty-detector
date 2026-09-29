# terraform-aws-guardduty-detector

Terraform module for a GuardDuty detector and, optionally, the protection
features layered on top of it. The detector analyses CloudTrail management
events, VPC flow logs and DNS logs for signs of compromise.

## Cost

The baseline detector is billed on the volume of events and logs analysed,
so it grows with the estate rather than sitting still. Each protection
feature is billed separately and independently of the baseline, which is
why none is enabled here by default: `S3_DATA_EVENTS` bills on S3 data
event volume, `EKS_AUDIT_LOGS` on audit log volume,
`EBS_MALWARE_PROTECTION` on gigabytes scanned per snapshot,
`RDS_LOGIN_EVENTS` and `LAMBDA_NETWORK_LOGS` on their own event volumes,
and `RUNTIME_MONITORING` on agent vCPU-hours.

S3 data events are the common surprise, because data events are far more
numerous than management events. AWS offers a trial period per feature,
which is the cheapest way to measure what each costs in your own account
before committing. See AWS's
[GuardDuty pricing](https://aws.amazon.com/guardduty/pricing/) page for
current rates.

## Design

There is exactly one detector per account per region. Applying this module
twice in the same region fails rather than creating a second, and if
GuardDuty was ever enabled by hand the existing detector must be imported
instead.

Findings publish every fifteen minutes rather than AWS's six-hour default,
because a detection delivered six hours late is a report rather than an
alert.

### Regional scope

Enabling the detector in one region leaves every other region unmonitored,
and an attacker operating in an unused region is exactly the case GuardDuty
exists to catch. Apply it in every region that holds anything.

### Findings go nowhere on their own

GuardDuty raises findings. Routing them to a person is EventBridge and SNS,
or centralisation through `terraform-aws-securityhub-account`.

### Disabling is not deleting

Setting `enable` to false pauses analysis and keeps the detector and its
configuration, which is what is wanted while investigating a cost increase.

## Usage

```hcl
module "guardduty" {
  source = "kn47ytv9mv/guardduty-detector/aws"
}
```

Or directly from this repository:

```hcl
module "guardduty" {
  source = "github.com/kn47ytv9mv/terraform-aws-guardduty-detector"
}
```

With the features that suit an account running containers and S3:

```hcl
module "guardduty" {
  source = "kn47ytv9mv/guardduty-detector/aws"

  features = [
    { name = "S3_DATA_EVENTS" },
    { name = "EKS_AUDIT_LOGS" },
    { name = "EBS_MALWARE_PROTECTION" },
  ]
}
```

## Requirements

| Name | Version |
|---|---|
| terraform | >= 1.3 |
| aws | ~> 6.61 |

## Providers

| Name | Version |
|---|---|
| aws | ~> 6.61 |

## Inputs

| Name | Description | Default | Required |
|---|---|---|---|
| enable | Whether the detector is enabled. Disabling it stops analysis but keeps the detector and its configuration. | `true` | no |
| finding_publishing_frequency | How often findings are published (e.g. `'FIFTEEN_MINUTES'`, `'ONE_HOUR'`, `'SIX_HOURS'`). | `"FIFTEEN_MINUTES"` | no |
| features | Protection features to turn on beyond the baseline. Each is billed separately. | `[]` | no |
| tags | A map of tags to assign to the detector. | `null` | no |

## Outputs

| Name | Description |
|---|---|
| id | The ID of the detector. |
| arn | The ARN of the detector. |
| account_id | The account the detector belongs to. |

## License

MIT — see [LICENSE.md](LICENSE.md).
