.PHONY: help proto-lint proto-gen openapi-validate validate-events check-tools

help:
	@echo "Targets:"
	@echo "  make proto-lint        - lint protobuf contracts with buf"
	@echo "  make proto-gen         - generate protobuf code with buf"
	@echo "  make openapi-validate  - validate OpenAPI contract"
	@echo "  make validate-events   - compile/check JSON event schemas"

check-tools:
	@command -v buf >/dev/null 2>&1 || (echo "buf is required: https://buf.build/docs/installation" && exit 1)
	@command -v npx >/dev/null 2>&1 || (echo "npx is required (Node.js): https://nodejs.org" && exit 1)

proto-lint: check-tools
	@buf lint

proto-gen: check-tools
	@buf generate

openapi-validate: check-tools
	@npx -y @redocly/cli lint openapi/gateway.v1.yaml

validate-events: check-tools
	@npx -y ajv-cli compile -s events/order.created.v1.json -r events/common-envelope.v1.json
	@npx -y ajv-cli compile -s events/payment.succeeded.v1.json -r events/common-envelope.v1.json
	@npx -y ajv-cli compile -s events/payment.failed.v1.json -r events/common-envelope.v1.json
	@npx -y ajv-cli compile -s events/order.fulfilled.v1.json -r events/common-envelope.v1.json
	@npx -y ajv-cli compile -s events/order.backordered.v1.json -r events/common-envelope.v1.json
