resource "aws_s3_bucket" "app_bucket" {
  bucket = "my-app-bucket"
}

resource "aws_s3_bucket_public_access_block" "app_bucket" {
  bucket = aws_s3_bucket.app_bucket.id
  
  # Fixed: Block all public access (4 settings = true)
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_security_group" "app_sg" {
  name = "app-sg"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    # Fixed: Restrict SSH to specific IP range (replace with your IP)
    cidr_blocks = ["203.0.113.0/24"]
  }
}
