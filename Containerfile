# Copyright (c) 2019 Red Hat, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
# implied.
# See the License for the specific language governing permissions and
# limitations under the License.

ARG CONTAINER_IMAGE=quay.io/ansible/python-base:latest
ARG REMOTE_SOURCE=.
ARG REMOTE_SOURCE_DIR=/remote-source
ARG REMOTE_SOURCE_APP_DIR=$REMOTE_SOURCE_DIR

FROM $CONTAINER_IMAGE as builder
# =============================================================================
ARG REMOTE_SOURCE_DIR
COPY $REMOTE_SOURCE $REMOTE_SOURCE_DIR

FROM $CONTAINER_IMAGE
# =============================================================================
ARG REMOTE_SOURCE_APP_DIR

COPY --from=builder $REMOTE_SOURCE_APP_DIR/build-requirements.txt $REMOTE_SOURCE_APP_DIR/build-requirements.txt
COPY --from=builder $REMOTE_SOURCE_APP_DIR/requirements.txt $REMOTE_SOURCE_APP_DIR/requirements.txt
COPY --from=builder $REMOTE_SOURCE_APP_DIR/scripts/assemble /usr/local/bin/assemble
COPY --from=builder $REMOTE_SOURCE_APP_DIR/scripts/get-extras-packages /usr/local/bin/get-extras-packages
COPY --from=builder $REMOTE_SOURCE_APP_DIR/scripts/install-from-bindep /output/install-from-bindep

WORKDIR $REMOTE_SOURCE_APP_DIR

RUN dnf update -y \
  && dnf install -y python38-wheel git \
  && dnf clean all \
  && rm -rf /var/cache/dnf

RUN cat build-requirements.txt requirements.txt | sort > upper-constraints.txt \
  && pip3 install --no-cache-dir -r build-requirements.txt -c upper-constraints.txt \
  && pip3 install --no-cache-dir -r requirements.txt -c upper-constraints.txt

WORKDIR /
RUN rm -rf $REMOTE_SOURCE_APP_DIR
