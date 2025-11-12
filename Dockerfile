FROM parrotsec/security:latest

WORKDIR /opt/ctf

# Copy the provisioning script and execute it during build
COPY install-extras.sh /tmp/install-extras.sh
RUN chmod +x /tmp/install-extras.sh \
    && /tmp/install-extras.sh \
    && rm /tmp/install-extras.sh

ENTRYPOINT ["/bin/bash"]
