#!/bin/bash
source settings.conf

cd $code_path
rm -f $code_path/mastodon
git clone $git_url
#cp  $code_path/settings.conf $code_path/mastodon/settings.conf
