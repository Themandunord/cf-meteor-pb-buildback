#!/bin/bash

cp manifest.yml deploy/
cd deploy
chmod -R 744 .

cf push
