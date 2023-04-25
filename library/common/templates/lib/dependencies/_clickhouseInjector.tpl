{{/*
  This template generates a random password and ensures it persists across updates/edits to the chart
*/}}
{{- define "tc.v1.common.dependencies.clickhouse.secret" -}}
{{- $dbHost := printf "%v-%v" .Release.Name "clickhouse" -}}

{{- if .Values.clickhouse.enabled -}}
  {{/* Initialize variables */}}
  {{- $basename := include "tc.v1.common.lib.chart.names.fullname" $ -}}
  {{- $fetchname := printf "%s-clickhousecreds" $basename -}}
  {{- $dbprevious := lookup "v1" "Secret" .Release.Namespace $fetchname -}}
  {{- $dbpreviousold := lookup "v1" "Secret" .Release.Namespace "clickhousecreds" -}}
  {{- $dbPass := randAlphaNum 50 -}}

  {{/* If there are previous secrets, fetch values and decrypt them */}}
  {{- if $dbprevious -}}
    {{- $dbPass = (index $dbprevious.data "clickhouse-password") | b64dec -}}
  {{- else if $dbpreviousold -}}
    {{- $dbPass = (index $dbpreviousold.data "clickhouse-password") | b64dec -}}
  {{- end -}}

  {{/* Prepare data */}}
  {{- $portHost := printf "%v:8123" $dbHost -}}
  {{- $ping := printf"http://%v/ping" $portHost -}}
  {{- $url := printf "http://%v:%v@%v/%v" .Values.clickhouse.clickhouseUsername $dbPass $portHost .Values.clickhouse.clickhouseDatabase -}}
  {{- $jdbc := printf "jdbc:ch://%v/%v" $$portHost -}}

  {{/* Append some values to mariadb.creds, so apps using the dep, can use them */}}
  {{- $_ := set .Values.clickhouse.creds "plain" ($dbHost | quote) -}}
  {{- $_ := set .Values.clickhouse.creds "plainhost" ($dbHost | quote) -}}
  {{- $_ := set .Values.clickhouse.creds "clickhousePassword" ($dbPass | quote) -}}
  {{- $_ := set .Values.clickhouse.creds "plainport" ($portHost | quote) -}}
  {{- $_ := set .Values.clickhouse.creds "plainporthost" ($portHost | quote) -}}
  {{- $_ := set .Values.clickhouse.creds "ping" ($ping | quote) -}}
  {{- $_ := set .Values.clickhouse.creds "complete" ($url | quote) -}}
  {{- $_ := set .Values.clickhouse.creds "jdbc" ($jdbc | quote) -}}

{{/* Create the secret (Comment also plays a role on correct formatting) */}}
enabled: true
expandObjectName: false
data:
  clickhouse-password: {{ $dbPass }}
  plainhost: {{ $dbHost }}
  plainporthost: {{ $portHost }}
  ping: {{ $ping }}
  url: {{ $url }}
  jdbc: {{ $jdbc }}
  {{- end -}}
{{- end -}}

{{- define "tc.v1.common.dependencies.clickhouse.injector" -}}
  {{- $secret := include "tc.v1.common.dependencies.clickhouse.secret" . | fromYaml -}}
  {{- if $secret -}}
    {{- $_ := set .Values.secret ( printf "%s-%s" .Release.Name "clickhousecreds" ) $secret -}}
  {{- end -}}
{{- end -}}
