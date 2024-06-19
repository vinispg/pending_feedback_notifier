#!/bin/bash
cd /path/to/redmine
/usr/local/bin/bundle exec rake send_feedback_reminders:send RAILS_ENV=production