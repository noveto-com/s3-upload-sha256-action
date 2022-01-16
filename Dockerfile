FROM python:3.8-alpine

LABEL "com.github.actions.name"="S3 Upload SHA256"
LABEL "com.github.actions.description"="Upload the content of a directory to an AWS S3 bucket and add SHA256 checksum as metadata to each file"
LABEL "com.github.actions.icon"="folder-plus"
LABEL "com.github.actions.color"="blue"

LABEL version="0.0.2"
LABEL repository="https://github.com/noveto-com/s3-upload-sha256-action"
LABEL homepage="https://noveto.com/"
LABEL maintainer="https://github.com/stefanhp"

# https://github.com/aws/aws-cli/blob/master/CHANGELOG.rst
ENV AWSCLI_VERSION='1.22.36'

RUN pip install --quiet --no-cache-dir awscli==${AWSCLI_VERSION}

RUN apk add --no-cache bash
ADD entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
