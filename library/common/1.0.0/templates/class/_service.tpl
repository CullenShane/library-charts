{{/* Template for service object, can only be called by the spawner */}}
{{/* An "svc" object and "root" is passed from the spawner */}}
{{- define "ix.v1.common.class.service" -}}
  {{- $svcValues := .svc -}}
  {{- $root := .root -}}
  {{- $defaultServiceType := $root.Values.global.defaults.defaultServiceType -}}
  {{- $svcName := include "ix.v1.common.names.fullname" $root -}}

  {{- if and (hasKey $svcValues "nameOverride") $svcValues.nameOverride -}}
    {{- $svcName = (printf "%v-%v" $svcName $svcValues.nameOverride) -}}
  {{- end -}}

  {{- $svcType := $svcValues.type | default $defaultServiceType -}}
  {{- if $root.Values.hostNetwork -}}
    {{- $svcType = "ClusterIP" -}} {{/* When hostNetwork is enabled, force ClusterIP as service type */}}
  {{- end -}}
  {{- $primaryPort := get $svcValues.ports (include "ix.v1.common.lib.util.service.ports.primary" (dict "values" $svcValues "svcName" $svcName)) }}
---
apiVersion: {{ include "ix.v1.common.capabilities.service.apiVersion" $root }}
kind: Service
metadata:
  name: {{ $svcName }}
  {{- $labels := (mustMerge ($svcValues.labels | default dict) (include "ix.v1.common.labels" $root | fromYaml)) -}}
  {{- with (include "ix.v1.common.util.labels.render" (dict "root" $root "labels" $labels) | trim) }}
  labels:
    {{- . | nindent 4 }}
  {{- end }}
  {{- $additionalAnnotations := dict -}}
  {{- if and $root.Values.addAnnotations.traefik (eq ($primaryPort.protocol | default "") "HTTPS") }}
    {{- $_ := set $additionalAnnotations "traefik.ingress.kubernetes.io/service.serversscheme" "https" -}}
  {{- end -}}
  {{- if and $root.Values.addAnnotations.metallb (eq $svcType "LoadBalancer") }}
    {{- $_ := set $additionalAnnotations "metallb.universe.tf/allow-shared-ip" (include "ix.v1.common.names.fullname" $root) }}
  {{- end -}}
  {{- $annotations := (mustMerge ($svcValues.annotations | default dict) (include "ix.v1.common.annotations" $root | fromYaml) $additionalAnnotations) -}}
  {{- with (include "ix.v1.common.util.annotations.render" (dict "root" $root "annotations" $annotations) | trim) }}
  annotations:
    {{- . | nindent 4 }}
  {{- end }}
spec:
  {{- if eq $svcType "ClusterIP" -}}
    {{- include "ix.v1.common.class.serivce.clusterIP.spec" (dict "svc" $svcValues "root" $root) | nindent 2 -}}
  {{- else if eq $svcType "LoadBalancer" -}}
    {{- include "ix.v1.common.class.serivce.loadBalancer.spec" (dict "svc" $svcValues "root" $root)| nindent 2 -}}
  {{- else if eq $svcType "NodePort" -}}
    {{- include "ix.v1.common.class.serivce.nodePort.spec" (dict "svc" $svcValues "root" $root) | nindent 2 -}}
  {{- else if eq $svcType "ExternalName" -}}
    {{- include "ix.v1.common.class.serivce.externalName.spec" (dict "svc" $svcValues "root" $root) | nindent 2 -}}
  {{- end -}}
  {{- include "ix.v1.common.class.serivce.sessionAffinity" (dict "svc" $svcValues "root" $root) | indent 2 -}}
  {{- include "ix.v1.common.class.serivce.externalIPs" (dict "svc" $svcValues "root" $root) | indent 2 -}}
  {{- include "ix.v1.common.class.serivce.publishNotReadyAddresses" (dict "publishNotReadyAddresses" $svcValues.publishNotReadyAddresses) | indent 2 }}
  ports:
  {{- range $name, $port := $svcValues.ports }}
    {{- if $port.enabled }}
      {{- $protocol := "TCP" -}} {{/* Default to TCP if no protocol is specified */}}
      {{- with $port.protocol }}
        {{- if has . (list "HTTP" "HTTPS" "TCP") -}}
          {{- $protocol = "TCP" -}}
        {{- else -}}
          {{- $protocol = . -}}
        {{- end -}}
      {{- end }}
    - port: {{ $port.port }}
      name: {{ $name }}
      protocol: {{ $protocol }}
      targetPort: {{ $port.targetPort | default $name }}
      {{- if and (eq $svcType "NodePort") $port.nodePort }}
      nodePort: {{ $port.nodePort }}
      {{- end -}}
    {{- end -}}
  {{- end -}}
  {{- if not (has $svcType (list "ExternalName" "ExternalIP")) -}}
    {{- include "ix.v1.common.class.serivce.selector" (dict "svc" $svcValues "root" $root) | nindent 2 -}}
  {{- end -}}
  {{- if eq $svcType "ExternalIP" -}}
    {{- include "ix.v1.common.class.serivce.externalTrafficPolicy" (dict "svc" $svcValues "root" $root) | nindent 2 -}}
    {{- include "ix.v1.common.class.serivce.endpoints" (dict "svc" $svcValues "svcName" $svcName "root" $root) | nindent 0 -}}
  {{- end -}}
{{- end -}}
