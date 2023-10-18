#!/usr/bin/env bash

# Creates all stacks in the correct order
ROOT_DIR=$(git rev-parse --show-toplevel)
STACKS_DIR="${ROOT_DIR}/terraform/stacks"

(cd "${STACKS_DIR}/network" && terraform apply -auto-approve)
(cd "${STACKS_DIR}/data-storage/s3" && terraform apply -auto-approve)
(cd "${STACKS_DIR}/data-storage/mysql" && terraform apply -auto-approve)
(cd "${STACKS_DIR}/data-ingestion" && terraform apply -auto-approve)
