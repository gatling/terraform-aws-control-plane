# Changes

* `ecr_policy`, `asm_policy` and `cloudwatch_logs_policy` are now correctly attached to a dedicated ECS execution role, separate from the task role.
* Fix validation when private-package is not needed.
