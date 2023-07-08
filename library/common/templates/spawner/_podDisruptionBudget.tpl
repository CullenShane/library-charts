{{/* poddisruptionbudget Spawwner */}}
{{/* Call this template:
{{ include "tc.v1.common.spawner.poddisruptionbudget" $ -}}
*/}}

{{- define "tc.v1.common.spawner.poddisruptionbudget" -}}

  {{- range $name, $poddisruptionbudget := .Values.poddisruptionbudget -}}

    {{- $enabled := false -}}
    {{- if hasKey $poddisruptionbudget "enabled" -}}
      {{- if not (kindIs "invalid" $poddisruptionbudget.enabled) -}}
        {{- $enabled = $poddisruptionbudget.enabled -}}
      {{- else -}}
        {{- fail (printf "poddisruptionbudget - Expected the defined key [enabled] in <poddisruptionbudget.%s> to not be empty" $name) -}}
      {{- end -}}
    {{- end -}}


    {{- if kindIs "string" $enabled -}}
      {{- $enabled = tpl $enabled $ -}}

      {{/* After tpl it becomes a string, not a bool */}}
      {{-  if eq $enabled "true" -}}
        {{- $enabled = true -}}
      {{- else if eq $enabled "false" -}}
        {{- $enabled = false -}}
      {{- end -}}
    {{- end -}}

    {{- if $enabled -}}

      {{/* Create a copy of the poddisruptionbudget */}}
      {{- $objectData := (mustDeepCopy $poddisruptionbudget) -}}

      {{- $objectName := (printf "%s-%s" (include "tc.v1.common.lib.chart.names.fullname" $) $name) -}}
      {{- if hasKey $objectData "expandObjectName" -}}
        {{- if not $objectData.expandObjectName -}}
          {{- $objectName = $name -}}
        {{- end -}}
      {{- end -}}

      {{/* Perform validations */}}
      {{- include "tc.v1.common.lib.chart.names.validation" (dict "name" $objectName) -}}
      {{- include "tc.v1.common.lib.poddisruptionbudget.validation" (dict "objectData" $objectData) -}}
      {{- include "tc.v1.common.lib.metadata.validation" (dict "objectData" $objectData "caller" "poddisruptionbudget") -}}

      {{/* Set the name of the poddisruptionbudget */}}
      {{- $_ := set $objectData "name" $objectName -}}
      {{- $_ := set $objectData "shortName" $name -}}

      {{/* Call class to create the object */}}
      {{- include "tc.v1.common.class.poddisruptionbudget" (dict "rootCtx" $ "objectData" $objectData) -}}

    {{- end -}}

  {{- end -}}

{{- end -}}
