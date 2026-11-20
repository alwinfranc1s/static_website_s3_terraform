# static_website_s3_terraform

Host a static homepage on Amazon S3 using Terraform.

## Deploy

Install Terraform, configure AWS credentials with permission to manage S3 buckets and objects, and choose a region and a globally unique bucket name. The effective account- and organization-level S3 Block Public Access settings must permit public bucket policies and anonymous reads. If they do not, use an account approved for public website hosting rather than disabling protections across a shared account.

```sh
export AWS_REGION=us-east-1
export TF_VAR_bucket_name=replace-with-your-unique-bucket-name
terraform init
terraform apply
terraform output -raw website_url
```

Open the output URL in a browser or run `curl --fail "$(terraform output -raw website_url)"` to verify anonymous access. S3 website endpoints are **HTTP only**. The bucket policy allows public reads of `index.html` only; it does not allow public bucket listing or writes.

Edit `index.html` and run `terraform apply` again to publish changes. Run `terraform destroy` with the same region and bucket name to remove the resources.
