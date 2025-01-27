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