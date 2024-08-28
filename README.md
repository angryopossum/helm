# helm
Example of helm charts

Для настройки TLS в Redis кластере вам потребуется создать несколько типов сертификатов: **CA сертификат**, **сертификаты для серверных нод Redis**, и **сертификаты для клиентов**. 

Ниже приведены команды для создания этих сертификатов с использованием `openssl`.

### 1. Создание CA сертификата

CA (Certificate Authority) сертификат будет использоваться для подписания сертификатов нод и клиентов.

```bash
# Генерация приватного ключа для CA
openssl genrsa -out ca.key 4096

# Создание CA сертификата
openssl req -x509 -new -nodes -key ca.key -sha256 -days 3650 -out ca.crt \
  -subj "/C=US/ST=State/L=City/O=Company Name/OU=Org/CN=example.com"
```

### 2. Создание серверного сертификата для Redis ноды

Для каждой ноды в кластере вам нужно создать отдельный сертификат.

#### 2.1. Создание приватного ключа

```bash
openssl genrsa -out redis-node1.key 4096
```

#### 2.2. Создание CSR (Certificate Signing Request)

```bash
openssl req -new -key redis-node1.key -out redis-node1.csr \
  -subj "/C=US/ST=State/L=City/O=Company Name/OU=Org/CN=redis-node1"
```

#### 2.3. Подписание сертификата CA

```bash
openssl x509 -req -in redis-node1.csr -CA ca.crt -CAkey ca.key -CAcreateserial \
  -out redis-node1.crt -days 3650 -sha256
```

### 3. Создание клиентского сертификата

Сертификаты для клиентов создаются аналогично серверным сертификатам.

#### 3.1. Создание приватного ключа клиента

```bash
openssl genrsa -out client.key 4096
```

#### 3.2. Создание CSR для клиента

```bash
openssl req -new -key client.key -out client.csr \
  -subj "/C=US/ST=State/L=City/O=Company Name/OU=Org/CN=client"
```

#### 3.3. Подписание сертификата клиенту

```bash
openssl x509 -req -in client.csr -CA ca.crt -CAkey ca.key -CAcreateserial \
  -out client.crt -days 3650 -sha256
```

### 4. Валидация сертификатов

После создания сертификатов вы можете проверить их:

```bash
openssl x509 -in redis-node1.crt -text -noout
```

### 5. Конфигурация Redis с TLS

Сгенерированные файлы (`ca.crt`, `redis-node1.key`, `redis-node1.crt`, `client.key`, `client.crt`) будут использоваться для настройки TLS в Redis. Эти файлы нужно передать на соответствующие серверы и клиенты.

### Заключение

Используя эти команды, вы создадите все необходимые сертификаты для настройки TLS в Redis кластере. Эти сертификаты помогут защитить коммуникации между нодами Redis и клиентами, обеспечивая шифрование и проверку подлинности.
