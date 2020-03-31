#!/bin/sh

# Set up sshd
echo "Starting SSH ..."
sed -i "s/SSH_PORT/$SSH_PORT/g" /etc/ssh/sshd_config
ssh-keygen -A -q
/usr/sbin/sshd

# Run Spring Boot app
java -cp /app:/app/lib/* com.microsoft.azure.samples.spring.Application
