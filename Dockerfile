FROM alpine:latest
LABEL Description="Extract private and public certifcats from acme.json generate by Traefik.\n Detect acme.json change" \
	License="MIT" \
	Usage="docker run -d -v [ACME_PATH]:/var/extractcert/acme -v [CERTS]:/var/extractcert/certs" \
	Version="1.0"

RUN apk add jq inotify-tools
COPY extractCert.sh /usr/bin
COPY notifyFile.sh /usr/bin
RUN chmod +x /usr/bin/extractCert.sh /usr/bin/notifyFile.sh
RUN mkdir -p /var/extractcert

VOLUME /var/extractcert/certs
VOLUME /var/extractcert/acme

CMD ["/usr/bin/notifyFile.sh"]
