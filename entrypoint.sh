#!/bin/bash

set -e

if [ -z "$AWS_S3_BUCKET" ]; then
  echo "AWS_S3_BUCKET is not set. Quitting."
  exit 1
fi

if [ -z "$AWS_ACCESS_KEY_ID" ]; then
  echo "AWS_ACCESS_KEY_ID is not set. Quitting."
  exit 1
fi

if [ -z "$AWS_SECRET_ACCESS_KEY" ]; then
  echo "AWS_SECRET_ACCESS_KEY is not set. Quitting."
  exit 1
fi

# Default to us-east-1 if AWS_REGION not set.
if [ -z "$AWS_REGION" ]; then
  AWS_REGION="us-east-1"
fi

# Override default AWS endpoint if user sets AWS_S3_ENDPOINT.
if [ -n "$AWS_S3_ENDPOINT" ]; then
  ENDPOINT_APPEND="--endpoint-url $AWS_S3_ENDPOINT"
fi

# Create a dedicated profile for this action to avoid conflicts
# with past/future actions.
aws configure --profile s3-upload-sha256-action <<-EOF > /dev/null 2>&1
${AWS_ACCESS_KEY_ID}
${AWS_SECRET_ACCESS_KEY}
${AWS_REGION}
text
EOF

# Find all files in the SOURCE_DIR, compute SHA 256, upload file and add
# SHA 256 as metadata
files=(`find ${SOURCE_DIR:-.} -type f`)
for file in ${files[@]}
do
    sha=($(sha256sum $file))
    file_no_source_dir=${file#*/}
    aws s3 cp \
        $file \
        s3://${AWS_S3_BUCKET}/${DEST_DIR}/$file_no_source_dir \
        --no-progress \
        --metadata sha256=$sha \
        ${ENDPOINT_APPEND} $*
done

# Clear out credentials after we're done.
# We need to re-run `aws configure` with bogus input instead of
# deleting ~/.aws in case there are other credentials living there.
# https://forums.aws.amazon.com/thread.jspa?threadID=148833
aws configure --profile s3-upload-sha256-action <<-EOF > /dev/null 2>&1
null
null
null
text
EOF
