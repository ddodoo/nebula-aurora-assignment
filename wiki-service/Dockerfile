# Build Stage

FROM python:3.12-slim AS builder

# Set workdir
WORKDIR /app

# Install build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends build-essential && rm -rf /var/lib/apt/lists/*

# Copy pyproject.toml 
COPY pyproject.toml /app/

# Copy application code 
COPY app ./app

# Install dependencies 
RUN pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir .

# Runtime Stage

FROM python:3.12-slim

# Set workdir
WORKDIR /app

# Create non-root user
RUN useradd -m appuser \
    && chown -R appuser:appuser /app

USER appuser


# Copy installed dependencies FROM builder
COPY --from=builder /usr/local/lib/python3.12/ /usr/local/lib/python3.12/
COPY --from=builder /usr/local/bin/ /usr/local/bin/

# Copy application code
COPY --chown=appuser:appuser app/ /app

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1


EXPOSE 9000

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "9000"]
