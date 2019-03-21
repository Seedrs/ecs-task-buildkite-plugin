# ECS Task Buildkite Plugin

A [Buildkite plugin](https://buildkite.com/docs/agent/plugins) to run ECS tasks.

Credentials for the command need to be added to the environment. You can use
another plugin to assume a specifc role (e.g [aws-assume-role-buildkite-plugin](https://github.com/Seedrs/aws-assume-role-buildkite-plugin))

This plugin will run a task in an ECS cluster. It abstracts the following command.

```bash
aws ecs run-task \
      --cluster <cluster-name> \
      --task-definition <task-definition-name>
```

## Example

```yml
steps:
  - plugins:
      - seedrs/ecs-task#v0.1.0:
          cluster: "production-cluster-name"
          task: "production-task-name"
```

## Options

### `cluster`

The name of the ECS cluster.

### `task`

The task name you which to run.

### `region` (optional)

The AWS region where the service is deployed. It defaults to `eu-west-1`.
Alternatively, you could specify `AWS_DEFAULT_REGION` in your environment.

## Developing

To run the tests:

```bash
docker-compose run --rm tests
```

## License

MIT (see [LICENSE](LICENSE))
