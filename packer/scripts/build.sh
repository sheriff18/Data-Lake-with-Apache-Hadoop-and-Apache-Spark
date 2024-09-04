#!/bin/sh

function mirror_error {
    echo "ERROR: $1"
    exit -1
}

TARBALL=pnda.tar.gz

rm -rf $TARBALL pnda
curl -LsS -o $TARBALL $PNDA_REPO/archive/$PNDA_BRANCH.tar.gz
[[ $? -ne 0 ]] && mirror_error "Problem while getting $PNDA_REPO/archive/$PNDA_BRANCH.tar.gz"

mkdir pnda
tar zxf $TARBALL --strip-components=1 -C pnda

# Install build machine and component package server pre-reqs

yum install -y git httpd
chkconfig httpd on

bash -c "echo '127.0.1.1 $(hostname)' | cat >> /etc/hosts"
cd /home/${OS_USER}

# Install build machine software
pnda/build/install-build-tools.sh << EOF
Yes
EOF

[[ $? -ne 0 ]] && mirror_error "Problem while installing build tools"

# Build PNDA software
source ${PWD}/set-pnda-env.sh
cd pnda/build
./build-pnda.sh $BUILD_MODE $BUILD_ARG $HADOOP_DISTRIBUTION << EOF
Yes
EOF

[[ $? -ne 0 ]] && mirror_error "Problem while building PNDA"

# Stage built PNDA components on HTTP server
echo "Before copying to http server home"
ls -lah /var/www/html/
ls -lah /home/${OS_USER}/pnda/build/pnda-dist/
mv /home/${OS_USER}/pnda/build/pnda-dist/* /var/www/html/

restorecon -r /var/www/html
sudo service httpd start

# cleaning up pnda
sudo rm -rf /home/${OS_USER}/pnda*
