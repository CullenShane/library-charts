{{- define "tc.v1.common.lib.util.operator.verifyAll" -}}
  {{- if .Values.operator.verify.enabled -}}
    {{/* Go over all operators that need to be verified */}}
    {{- range $opName := .Values.operator.verify.additionalOperators -}}
      {{- $opExists := include "tc.v1.common.lib.util.operator.verify" (dict "rootCtx" $ "opName" $opName) -}}

      {{/* If the operator was not found */}}
      {{- if eq $opExists "false" -}}
        {{- fail (printf "Operator [%s] needs to be installed" $opName) -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{- define "tc.v1.common.lib.util.operator.verify" -}}
  {{- $rootCtx := .rootCtx -}}
  {{- $opName := .opName -}}
  {{- $opExists := false -}}

  {{/* Go over all configmaps */}}
  {{- range $index, $cm := (lookup "v1" "ConfigMap" "" "").items -}}
    {{/* Go over all keys under data on the configmap */}}
    {{- range $key, $value := $cm.data -}}
      {{/* If the key is "tc-operator-name */}}
      {{- if eq $key "tc-operator-name" -}}
        {{/* And it has value the value of the operator we trying to verify */}}
        {{- if eq $value $opName -}}
          {{/* Mark operator as found*/}}
          {{- $opExists = true -}}
        {{- end -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}

  {{/* Return the status stringified */}}
  {{- $opExists | toString -}}
{{- end -}}
