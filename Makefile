# Target setup
TARGET = setup

# bash shell
SHELL = /bin/bash

# .PHONY: 

# Check if uv is installed
check_uv_installed:
	@command --version uv >/dev/null 2>&1 || { echo "Installing uv..."; pip install uv; }

# Check if virtual environment exists
check_venv: check_uv_installed
	@if [ ! -d ".venv" ]; then \
		echo "Creating virtual environment..."; \
		uv venv --python=3.9.21; \
	else \
		echo "Virtual environment already exists."; \
	fi

# Install dependencies in development environment
install_dev:
	@uv sync --dev
	@echo "Development dependencies installed."

# Install dependencies in production environment
install_prod:
	@uv sync --no-dev
	@echo "Production dependencies installed."

# Menu for selecting the environment
menu_env: check_venv
	@echo "Please select the environment:"; \
	echo '1) dev'; \
	echo '2) prod'; \
	read -p 'Enter value: ' choice_env; \
	$(MAKE) --no-print-directory got-choice-env CHOICE_ENV="$$choice_env"

	@echo "Please select the CUDA option:"; \
	echo '1) cuda 11.8'; \
	echo '2) cuda 12.4'; \
	echo '3) cuda 12.6'; \
	echo '4) cpu only'; \
	read -p 'Enter value: ' choice_cuda; \
	$(MAKE) --no-print-directory got-choice-cuda CHOICE_CUDA="$$choice_cuda"

got-choice-env:
	@if [ "$(CHOICE_ENV)" = "1" ]; then \
		$(MAKE) install_dev; \
	elif [ "$(CHOICE_ENV)" = "2" ]; then \
		$(MAKE) install_prod; \
	else \
		echo "Invalid environment choice!"; \
	fi

got-choice-cuda:
	@if [ "$(CHOICE_CUDA)" = "1" ]; then \
		uv pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118; \
	elif [ "$(CHOICE_CUDA)" = "2" ]; then \
		uv pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu124; \
	elif [ "$(CHOICE_CUDA)" = "3" ]; then \
		uv pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu126; \
	elif [ "$(CHOICE_CUDA)" = "4" ]; then \
		uv pip install torch torchvision torchaudio; \
	else \
		echo "Invalid CUDA choice!"; \
	fi

# Check env for mlflow
ask_env_mlflow:
	@echo 'You need to have .env file in mlflow-docker-compose directory.'; \
	echo 'Do you want to create it or not?'; \
	echo '1) Yes'; \
	echo '2) No'; \
	read -p 'Enter value: ' choice_env_mlflow; \
    $(MAKE) --no-print-directory got-choice-env-mlflow CHOICE_ENV_MLFLOW=$$choice_env_mlflow
	@docker compose -f mlflow-docker-compose/docker-compose.yml up -d
	echo "MLFlow, Minio and MySQL Server are running."


got-choice-env-mlflow:
	@if [ "$(CHOICE_ENV_MLFLOW)" = "1" ]; then \
		source ./bin/create_env_mflow.sh; \
	elif [ "$(CHOICE_ENV_MLFLOW)" = "2" ]; then \
		echo "No"; \
	else \
		echo "Invalid choice!"; \
	fi

# Build and deploy the application on local server
build_deploy_local:
	@echo "Building and deploying the application on local server..."; \
	echo "Please input the port number on localhost: "; \
	read -p 'Enter value: ' PORT; \
	bash ./bin/build_deploy_local.sh $$PORT

copy_elk_docker_compose:
	@echo "Please make sure your localhost is connected to the compute engine via SSH..."; \
	read -p 'Enter GCP External IP: ' GCE_EXTERNAL_IP; \
	scp -i ~/.ssh/id_rsa -r elk-docker-compose minhnhk@$$GCE_EXTERNAL_IP:/home/minhnhk

# Main menu
menu:
	@echo "Please select the option:"; \
	echo '1) Create, activate the environment and install their dependencies'; \
	echo '2) Create MLFlow, Minio and MySQL Server for logging the training results'; \
	echo '3) Install Ninja Linux package'; \
	echo '4) Download 68 Shape Predictor DLIB Model'; \
	echo '5) Deploy the application on local server to develop'; \
	echo '6) Copy the elk-docker-compose folder to compute engine'; \
	echo '7) Deploy filebeat pod to GKE'; \
	read -p 'Enter value: ' result; \
	$(MAKE) --no-print-directory got-choice CHOICE="$$result"

got-choice:
	@if [ "$(CHOICE)" = "1" ]; then \
		$(MAKE) menu_env; \
	elif [ "$(CHOICE)" = "2" ]; then \
		$(MAKE) ask_env_mlflow; \
	elif [ "$(CHOICE)" = "3" ]; then \
		source ./bin/install_ninja.sh; \
	elif [ "$(CHOICE)" = "4" ]; then \
		source ./bin/download_dlib_model.sh; \
	elif [ "$(CHOICE)" = "5" ]; then \
		$(MAKE) build_deploy_local; \
	elif [ "$(CHOICE)" = "6" ]; then \
		$(MAKE) copy_elk_docker_compose; \
	elif [ "$(CHOICE)" = "7" ]; then \
		source ./bin/helm_filebeat.sh; \
	else \
		echo "Invalid choice!"; \
	fi

# Run setup
setup: menu
