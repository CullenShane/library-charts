{{/* The main container included in the controller */}}
{{/*
The "tpl (toYaml somepath) $" is used to expand template content (if any)
Cases like this are when we set these values on another tpl file with template

On some includes we pass a dict with the "root" and some other values.
This is because this named function relies on those two, to specify it's context.
So it can work on multiple places, like additional containers and not only the main container.
*/}}
{{- define "ix.v1.common.controller.mainContainer" -}}
- name: {{ include "ix.v1.common.names.fullname" . }}
  image: {{ include "ix.v1.common.images.selector" (dict "root" . "selectedImage" .Values.imageSelector ) }}
  imagePullPolicy: {{ include "ix.v1.common.images.pullPolicy" (dict "policy" .Values.image.pullPolicy) }}
  tty: {{ .Values.tty }}
  stdin: {{ .Values.stdin }}
  {{- with (include "ix.v1.common.container.command" (dict "commands" .Values.command "root" $)) | trim }}
  command:
    {{- . | nindent 4 }}
  {{- end -}}
  {{- with (include "ix.v1.common.container.args" (dict "args" .Values.args "extraArgs" .Values.extraArgs "root" $)) | trim }}
  args:
    {{- . | nindent 4 }}
  {{- end -}}
  {{- with (include "ix.v1.common.container.securityContext" (dict "secCont" .Values.securityContext "podSecCont" .Values.podSecurityContext "root" $)) | trim }}
  securityContext:
    {{- . | nindent 4 }}
  {{- end -}}
  {{- with (include "ix.v1.common.container.lifecycle" (dict "lifecycle" .Values.lifecycle "root" $)) | trim }}
  lifecycle:
    {{- . | nindent 4 }}
  {{- end }}
  {{- with (include "ix.v1.common.container.termination.messagePath" (dict "msgPath" .Values.termination.messagePath "root" $)) | trim }}
  terminationMessagePath: {{ . }}
  {{- end }}
  {{- with (include "ix.v1.common.container.termination.messagePolicy" (dict "msgPolicy" .Values.termination.messagePolicy "root" $)) | trim }}
  terminationMessagePolicy: {{ . }}
  {{- end -}}
  {{- with (include "ix.v1.common.container.envVars" (dict "envs" .Values.env "envList" .Values.envList "root" $) | trim) }}
  env:
    {{- . | nindent 4 }} {{/* env and envList */}}
  {{- end -}}
  {{- with (include "ix.v1.common.container.envFrom" (dict "envFrom" .Values.envFrom "root" $) | trim) }}
  envFrom:
    {{- . | nindent 4 }}
  {{- end -}}
  {{- with (include "ix.v1.common.container.ports" . | trim) }}
  ports:
    {{- . | nindent 4 }}
  {{- end -}}
  {{- with (include "ix.v1.common.container.volumeMounts" . | trim) }}
  volumeMounts:
    {{- . | nindent 4 }}
  {{- end -}}
  {{- with (include "ix.v1.common.container.probes" . | trim) }}
    {{- . | nindent 2 }}
  {{- end -}}
  {{- with (include "ix.v1.common.container.resources" (dict "resources" .Values.resources "gpu" .Values.scaleGPU) | trim) }}
  resources:
    {{- . | nindent 4 }}
  {{- end -}}
{{- end -}}
