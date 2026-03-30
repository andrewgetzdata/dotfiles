# Testing Guide

## Philosophy
- Test behavior, not implementation — tests should survive refactors
- Focus on critical paths and edge cases, not 100% coverage
- Coverage target ~80%+ on business logic; don't chase coverage on boilerplate
- Don't test framework behavior or third-party libraries
- A failing test should clearly tell you what broke

## Python (pytest)

### Structure
- Arrange / Act / Assert pattern
- One assertion concept per test (multiple `assert` lines are fine if testing one thing)
- Test naming: `test_<function>_<scenario>_<expected>`

```python
def test_process_batch_with_empty_list_returns_zero_count():
    # Arrange
    items = []

    # Act
    result = process_batch(items)

    # Assert
    assert result.count == 0
    assert result.errors == []
```

### Fixtures
- Use `conftest.py` for shared fixtures
- `yield` fixtures for setup/teardown
- Scope fixtures appropriately (`function`, `module`, `session`)
- Factory fixtures when you need variations

```python
@pytest.fixture
def db_session():
    session = create_test_session()
    yield session
    session.rollback()
    session.close()

@pytest.fixture
def make_user(db_session):
    def _make_user(name="Test User", email="test@example.com", **kwargs):
        user = User(name=name, email=email, **kwargs)
        db_session.add(user)
        db_session.flush()
        return user
    return _make_user
```

### Parametrize
Use `@pytest.mark.parametrize` for testing multiple inputs/outputs:

```python
@pytest.mark.parametrize("input,expected", [
    ("hello", "HELLO"),
    ("", ""),
    ("Hello World", "HELLO WORLD"),
])
def test_uppercase(input, expected):
    assert uppercase(input) == expected
```

### Mocking
- Mock external dependencies (APIs, third-party services)
- Prefer real databases for integration tests over mocking the DB
- Use `unittest.mock.patch` or `pytest-mock`
- Mock at the boundary, not deep internals

```python
def test_fetch_user_handles_api_timeout(mocker):
    mocker.patch(
        "app.services.user_api.get",
        side_effect=httpx.TimeoutException("timeout"),
    )
    with pytest.raises(UserFetchError):
        fetch_user("user-123")
```

### Test Organization
```
tests/
├── conftest.py           # shared fixtures
├── test_models.py        # unit tests for models
├── test_services.py      # unit tests for business logic
├── integration/
│   ├── conftest.py       # DB fixtures, test client
│   └── test_api.py       # API endpoint tests
└── fixtures/
    └── sample_data.json  # test data files
```

## JavaScript/TypeScript (vitest)

### Structure
Same Arrange/Act/Assert pattern. Use `describe` blocks to group related tests:

```typescript
describe("formatCurrency", () => {
  it("formats positive amounts with dollar sign", () => {
    expect(formatCurrency(1234.56)).toBe("$1,234.56")
  })

  it("handles zero", () => {
    expect(formatCurrency(0)).toBe("$0.00")
  })

  it("formats negative amounts with parentheses", () => {
    expect(formatCurrency(-100)).toBe("($100.00)")
  })
})
```

### React Component Testing
- Test user-visible behavior, not component internals
- Use `@testing-library/react` — query by role, label, text
- Avoid testing implementation details (state values, class names)

```typescript
it("shows error message when form submission fails", async () => {
  server.use(
    http.post("/api/submit", () => HttpResponse.json({ error: "fail" }, { status: 500 }))
  )

  render(<ContactForm />)
  await userEvent.click(screen.getByRole("button", { name: /submit/i }))

  expect(screen.getByText(/something went wrong/i)).toBeInTheDocument()
})
```

### Test File Location
- Colocate with source: `component.tsx` + `component.test.tsx`
- Shared test utilities in `test/` or `__tests__/` directory

## What to Test vs. Skip

**Always test:**
- Business logic and calculations
- Edge cases (empty inputs, boundaries, nulls)
- Error handling paths
- API contract (request/response shapes)
- Complex conditional logic

**Skip:**
- Simple getters/setters
- Framework internals (React rendering, Express routing)
- Third-party library behavior
- Pure UI styling (use visual regression tools instead)
- Configuration-only code
