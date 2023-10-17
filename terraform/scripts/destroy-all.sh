#!/usr/bin/env bash

# Destroys all stacks in the correct order
ROOT_DIR=$(git rev-parse --show-toplevel)
STACKS_DIR="${ROOT_DIR}/terraform/stacks"

(cd "${STACKS_DIR}/data-ingestion" && terraform destroy -auto-approve)
(cd "${STACKS_DIR}/data-storage/s3" && terraform destroy -auto-approve)
(cd "${STACKS_DIR}/data-storage/mysql" && terraform destroy -auto-approve)
(cd "${STACKS_DIR}/network" && terraform destroy -auto-approve)