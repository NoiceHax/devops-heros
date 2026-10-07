FROM python:3.12-slim
WORKDIR /app
COPY app/ ./app/
# non-root user
RUN useradd --create-home appuser
USER appuser
CMD ["python", "-m", "app.calculator"]
