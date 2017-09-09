#!/bin/bash -xe
exec bundle exec puma -p $PORT -w 4:16
