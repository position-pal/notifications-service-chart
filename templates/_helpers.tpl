{{- define "postgresql.waitForDatabase" -}}
initContainers:
  - name: wait-for-postgresql
    image: bitnami/postgresql:latest
    command:
      - /bin/bash
      - -ec
      - |
        until PGPASSWORD="${POSTGRES_PASSWORD}" psql -h "${POSTGRES_HOST}" -U "${POSTGRES_USER}" -d "${POSTGRES_DB}" -c "SELECT 1"; do
          echo "Waiting for PostgreSQL to be ready..."
          sleep 2
        done
        echo "PostgreSQL is ready!"
    env:
      - name: POSTGRES_HOST
        value: {{ .Release.Name }}-postgresql
      - name: POSTGRES_DB
        value: {{ .Values.postgresql.global.postgresql.auth.database | quote }}
      - name: POSTGRES_USER
        value: {{ .Values.postgresql.global.postgresql.auth.username | quote }}
      - name: POSTGRES_PASSWORD
        valueFrom:
            secretKeyRef:
                name: {{ .Release.Name }}-postgresql
                key: password
{{- end -}}

{{- define "notifications-service.env" -}}
- name: FIREBASE_SERVICE_ACCOUNT_FILE_PATH
  value: /etc/firebase/service-account.json
- name: POSTGRES_HOST
  value: {{ .Release.Name }}-postgresql
- name: POSTGRES_PORT
  value: {{ .Values.postgresql.port | quote }}
- name: POSTGRES_USERNAME
  value: {{ .Values.postgresql.global.postgresql.auth.username | quote }}
- name: POSTGRES_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .Release.Name }}-postgresql
      key: password
- name: RABBITMQ_VIRTUAL_HOST
  value: {{ .Values.rabbitmq.virtualHost | quote }}
- name: RABBITMQ_HOST
  value: "{{ .Values.rabbitmq.serviceName }}.{{ .Values.rabbitmq.namespace }}.svc.cluster.local"
- name: RABBITMQ_PORT
  value: {{ .Values.rabbitmq.port | quote }}
- name: RABBITMQ_USERNAME
  value: {{ .Values.rabbitmq.username | quote }}
- name: RABBITMQ_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .Release.Name }}-notification-service-secrets
      key: rabbitmq-password

- name: GRPC_PORT
  value: {{ .Values.grpcPort | quote }}
{{- end -}}

{{- define "notifications-service.labels" -}}
app: notifications-service
release: {{ .Release.Name }}
{{- end -}}