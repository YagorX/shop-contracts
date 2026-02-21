# shop-contracts (v1)

Этот репозиторий хранит контракты первой версии (`v1`) для mini-shop.

Текущий этап: **Contract Baseline v1.0.0**.

## Структура репозитория

```text
shop-contracts/
  events/
    README.md
    common-envelope.v1.json
    order.created.v1.json
    payment.succeeded.v1.json
    payment.failed.v1.json
    order.fulfilled.v1.json
    order.backordered.v1.json

  proto/
    catalog/
      v1/
        catalog.proto
    order/
      v1/
        order.proto

  openapi/
    gateway.v1.yaml

  Makefile
  README.md
```

## Что за что отвечает

- `events/`
  Контракты Kafka-событий для асинхронного взаимодействия сервисов.
  Это бизнес-факты, которые публикуются в топики (`order.created.v1`, `payment.failed.v1` и т.д.).

- `proto/`
  gRPC-контракты внутренних синхронных вызовов между сервисами.
  В `v1`:
  - `catalog/v1/catalog.proto`: `ListProducts`, `GetProduct`
  - `order/v1/order.proto`: `CreateOrder`, `GetOrder`

- `openapi/`
  HTTP-контракты публичного API (`gateway`) для клиента.

## Принятый транспорт в v1

- Внешний клиент -> `gateway`: HTTP (`openapi/gateway.v1.yaml`)
- `gateway` -> `catalog-service`: gRPC (`proto/catalog/v1/catalog.proto`)
- `gateway` -> `order-service`: gRPC (`proto/order/v1/order.proto`)
- Асинхронные шаги (payment/fulfillment/notification/audit): Kafka events (`events/*.v1.json`)

## Версионность (только v1)

- Все текущие контракты — версия `v1`.
- Backward-compatible изменения разрешены в `v1`.
- Ломающие изменения только через новую версию (`v2`).
- Имена топиков содержат суффикс версии: `<event_name>.v1`.

## Правила для events v1

- Kafka key: `order_id`.
- Required headers: `traceparent`, `x-request-id`, `event_type`, `event_version`.
- Единый envelope: `common-envelope.v1.json`.
- Любое событие должно проходить валидацию своей схемой.

## План фиксации v1.0.0

1. `events` — завершено.
2. `proto/catalog/v1/catalog.proto` — завершено.
3. `proto/order/v1/order.proto` — завершено.
4. `openapi/gateway.v1.yaml` — завершено.
5. Поставить тег `v1.0.0`.
