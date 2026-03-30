# Python Style Guide

## Formatting
- 4-space indentation, 88-char line length (black default)
- Double quotes (black default)
- Trailing commas in multi-line structures
- `from __future__ import annotations` for modern type syntax

## Naming
- Variables/functions: `snake_case`
- Classes: `PascalCase`
- Constants: `UPPER_CASE`
- Private methods: leading underscore `_method_name`

## Imports
- Order: stdlib → third-party → local
- Absolute imports preferred
- isort-compatible grouping with blank lines between groups

## Type Hints
- Always use type hints on function signatures
- Use `from __future__ import annotations` for `X | None` syntax
- Pydantic `BaseModel` for validated data, `@dataclass` for plain containers

## Docstrings
- Google-style on public APIs
- Skip on obvious internal/private methods
- Include `Args`, `Returns`, `Raises` sections when non-trivial

```python
def process_batch(items: list[Item], *, dry_run: bool = False) -> BatchResult:
    """Process a batch of items and return the result.

    Args:
        items: Items to process.
        dry_run: If True, validate without persisting.

    Returns:
        Result containing processed count and any errors.

    Raises:
        ValidationError: If any item fails validation.
    """
```

## Preferred Patterns

**f-strings** over format/%, **list comprehensions** over map/filter, **pathlib** over os.path, **context managers** for resources:

```python
# Yes
path = Path(__file__).parent / "data" / "config.json"
names = [u.name for u in users if u.active]
msg = f"Processed {count} items in {elapsed:.2f}s"

# No
path = os.path.join(os.path.dirname(__file__), "data", "config.json")
names = list(map(lambda u: u.name, filter(lambda u: u.active, users)))
msg = "Processed {} items in {:.2f}s".format(count, elapsed)
```

**Dataclasses** for plain data, **Pydantic** for validated/external data:

```python
@dataclass
class Point:
    x: float
    y: float

class UserCreate(BaseModel):
    email: EmailStr
    name: str = Field(min_length=1, max_length=100)
```

## Configuration

Use Pydantic `BaseSettings` with `.env` files:

```python
from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    app_name: str
    debug: bool = False
    database_url: str

    model_config = ConfigDict(env_file=".env")

settings = Settings()
```

## Error Handling
- Catch specific exceptions, never bare `except:`
- Let unexpected errors propagate
- Log errors with `exc_info=True`

```python
try:
    result = external_api.fetch(item_id)
except httpx.TimeoutException:
    logger.warning(f"Timeout fetching item {item_id}, retrying")
    result = external_api.fetch(item_id, timeout=30)
except httpx.HTTPStatusError as e:
    logger.error(f"API error for item {item_id}: {e}", exc_info=True)
    raise
```

## Logging

```python
import logging

logger = logging.getLogger(__name__)

# Levels:
# DEBUG — internal state, variable values during development
# INFO — operations starting/completing, key business events
# WARNING — recoverable issues, degraded behavior
# ERROR — failures with exc_info=True
```

## Async
- `asyncio` for async runtime
- `httpx.AsyncClient` for async HTTP
- Prefer `async for` / `async with` when available

## Project Structure

```
project/
├── pyproject.toml
├── src/package_name/
│   ├── __init__.py
│   ├── main.py
│   ├── models.py
│   ├── services/
│   └── routes/
├── tests/
│   ├── conftest.py
│   └── test_*.py
├── scripts/
└── docs/
```

- src/ layout with `pyproject.toml`
- Separate `tests/` directory
- `scripts/` for CLI utilities and one-off scripts
- Business logic in `services/`, never in routes

## Dependencies
- CLI tools: typer or click
- HTTP clients: httpx (async), requests (simple scripts)
- Date/time: standard datetime, avoid arrow/pendulum unless needed
- Data validation: Pydantic
- Secrets: environment variables or secrets manager, never in code
