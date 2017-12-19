#!/bin/bash

travis encrypt GPG_PASSPHRASE=$GPG_PASSPHRASE -a
travis encrypt GITHUB_TOKEN=$GITHUB_TOKEN -a
