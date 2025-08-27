# Self-signed certificate for ALB
resource "aws_acm_certificate" "self_signed" {
  private_key = tls_private_key.self_signed.private_key_pem
  certificate_body = tls_self_signed_cert.self_signed.cert_pem

  tags = {
    Name        = "${var.organization_name}-${var.environment}-self-signed"
    Environment = var.environment
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Generate private key for self-signed certificate
resource "tls_private_key" "self_signed" {
  algorithm = "RSA"
  rsa_bits = 2048
}

# Generate self-signed certificate
resource "tls_self_signed_cert" "self_signed" {
  private_key_pem = tls_private_key.self_signed.private_key_pem

  subject {
    common_name = aws_lb.alb.dns_name
  }

  validity_period_hours = 8760 # 1 year

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}

# Output com a URL HTTPS do ALB
output "alb_url" {
  description = "URL do ALB para acesso direto"
  value       = "https://${aws_lb.alb.dns_name}"
}
