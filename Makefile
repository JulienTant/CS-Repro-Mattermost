.PHONY: stop start check_mattermost
	
logs:
	@echo "Following logs..."
	@docker-compose logs --follow
	@echo "Done"

setup-mattermost:
	@./scripts/mattermost.sh setup

backup-keycloak:
	@./scripts/keycloak.sh backup

restore-keycloak:
	@./scripts/keycloak.sh restore

start: 
	@echo "Starting..."
	@make restore-keycloak
	@docker-compose up -d
	@make setup-mattermost
	
stop:
	@echo "Stopping..."
	@docker-compose down
	@echo "Done"

restart:
	@docker-compose restart

restart-mattermost:
	@docker-compose restart cs-repro-mattermost

reset:
	@echo "Resetting..."
	@make delete-data
	@make start

downgrade:
	@echo "Downgrading Mattermost..."
	@docker stop cs-repro-mattermost || true && docker rm cs-repro-mattermost || true
	@docker stop cs-repro-postgres || true && docker rm cs-repro-postgres || true
	rm -rf ./volumes/mattermost
	rm -rf ./volumes/db
	docker-compose up -d
	@make setup-mattermost

delete-dockerfiles:
	@echo "Deleting data..."
	@docker-compose rm
	@rm -rf ./volumes
	@echo "Done"

delete-data: stop delete-dockerfiles

nuke: 
	@echo "Nuking Docker..."
	@docker-compose down --rmi all --volumes --remove-orphans
	@make delete-data

