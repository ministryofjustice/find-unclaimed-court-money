apiVersion: batch/v1
kind: Job
metadata:
  name: find-unclaimed-court-money-migrations
spec:
  ttlSecondsAfterFinished: 60
  template:
    spec:
      containers:
      - name: migrations
        image: ${ECR_URL}:${IMAGE_TAG}
        command: ["./config/docker/entrypoint-migrations.sh"]
        env:
          - name: DATABASE_URL
            valueFrom:
              secretKeyRef:
                name: rds-postgresql-instance-output
                key: url
      restartPolicy: OnFailure
