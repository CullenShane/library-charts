{{/* poddisruptionbudget Class */}}
{{/* Call this template:
{{ include "tc.v1.common.class.poddisruptionbudget" (dict "rootCtx" $ "objectData" $objectData) }}

rootCtx: The root context of the chart.
objectData:
  name: The name of the poddisruptionbudget.
  labels: The labels of the poddisruptionbudget.
  annotations: The annotations of the poddisruptionbudget.
  data: The data of the poddisruptionbudget.
  namespace: The namespace of the poddisruptionbudget. (Optional)
*/}}

{{- define "tc.v1.common.class.poddisruptionbudget" -}}

  {{- $rootCtx := .rootCtx -}}
  {{- $objectData := .objectData }}
---
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: {{ $objectData.name }}
  {{- $labels := (mustMerge ($objectData.labels | default dict) (include "tc.v1.common.lib.metadata.allLabels" $rootCtx | fromYaml)) -}}
  {{- with (include "tc.v1.common.lib.metadata.render" (dict "rootCtx" $rootCtx "labels" $labels) | trim) }}
  labels:
    {{- . | nindent 4 }}
  {{- end -}}
  {{- $annotations := (mustMerge ($objectData.annotations | default dict) (include "tc.v1.common.lib.metadata.allAnnotations" $rootCtx | fromYaml)) -}}
  {{- with (include "tc.v1.common.lib.metadata.render" (dict "rootCtx" $rootCtx "annotations" $annotations) | trim) }}
  annotations:
    {{- . | nindent 4 }}
  {{- end -}}
  {{- with $objectData.namespace }}
  namespace: {{ tpl . $rootCtx }}
  {{- end }}
data:
  selector:
    {{- if $objectData.selector }}
    {{- tpl (toYaml $objectData.selector) $ | nindent 4 }}
    {{- else }}
    {{- $objectData := dict "targetSelector" $objectData.targetSelector }}
    {{- $selectedPod := fromYaml ( include "tc.v1.common.lib.helpers.getSelectedPodValues" (dict "rootCtx" $rootCtx "objectData" $objectData)) }}
    {{- $selectedPodName := $selectedPod.shortName }}
    matchLabels:
      {{- include "tc.v1.common.lib.metadata.selectorLabels" (dict "rootCtx" $ "objectType" "pod" "objectName" $selectedPodName) | indent 6 }}
    {{- end }}
  {{- with $objectData.minAvailable }}
  minAvailable: {{ . }}
  {{- end }}
  {{- with $objectData.maxUnavailable }}
  maxUnavailable: {{ . }}
  {{- end }}
{{- end -}}
