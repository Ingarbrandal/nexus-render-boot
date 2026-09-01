FROM python:3.12-bookworm
RUN apt-get update \
 && apt-get install -y --no-install-recommends git \
 && rm -rf /var/lib/apt/lists/*
COPY start.sh /start.sh
RUN chmod +x /start.sh
WORKDIR /opt
CMD ["/start.sh"]
