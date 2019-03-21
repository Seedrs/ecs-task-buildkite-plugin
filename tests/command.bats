#!/usr/bin/env bats

load "$BATS_PATH/load.bash"

# Uncomment to enable stub debugging
#export AWS_STUB_DEBUG=/dev/tty
#export JQ_STUB_DEBUG=/dev/tty

@test "runs a task and waits for desired state" {
  export BUILDKITE_PLUGIN_ECS_TASK_CLUSTER="my-cluster"
  export BUILDKITE_PLUGIN_ECS_TASK_TASK="my-task-name"
  export BUILDKITE_PLUGIN_ECS_TASK_REGION="eu-west-1"

  stub aws \
    "ecs run-task --region \"eu-west-1\" --cluster \"my-cluster\" --task-definition \"my-task-name\" --query \"{failures: failures, taskArn: tasks[0].taskArn}\" : cat tests/response.json" \
    "ecs wait tasks-stopped --cluster \"my-cluster\" --tasks \"my-task-arn\" : echo ok" \
    "ecs describe-tasks --cluster \"my-cluster\" --tasks \"my-task-arn\" --query \"tasks[0].containers[0].exitCode\" --output text --region \"eu-west-1\" : echo 0"

  stub jq \
    "-r \".taskArn\" : echo \"my-task-arn\""

  run $PWD/hooks/command

  assert_output --partial "--- Running :amazon-ecs: task [my-task-name] in cluster [my-cluster]"
  assert_output --partial "--- Waiting :amazon-ecs: task to be stopped"
  assert_output --partial "--- Success :amazon-ecs: task was executed successfully"

  assert_success
  unstub aws
  unstub jq
}

@test "task could not be allocated" {
  export BUILDKITE_PLUGIN_ECS_TASK_CLUSTER="my-cluster"
  export BUILDKITE_PLUGIN_ECS_TASK_TASK="my-task-name"
  export BUILDKITE_PLUGIN_ECS_TASK_REGION="eu-west-1"

  stub aws \
    "ecs run-task --region \"eu-west-1\" --cluster \"my-cluster\" --task-definition \"my-task-name\" --query \"{failures: failures, taskArn: tasks[0].taskArn}\" : cat tests/response.json"

  stub jq \
    "-r \".taskArn\" : echo \"null\""

  run $PWD/hooks/command

  assert_output --partial "--- Running :amazon-ecs: task [my-task-name] in cluster [my-cluster]"
  assert_output --partial "--- Error   :amazon-ecs: task [my-task-name] in cluster [my-cluster] could not be allocated"

  assert_failure
  unstub aws
}

@test "missing required parameters" {
  run $PWD/hooks/command

  assert_output --partial "Missing BUILDKITE_PLUGIN_ECS_TASK_CLUSTER or BUILDKITE_PLUGIN_ECS_TASK_TASK"
}
