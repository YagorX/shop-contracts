.PHONY: help proto-lint proto-gen openapi-validate validate-events bundle check-tools check-npx

# Куда gateway отдаёт спеку Swagger UI (генерируемая копия из этого source of truth).
GATEWAY_SPEC := ../shop-gateway-service/openapi/gateway.v1.yaml

help:
	@echo "Targets:"
	@echo "  make proto-lint        - lint protobuf contracts with buf"
	@echo "  make proto-gen         - generate protobuf code with buf"
	@echo "  make openapi-validate  - validate OpenAPI contract"
	@echo "  make validate-events   - compile/check JSON event schemas"
	@echo "  make bundle            - inline \$$ref into a single file served by gateway Swagger"

check-tools: check-npx
	@command -v buf >/dev/null 2>&1 || (echo "buf is required: https://buf.build/docs/installation" && exit 1)

check-npx:
	@command -v npx >/dev/null 2>&1 || (echo "npx is required (Node.js): https://nodejs.org" && exit 1)

proto-lint: check-tools
	@buf lint

proto-gen: check-tools
	@buf generate

openapi-validate: check-tools
	@npx -y @redocly/cli lint openapi/gateway.v1.yaml

# Склеивает многофайловую спеку (с $ref) в один самодостаточный файл и кладёт его туда,
# откуда gateway отдаёт Swagger UI. Запускать после любых правок openapi/.
bundle: check-npx
	@npx -y @redocly/cli bundle openapi/gateway.v1.yaml -o $(GATEWAY_SPEC)
	@echo "bundled -> $(GATEWAY_SPEC)"

validate-events: check-tools
	@npx -y ajv-cli compile -s events/order.created.v1.json -r events/common-envelope.v1.json
	@npx -y ajv-cli compile -s events/payment.succeeded.v1.json -r events/common-envelope.v1.json
	@npx -y ajv-cli compile -s events/payment.failed.v1.json -r events/common-envelope.v1.json
	@npx -y ajv-cli compile -s events/order.fulfilled.v1.json -r events/common-envelope.v1.json
	@npx -y ajv-cli compile -s events/order.backordered.v1.json -r events/common-envelope.v1.json
