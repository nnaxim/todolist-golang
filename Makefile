include .env
export

PROJECT_ROOT := $(shell pwd)

env-up:
	docker compose up -d golang-postgres
env-down:
	docker compose down golang-postgres
env-cleanup:
	@read -p "Очистить все данные окружения? [Y/N]" ans; \
	if ["$$ans" == "Y"]; then \
		docker compose down golang-postgres && \
		rm -rf out/pgdata && \
		echo "Файлы очищены"; \
	else \
		echo "Очистка отменена"; \
	fi


migrate-create:
	@if [ -z "$(seq)" ]; then \
		echo "seq is empty"; \
		exit 1; \
	fi; \
	MSYS_NO_PATHCONV=1 docker compose run --rm golang-postgres-migrate \
		create \
		-ext sql \
		-dir /migrations \
		-seq "$(seq)"

migrate-up:
	make migrate-action action=up

migrate-down:
	make migrate-action action=down

migrate-action:
	@if [ -z "$(action)" ]; then \
		echo "action is empty"; \
		exit 1; \
	fi; \
	MSYS_NO_PATHCONV=1 docker compose run --rm golang-postgres-migrate \
	-path /migrations \
	-database postgres://${POSTGRES_USER}:${POSTGRES_PASSWORD}@golang-postgres:5432/${POSTGRES_DB}?sslmode=disable \
	"$(action)"

env-port-forwarder:
	docker compose up -d port-forwarder

env-post-close:
	docker compose down -d port-forwarder