# Service Account

## Key: rbac

- Type: `dict`
- Default:

  ```yaml
  serviceAccount:
    main:
      enabled: false
      primary: true
  ```

- Helm Template: ❌

For every `serviceAccount.NAME` that is enabled it will
create a `ServiceAccount` object.

`primary` flag is used to decide what `serviceAccountName`
will be assigned to the pod. Without a `ServiceAccount`,
the `serviceAccountName` will be `default` .

Examples:

```yaml
serviceAccount:
  main:
    enabled: true
    primary: true
    labels:
      key: value
    annotations:
      key: value
```

Kubernetes Documentation:

- [Service Account](https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account)
