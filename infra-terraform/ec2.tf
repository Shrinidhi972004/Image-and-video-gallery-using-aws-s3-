resource "aws_instance" "ubuntu" {
  ami                         = "ami-02d26659fd82cf299"
  instance_type               = "c7i-flex.large"
  subnet_id                   = aws_subnet.main.id
  vpc_security_group_ids      = [aws_security_group.sg.id]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.terraform-key.key_name

  root_block_device {
    volume_size = 25
    volume_type = "gp3"
  }

  tags = {
    Name = "image-video-ubuntu"
  }
}
