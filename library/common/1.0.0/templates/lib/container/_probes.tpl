{{/* Probes selection logic included by the container. */}}
{{- define "ix.v1.common.container.probes" -}}
  {{- $primarySeriviceName := (include "ix.v1.common.lib.util.service.primary" .) -}}  {{/* Get the name of the primary service, if any */}}
  {{- $primaryService := get .Values.service $primarySeriviceName -}} {{/* Get service values of the primary service, if any */}}
  {{- $primaryPort := "" -}}
  {{- $defaultProbeType := .Values.global.defaults.defaultProbeType -}}

  {{- if $primaryService -}}
    {{- $primaryPort = get $primaryService.ports (include "ix.v1.common.lib.util.service.ports.primary" (dict "values" $primaryService "svcName" $primarySeriviceName)) -}}
  {{- end -}}

  {{- range $probeName, $probe := .Values.probes -}}
      {{- if not (has $probeName (list "liveness" "readiness" "startup")) -}}
        {{- fail (printf "Invalid probe name (%s). Valid options are (liveness, readiness, startup)" $probeName) -}}
      {{- end -}}
    {{- $probeType := "" -}}
    {{- if $probe.enabled -}}
      {{- if $probe.custom -}}
        {{ $probeType = "CUSTOM" }}
      {{- else if eq $probe.type "EXEC" -}}
        {{ $probeType = "EXEC" }}
      {{- else -}}
        {{- if and $primaryService $primaryPort -}}
          {{- if $probe.type -}}
            {{- if eq $probe.type "AUTO" -}} {{/* Get probeType based on the service protocol */}}
              {{- $probeType = $primaryPort.protocol -}}
            {{- else -}}
              {{- if not (has $probe.type (list "TCP" "HTTP" "HTTPS" "GRPC")) -}} {{/* Make sure there is a valid probe type defined */}}
                {{- fail (printf "Invalid probe type (%s) on probe (%s). Valid types are TCP, HTTP, HTTPS, GRPC, EXEC" $probe.type $probeName) -}}
              {{- end -}}
              {{- $probeType = $probe.type -}}
            {{- end -}}
          {{- else -}} {{/* Fail back to defaultProbeType if no type is defined */}}
            {{- $probeType := $defaultProbeType -}}
          {{- end -}}
        {{- else -}}
          {{- fail (printf "Only custom probes are allowed when service is disabled (%s)" $probeName) -}}
        {{- end -}}
      {{- end -}}

      {{- $probePort := $primaryPort.port -}}
      {{- if $probe.port -}}
        {{- $probePort = (tpl ($probe.port | toString) $) -}}
      {{- else if $primaryPort.targetPort -}}
        {{- $probePort = $primaryPort.targetPort -}}
      {{- end -}}

      {{- $tmpProbe := dict -}}{{/* Prepare a temp Probe to pass in the probe definition function */}}
      {{- $_ := set $tmpProbe "name" $probeName -}}
      {{- $_ := set $tmpProbe "spec" $probe.spec -}}
      {{- $_ := set $tmpProbe "type" $probeType -}}
      {{- $_ := set $tmpProbe "port" $probePort }}
{{ $probeName }}Probe:
      {{- if has $probeType (list "HTTPS" "HTTP") -}}
        {{- $_ := set $tmpProbe "path" $probe.path -}}
        {{- $_ := set $tmpProbe "httpHeaders" $probe.httpHeaders -}}
        {{- include "ix.v1.common.container.probes.httpGet" (dict "probe" $tmpProbe "root" $) | trim | nindent 2 }}
      {{- else if (eq $probeType "TCP") -}}
        {{- include "ix.v1.common.container.probes.tcp" (dict "probe" $tmpProbe "root" $) | trim | nindent 2 }}
      {{- else if (eq $probeType "GRPC") -}}
        {{- include "ix.v1.common.container.probes.grpc" (dict "probe" $tmpProbe "root" $) | trim | nindent 2 }}
      {{- else if (eq $probeType "EXEC") -}}
        {{- $_ := set $tmpProbe "command" $probe.command -}}
        {{- include "ix.v1.common.container.probes.exec" (dict "probe" $tmpProbe "root" $) | trim | nindent 2 }}
      {{- else if (eq $probeType "CUSTOM") -}}
        {{- include "ix.v1.common.container.probes.custom" (dict "probe" $tmpProbe "root" $) | trim | nindent 2 }}
      {{- else if (eq $probeType "UDP") -}}
        {{- include "ix.v1.common.container.probes.udp" (dict "probe" $tmpProbe "root" $) | trim | nindent 2 }}
      {{- end -}}

    {{- end -}}
  {{- end -}}
{{- end -}}
