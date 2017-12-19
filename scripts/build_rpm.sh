#!/bin/bash

SOURCE_DIR="package/rpm"
DESTINATION_DIR="package/rpm-build"
export GPG_PRIVATE_KEY="`cat usacloud_gpg_key`"

set -e
set -x

: "prepare rpm build..."
    rm -rf rpmbuild/
    mkdir -p rpmbuild/RPMS/{x86_64,noarch}
    rm -rf repos/centos
    mkdir -p repos/centos/{x86_64,noarch}
    rm -rf "${DESTINATION_DIR}"
    mkdir -p "${DESTINATION_DIR}/src"
    cp contrib/completion/bash/hanami "${DESTINATION_DIR}/src/hanami_bash_completion"
    cp "${SOURCE_DIR}/hanami.spec" "${DESTINATION_DIR}/hanami.spec"

: "building i386..."
    unzip -oq bin/hanami_linux-386.zip -d bin/
	docker run --rm \
	    -v "$PWD":/workdir \
	    -v "$PWD/rpmbuild":/rpmbuild \
	    sacloud/rpm-build:latest \
	        --define "_sourcedir /workdir/package/rpm-build/src" \
	        --define "_builddir /workdir/bin" \
	        --define "_version ${CURRENT_VERSION}" \
	        --define "buildarch noarch" \
	        --target noarch \
	        -bb package/rpm-build/hanami.spec

    # sign to rpm
	docker run --rm \
	    -v "$PWD/rpmbuild":/rpmbuild \
	    -e GPG_PRIVATE_KEY \
	    -e GPG_PASSPHRASE \
	    -e GPG_FINGERPRINT \
	    -e GPG_NAME \
	    --entrypoint /sign_to_rpm.sh \
	    --workdir /rpmbuild/RPMS/noarch \
	    sacloud/rpm-build:latest

: "building x86_64..."
    unzip -oq bin/hanami_linux-amd64.zip -d bin/
	docker run --rm \
	    -v "$PWD":/workdir \
	    -v "$PWD/rpmbuild":/rpmbuild \
	    sacloud/rpm-build:latest \
	        --define "_sourcedir /workdir/package/rpm-build/src" \
	        --define "_builddir /workdir/bin" \
	        --define "_version ${CURRENT_VERSION}" \
	        --define "buildarch x86_64" \
	        --target x86_64 \
	        -bb package/rpm-build/hanami.spec

    # sign to rpm
	docker run --rm \
	    -v "$PWD/rpmbuild":/rpmbuild \
	    -e GPG_PRIVATE_KEY \
	    -e GPG_PASSPHRASE \
	    -e GPG_FINGERPRINT \
	    -e GPG_NAME \
	    --entrypoint /sign_to_rpm.sh \
	    --workdir /rpmbuild/RPMS/x86_64 \
	    sacloud/rpm-build:latest

: "create yum repo..."
    cp -rf rpmbuild/RPMS/noarch/* repos/centos/noarch/
    cp -rf rpmbuild/RPMS/x86_64/* repos/centos/x86_64/
	docker run --rm \
	    -v "$PWD/repos/centos/noarch":/workdir \
	    --entrypoint createrepo \
	    sacloud/rpm-build:latest \
	        -v /workdir
	docker run --rm \
	    -v "$PWD/repos/centos/x86_64":/workdir \
	    --entrypoint createrepo \
	    sacloud/rpm-build:latest \
	        -v /workdir

