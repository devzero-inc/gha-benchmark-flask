#! /bin/bash

# Clone pallets/flask
git clone https://github.com/pallets/flask.git --depth=1

# Create workflows directory if it doesn't exist
mkdir -p .github/workflows/


# Copy the workflow
cp temp-flask/.github/workflows/tests.yml .github/workflows/benchmark.yml

# Modify with yq
yq -P -i '.on = {"workflow_dispatch": {}, "schedule": [{"cron": "15 */12 * * *"}]}' .github/workflows/benchmark.yml
yq -P -i '(.jobs.* | select(.strategy == null)).strategy.matrix.os = ["ubuntu-24.04", "devzero-ubuntu-24.04"]' .github/workflows/benchmark.yml
yq -P -i '(.jobs.* | select(.strategy != null)).strategy.matrix.os = ["ubuntu-24.04", "devzero-ubuntu-24.04"]' .github/workflows/benchmark.yml
yq -P -i '.jobs.*.runs-on = "${{ matrix.os }}"' .github/workflows/benchmark.yml
yq -P -i '(.jobs.*.steps.[] | select(.uses == "actions/checkout@v4").with.repository) = "pallets/flask"' .github/workflows/benchmark.yml
yq -P -i '(.jobs.*.steps.[] | select(.uses == "actions/checkout@v4").with.ref) = "main"' .github/workflows/benchmark.yml
yq -P -i '(.jobs.*.steps.[] | select(.uses == "actions/checkout@v3").with.repository) = "pallets/flask"' .github/workflows/benchmark.yml
yq -P -i '(.jobs.*.steps.[] | select(.uses == "actions/checkout@v3").with.ref) = "main"' .github/workflows/benchmark.yml

# Clean up
rm -rf temp-flask

# Configure git and commit
git config --local user.email "$1"
git config --local user.name "$2"
git remote set-url origin https://$GHA_BENCHMARK@github.com/devzero-inc/gha-benchmark-flask.git
git add .github/workflows/benchmark.yml
git commit -m "Setup flask tests workflow" || echo "No changes to commit"
git push origin main
