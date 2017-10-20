{{- define "environment" -}}
- name: REDIS_HOST
  value: "mastodon-redis.default.svc.cluster.local"
- name: REDIS_PORT
  value: "6379"
- name: DB_HOST
  value: "192.168.131.1"
- name: DB_USER
  valueFrom:
    secretKeyRef:
      name: "mastodon-postgres-user"
      key: user
- name: DB_PASS
  valueFrom:
    secretKeyRef:
      name: "mastodon-postgres-user"
      key: password
- name: DB_NAME
  value: "mastodon"
- name: LOCAL_DOMAIN
  value: "wobscale.social"
- name: SMTP_FROM_ADDRESS
  value: noreply@ses.wobscale.com
- name: SMTP_SERVER
  value: email-smtp.us-west-2.amazonaws.com
- name: SMTP_PORT
  value: "587"
- name: SMTP_LOGIN
  value: {{ .Values.mastodon.smtp.user }}
- name: SMTP_PASSWORD
  value: {{ .Values.mastodon.smtp.password }}
- name: LOCAL_HTTPS
  value: "true"
- name: SINGLE_USER_MODE
  value: "false"
- name: SECRET_KEY_BASE
  valueFrom:
    secretKeyRef:
      name: mastodon-secrets
      key: secretKeyBase
- name: OTP_SECRET
  valueFrom:
    secretKeyRef:
      name: mastodon-secrets
      key: otpSecret
- name: PAPERCLIP_SECRET
  valueFrom:
    secretKeyRef:
      name: mastodon-secrets
      key: paperclipSecret
- name: VAPID_PUBLIC_KEY
  valueFrom:
    secretKeyRef:
      name: mastodon-secrets
      key: vapidPublicKey
- name: VAPID_PRIVATE_KEY
  valueFrom:
    secretKeyRef:
      name: mastodon-secrets
      key: vapidPrivateKey
{{- end -}}
