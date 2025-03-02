# PostgreSQL connection variables
CONTAINER_NAME = datawarehouse-postgres
POSTGRES_USER = postgres
DB_NAME = datawarehouse

# Docker commands
.PHONY: up down clean psql exec-sql tables exec-bronze exec-silver

# Start the container
up:
	docker-compose up

# Stop the container
down:
	docker-compose down

# Stop and remove volumes
clean:
	docker-compose down -v

# Connect to PostgreSQL with psql
psql:
	docker-compose exec postgres psql -U $(POSTGRES_USER) -d $(DB_NAME)

# Execute a SQL script (usage: make exec-sql SCRIPT=./scripts/init.sql)
exec-sql:
	@if [ -z "$(SCRIPT)" ]; then \
		echo "Error: SCRIPT parameter is required. Usage: make exec-sql SCRIPT=path/to/script.sql"; \
		exit 1; \
	fi
	@if [ ! -f "$(SCRIPT)" ]; then \
		echo "Error: Script file $(SCRIPT) not found"; \
		exit 1; \
	fi
	docker-compose exec -T postgres psql -U $(POSTGRES_USER) -d $(DB_NAME) < $(SCRIPT)

# Exec bronze layer
exec-bronze:
	@docker-compose exec -T postgres psql -U $(POSTGRES_USER) -d $(DB_NAME) < ./scripts/bronze/ddl_bronze.sql
	@docker-compose exec -T postgres psql -U $(POSTGRES_USER) -d $(DB_NAME) < ./scripts/bronze/proc_load_bronze.sql

exec-silver:
	@docker-compose exec -T postgres psql -U $(POSTGRES_USER) -d $(DB_NAME) < ./scripts/silver/ddl_silver.sql
	@docker-compose exec -T postgres psql -U $(POSTGRES_USER) -d $(DB_NAME) < ./scripts/silver/crm_cust_info/proc_load_silver.sql

	@docker-compose exec -T postgres psql -U $(POSTGRES_USER) -d $(DB_NAME) < ./scripts/silver/crm_prd_info/proc_load_silver.sql


# Show database info
info:
	@echo "Listing schemas..."
	@docker-compose exec postgres psql -U $(POSTGRES_USER) -d $(DB_NAME) -c "\dn"
	@echo "== Bronze Layer Tables ==="
	@docker-compose exec postgres psql -U $(POSTGRES_USER) -d $(DB_NAME) -c "\dt bronze.*"
	@echo "== Silver Layer Tables ==="
	@docker-compose exec postgres psql -U $(POSTGRES_USER) -d $(DB_NAME) -c "\dt silver.*"
	@echo "== Gold Layer Tables ==="
	@docker-compose exec postgres psql -U $(POSTGRES_USER) -d $(DB_NAME) -c "\dt gold.*"
