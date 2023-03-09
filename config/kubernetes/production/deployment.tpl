apiVersion: apps/v1
kind: Deployment
metadata:
  name: find-unclaimed-court-money
spec:
  replicas: 4
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 100%
      maxUnavailable: 50%
  selector:
    matchLabels:
      app: find-unclaimed-court-money
  template:
    metadata:
      labels:
        app: find-unclaimed-court-money
    spec:
      containers:
        - name: webapp
          imagePullPolicy: Always
          image: ${ECR_URL}:${IMAGE_TAG}
          ports:
            - containerPort: 3000
          command: ["./config/docker/entrypoint-webapp.sh"]
          env:
            - name: DATABASE_URL
              valueFrom:
                secretKeyRef:
                  name: rds-postgresql-instance-output
                  key: url
          envFrom:
            - configMapRef:
                name: environment-variables
            - secretRef:
                name: app-secrets
          readinessProbe:
            httpGet:
              path: /healthcheck/ready
              port: 3000
              httpHeaders:
                - name: X-Forwarded-Proto
                  value: https
                - name: X-Forwarded-Ssl
                  value: "on"
            periodSeconds: 60
            timeoutSeconds: 15
          livenessProbe:
            httpGet:
              path: /healthcheck/live
              port: 3000
              httpHeaders:
                - name: X-Forwarded-Proto
                  value: https
                - name: X-Forwarded-Ssl
                  value: "on"
            periodSeconds: 60
            timeoutSeconds: 15
      initContainers:
        - name: pending-migrations
          image: ${ECR_URL}:${IMAGE_TAG}
          command:
            - rake
            - db:abort_if_pending_migrations
          env:
            - name: DATABASE_URL
              valueFrom:
                secretKeyRef:
                  name: rds-postgresql-instance-output
                  key: url
          envFrom:
          - configMapRef:
              name: environment-variables
          - secretRef:
              name: app-secrets
