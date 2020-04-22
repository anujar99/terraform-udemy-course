# Public access creds
resource "aws_key_pair" "access_key" {
  key_name   = "wsl_key"
  public_key = file(var.PATH_TO_PUBLIC_KEY)
}

resource "aws_instance" "example" {
  # Define image
  ami           = var.AMIS[var.AWS_REGION]
  instance_type = "t2.micro"
  key_name      = aws_key_pair.access_key.key_name

  # Output container's IP locally
  provisioner "local-exec" {
    command = "echo ${aws_instance.example.private_ip} >> private_ips.txt"
  }

  # Private key for ssh access
  connection {
    host        = coalesce(self.public_ip, self.private_ip)
    type        = "ssh"
    user        = var.INSTANCE_USERNAME
    private_key = file(var.PATH_TO_PRIVATE_KEY)
  }
}

# Output to stdout(?)
output "ip" {
  value = aws_instance.example.public_ip
}

