#!/bin/bash
cd /usr/src/redmine

export PATH=$PATH:/usr/local/bundle/bin

bundle exec rake send_feedback_reminders:send RAILS_ENV=production
