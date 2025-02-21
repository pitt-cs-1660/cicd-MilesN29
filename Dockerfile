FROM python:3.11-buster AS builder
WORKDIR /app

COPY pyproject.toml poetry.lock ./
RUN pip install --upgrade pip && pip install poetry
RUN poetry config virtualenvs.create false \
  && poetry install --no-root --no-interaction --no-ansi
COPY . .

FROM python:3.11-buster
WORKDIR /app

COPY --from=builder /usr/local/lib/python3.11/site-packages /usr/local/lib/python3.11/site-packages
COPY --from=builder /usr/local/bin /usr/local/bin
COPY --from=builder /app /app

EXPOSE 8000

ENTRYPOINT [ "/app/entrypoint.sh" ]
CMD ["uvicorn", "cc_compose.server:app", "--reload", "--host", "0.0.0.0", "--port", "8000"]
