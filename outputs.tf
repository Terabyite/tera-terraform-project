output "TeraInstance_PublicIP" {
  value = aws_instance.TeraInstance.public_ip
}

output "TeraBucket_Name" {
  value = aws_s3_bucket.TeraBucket.bucket
}

output "TeraVPC_ID" {
  value = aws_vpc.TeraVPC.id
}