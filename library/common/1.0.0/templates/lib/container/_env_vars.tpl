{{/*
A custom dict is expected with envs and root.
It's designed to work for mainContainer AND initContainers.
Calling this from an initContainer, wouldn't work, as it would have a different "root" context,
and "tpl" on "$" would cause erors.
That's why the custom dict is expected.
*/}}
{{/* Environment Variables included by the container */}}
{{- define "ix.v1.common.container.envVars" -}}
  {{- $envs := .envs -}}
  {{- $envList := .envList -}}
  {{- $root := .root -}}
  {{- $fixedEnv := list -}}
  {{- if $root.Values.injectFixedEnvs -}}
    {{- $fixedEnv = (include "ix.v1.common.container.fixedEnvs" (dict "root" $root "fixedEnv" $fixedEnv )) -}}
  {{- end -}} {{/* Finish fixedEnv */}}
  {{- with $fixedEnv -}}
    {{- range $fixedEnv | fromJsonArray }} {{/* "fromJsonArray" parses stringified output and convet to list */}}
- name: {{ .name | quote }}
  value: {{ .value | quote }}
    {{- end -}}
  {{- end -}}
  {{- include "ix.v1.common.container.env" (dict "envs" $envs "root" $root "fixedEnv" $fixedEnv) -}}
  {{- include "ix.v1.common.container.envList" (dict "envList" $envList "envs" $envs "root" $root "fixedEnv" $fixedEnv) -}}
{{- end -}}

{{/* Note: It's does not check for dupes in configmap/secrets. */}}
