#!/bin/bash

BUILD_DIR=.
CACHE_DIR=/home/pipeline/.cache
METEOR_HOME=$BUILD_DIR/.meteor/local
PATH=$METEOR_HOME/usr/bin:$METEOR_HOME/usr/lib/meteor/bin:$PATH

status() {
  echo "-----> $*"
}

install_meteor() {

  if [ -f "/home/pipeline/.cache/.meteor/meteor" ] ; then
    status "Meteor installation. Already installed."
    #return
  fi

  # Download node from Heroku's S3 mirror of nodejs.org/dist
  status "Downloading meteor"
  METEOR_INSTALL_SCRIPT=install_meteor.sh
  METEOR_URL="https://install.meteor.com/"
  curl $METEOR_URL > $METEOR_INSTALL_SCRIPT

  status "Downloading meteor"
  sed -e '/^#!\/bin\/sh/ s/$/ -x/' \
      -e 's/set -/#set -/' \
      -e 's/curl --progress-bar  --fail.*/curl "$TARBALL_URL" > meteor-bundle.tgz; tar -xzf meteor-bundle.tgz -C "$INSTALL_TMPDIR" -o/' \
  $METEOR_INSTALL_SCRIPT > install-meteor-verbose.sh
  chmod +x install-meteor-verbose.sh

  status "Execute ./install-meteor-verbose.sh"
  ./install-meteor-verbose.sh
  status "Done"

  status "updating PATH for meteor"
  PATH=$HOME/.meteor:$PATH

}

install_yarn() {
  if [ -f "$PROJECT_DIR/.vendor/yarn/bin/yarn" ] ; then
    status "Skipping Yarn installation. Already installed."
    return
  fi

  # Download yarn from yarn mirror
  status "Downloading and installing yarn $YARN_VERSION"
  YARN_INSTALLER="yarn-v$YARN_VERSION.tar.gz"
  YARN_URL="https://yarnpkg.com/downloads/$YARN_VERSION/$YARN_INSTALLER"
  local code=$(curl "$YARN_URL" -L --silent --fail --retry 5 --retry-max-time 15 -o /tmp/yarn.tar.gz --write-out "%{http_code}")
  if [ "$code" != "200" ]; then
    echo "Unable to download yarn: $code" && false
  fi

  mkdir -p $PROJECT_DIR/yarn

  if tar --version | grep -q 'gnu'; then
    tar xzf /tmp/yarn.tar.gz -C "$PROJECT_DIR/yarn" --strip 1 --warning=no-unknown-keyword
  else
    tar xzf /tmp/yarn.tar.gz -C "$PROJECT_DIR/yarn" --strip 1
  fi

  # Move yarn into ./.vendor and make them executable
  mkdir -p $PROJECT_DIR/.vendor
  mv $PROJECT_DIR/yarn $PROJECT_DIR/.vendor/yarn
  chmod +x $PROJECT_DIR/.vendor/yarn/bin/*
  PATH=$PROJECT_DIR/.vendor/yarn/bin:$PATH

  status "Installed yarn $(yarn --version)"
}


build() {
  (
    cd $BUILD_DIR

    status "installing needed modules"
    meteor npm install --save babel-runtime cookies-js moment linkifyjs
    meteor npm install --save postcss-cli autoprefixer

    status "building the application"
    meteor build --directory $BUILD_DIR/deploy --server http://localhost:3000
  )
}

install_meteor
build
