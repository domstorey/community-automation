#!/bin/bash

# bash best practices
set -o errexit
set -o nounset
set -o pipefail

source scripts/common/rhel8-functions.sh

[[ -f /etc/redhat-release ]] && [[ $(grep '8.' /etc/redhat-release) ]] && rhel8_support $@ || true

repo_dir="$(pwd)"
play_dir=/tmp/community-automation/ansible/prereq-play
container_name="community_auto_bash"
# start docker container and pass environment variables
docker run --name "$container_name" -v "$repo_dir":/tmp/community-automation -i -t -d ubuntu:latest sleep 120m

# install pre-reqs
docker exec -it "$container_name" bash -c "apt -y update; apt -y install python3 python3-pip git curl wget sudo jq gpg vim; pip3 install --upgrade pip; pip3 install ansible"
docker exec -it "$container_name" bash -c "ansible-galaxy collection install -r $play_dir/requirements.yml"
docker exec -it "$container_name" bash -c "ansible-playbook -i $play_dir/inventory $play_dir/prereq-play.yml"

# open docker container to execute plays
docker exec -it "$container_name" bash

echo "When you exit from docker conatiner $container_name, here is how to stop the container"
echo "docker stop $container_name"
