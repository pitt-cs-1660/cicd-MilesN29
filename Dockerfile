FROM python:3.11-buster AS builder
WORKDIR /app

COPY pyproject.toml poetry.lock ./ 
RUN pip install --upgrade pip && pip install poetry
RUN poetry config virtualenvs.create false \
  && poetry install --no-root --no-interaction --no-ansi
#put all of the stuff in the container
COPY . .

FROM python:3.11-buster
WORKDIR /app
#we installed the stuff we need in builder, but now we have to actually go get it. 
# we dont want to get everything tho (dont need poetry or compilers)
# so we get only the stuff we need that we downloaded in builder
COPY --from=builder /usr/local/lib/python3.11/site-packages /usr/local/lib/python3.11/site-packages
COPY --from=builder /usr/local/bin /usr/local/bin

COPY --from=builder /app /app

EXPOSE 8000

ENTRYPOINT [ "/app/entrypoint.sh" ]
CMD ["uvicorn", "cc_compose.server:app", "--reload", "--host", "0.0.0.0", "--port", "8000"]
