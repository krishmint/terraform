output "key_name" {
  description = "Name of the key pair"
  value       = aws_key_pair.main.key_name
}

output "key_pair_id" {
  description = "ID of the key pair"
  value       = aws_key_pair.main.key_pair_id
}

output "fingerprint" {
  description = "SHA-1 digest of the DER encoded private key"
  value       = aws_key_pair.main.fingerprint
}

output "private_key_pem" {
  description = "Private key in PEM format"
  value       = tls_private_key.main.private_key_pem
  sensitive   = true
}

output "public_key_openssh" {
  description = "Public key in OpenSSH format"
  value       = tls_private_key.main.public_key_openssh
}

# output "s3_bucket_name" {
#   description = "S3 bucket name where keys are stored"
#   value       = aws_s3_bucket.key_storage.id
# }

# output "private_key_s3_location" {
#   description = "S3 location of the private key"
#   value       = "s3://${aws_s3_bucket.key_storage.id}/${aws_s3_object.private_key.key}"
#   sensitive   = true
# }

# output "public_key_s3_location" {
#   description = "S3 location of the public key"
#   value       = "s3://${aws_s3_bucket.key_storage.id}/${aws_s3_object.public_key.key}"
# }