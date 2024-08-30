Якщо у вас уже є секрет у OpenShift з сертифікатами, ви можете використовувати цей секрет у вашому Helm-чарті для налаштування Redis з підтримкою TLS. Вам потрібно буде оновити Helm-чарт, щоб використовувати існуючий секрет, а не створювати новий.

### Приклад налаштування Helm-чарта з використанням існуючого секрету:

1. **Оновіть файл `values.yaml`:**

   Вкажіть ім'я вашого існуючого секрету в `values.yaml`:

   ```yaml
   image:
     repository: redis
     tag: 7.0
     pullPolicy: IfNotPresent

   tls:
     enabled: true
     certSecret: existing-secret-name
     certFile: /certs/redis.crt
     keyFile: /certs/redis.key
     caFile: /certs/ca.crt

   service:
     name: redis
     type: ClusterIP
     port: 6379
     targetPort: 6379

   resources: {}

   persistence:
     enabled: true
     storageClass: "standard"
     accessModes:
       - ReadWriteOnce
     size: 1Gi
   ```

   Замість `existing-secret-name` вкажіть ім'я вашого секрету.

2. **Оновіть `templates/deployment.yaml` для використання існуючого секрету:**

   В файлі `templates/deployment.yaml` забезпечте, щоб конфігурація Redis використовувала ваш існуючий секрет для сертифікатів. Модифікуйте розділ `volumes` і `volumeMounts` для підключення існуючого секрету:

   ```yaml
   apiVersion: apps/v1
   kind: Deployment
   metadata:
     name: {{ include "redis-tls.fullname" . }}
     labels:
       {{- include "redis-tls.labels" . | nindent 4 }}
   spec:
     replicas: 1
     selector:
       matchLabels:
         app: {{ include "redis-tls.name" . }}
     template:
       metadata:
         labels:
           app: {{ include "redis-tls.name" . }}
       spec:
         containers:
           - name: redis
             image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
             imagePullPolicy: {{ .Values.image.pullPolicy }}
             command: ["redis-server", "/usr/local/etc/redis/redis.conf"]
             volumeMounts:
               - name: redis-config
                 mountPath: /usr/local/etc/redis
                 subPath: redis.conf
               - name: redis-certs
                 mountPath: /certs
             ports:
               - containerPort: 6379
             readinessProbe:
               httpGet:
                 path: /health
                 port: 6379
               initialDelaySeconds: 10
               timeoutSeconds: 5
         volumes:
           - name: redis-config
             configMap:
               name: redis-config
           - name: redis-certs
             secret:
               secretName: {{ .Values.tls.certSecret }}
   ```

   У цьому прикладі `redis-certs` — це том, який монтує секрет, що містить сертифікати для Redis.

3. **Перевірте наявність існуючого секрету:**

   Переконайтеся, що ваш секрет існує у вашому namespace:

   ```bash
   oc get secrets
   ```

   Ви повинні побачити ваш секрет у списку.

4. **Оновіть конфігурацію Redis:**

   Якщо конфігурація Redis вже є в `ConfigMap`, переконайтеся, що в `redis.conf` правильно вказані шляхи до сертифікатів:

   ```yaml
   apiVersion: v1
   kind: ConfigMap
   metadata:
     name: redis-config
   data:
     redis.conf: |
       tls-port 6379
       tls-cert-file /certs/redis.crt
       tls-key-file /certs/redis.key
       tls-ca-cert-file /certs/ca.crt
       tls-auth-clients no
   ```

5. **Перезавантажте ваш Helm-чарт:**

   Після внесення змін, перезавантажте Helm-чарт:

   ```bash
   helm upgrade redis-tls ./redis-tls
   ```

### Пояснення

- **`certSecret`**: Вказує на існуючий секрет, що містить сертифікати для TLS.
- **`volumeMounts`** та **`volumes`**: Налаштовують контейнер для монтування сертифікатів з секрету в потрібну директорію.
- **`ConfigMap`**: Містить конфігурацію Redis, що налаштовує використання TLS.

Цей підхід дозволяє використовувати вже існуючі сертифікати у вашому кластері OpenShift для налаштування Redis з підтримкою TLS без необхідності створювати нові секрети.
