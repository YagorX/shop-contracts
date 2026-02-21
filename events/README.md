# Events v1

## Общие правила

- Topic naming: `<event_name>.v1` (e.g. `order.created.v1`)
- Kafka key: `order_id`
- Required headers: `traceparent`, `x-request-id`, `event_type`, `event_version`
- Compatibility: backward-compatible changes in `v1`; breaking changes -> `v2`

## Назначение файлов

- `common-envelope.v1.json`
  Общий каркас любого события: идентификаторы, тип, версия, время события, `order_id`, `customer_id`, контейнер `data`.

- `order.created.v1.json`
  Событие о создании заказа в `order-service`. Стартует асинхронную цепочку обработки (payment/аудит и т.д.).

- `payment.succeeded.v1.json`
  Событие об успешной оплате. Используется для запуска fulfillment и дальнейших уведомлений.

- `payment.failed.v1.json`
  Событие о неуспешной оплате (declined/timeout/provider_error/invalid_request). Используется для уведомлений и аналитики отказов.

- `order.fulfilled.v1.json`
  Событие о том, что заказ укомплектован/готов к доставке. Используется notification и audit-сервисами.

- `order.backordered.v1.json`
  Событие о том, что заказ отложен (нет в наличии/задержка поставки). Используется для уведомлений и расследований по supply-проблемам.

## Поток событий (checkout)

1. `order.created.v1`
2. `payment.succeeded.v1` или `payment.failed.v1`
3. при успехе оплаты: `order.fulfilled.v1` или `order.backordered.v1`
