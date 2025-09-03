FROM ghcr.io/astral-sh/uv:python3.12-bookworm

# Set the working directory
WORKDIR /app

# Copy the project files including the wheel into the container
COPY . /app

# Upgrade pip first
# RUN pip install --upgrade pip

# Now install your API project (which no longer references the wheel in pyproject.toml)
# RUN uv pip install .
RUN uv sync

# Expose port 8000
# EXPOSE 8000

# Start the FastAPI server
# CMD [ "uv", "run", "uvicorn", "api_training.api:app", "--host", "0.0.0.0", "--port", "8000"]

# CMD uv run uvicorn api_training.api:app --host 0.0.0.0 --port $PORT
# Start the FastAPI server using shell form to expand $PORT
#CMD ["sh", "-c", "uv run uvicorn api_training.api:app --host 0.0.0.0 --port $PORT"]
# Start the FastAPI server using an explicit shell so $PORT expands
# ENTRYPOINT [ "sh", "-c" ]
# CMD ["uv run uvicorn api_training.api:app --host 0.0.0.0 --port $PORT"]
# Run uvicorn with PORT from environment variable directly in a shell
CMD uv run uvicorn api_training.api:app --host 0.0.0.0 --port ${PORT:-8080}

# # api_training/Dockerfile

# FROM python:3.12-slim

# # Set the working directory
# WORKDIR /app

# # Copy the project files into the container
# COPY . /app

# # Upgrade pip and install build dependencies
# RUN pip install --upgrade pip
# RUN pip install .

# # Expose port 8000
# EXPOSE 8000

# # Start the FastAPI server
# CMD ["uvicorn", "api:app", "--host", "0.0.0.0", "--port", "8000"]
