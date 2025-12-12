#!/bin/bash
set -euo pipefail

echo "Entry point script running"

CONFIG_FILE=_config.yml

manage_gemfile_lock() {
    git config --global --add safe.directory '*'
    echo "Keeping Gemfile.lock untouched"
}

start_jekyll() {
    manage_gemfile_lock

    echo "Ensuring gems are installed..."
    bundle install

    echo "Starting Jekyll..."
    bundle exec jekyll serve \
        --watch \
        --port=8080 \
        --host=0.0.0.0 \
        --livereload \
        --verbose \
        --trace \
        --force_polling &
}

start_jekyll

# Auto-reload logic remains
while true; do
    inotifywait -q -e modify,move,create,delete $CONFIG_FILE
    if [ $? -eq 0 ]; then
        echo "Change detected in $CONFIG_FILE, restarting Jekyll"
        jekyll_pid=$(pgrep -f jekyll)
        kill -KILL $jekyll_pid
        start_jekyll
    fi
done
