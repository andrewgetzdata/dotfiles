# TypeScript Style Guide

## Formatting
- No semicolons (prettier default)
- Double quotes
- 2-space indentation
- Trailing commas in multi-line structures

## Naming
- Variables/functions: `camelCase`
- Classes/components: `PascalCase`
- Constants: `UPPER_CASE`
- Files: `kebab-case.ts`, `kebab-case.tsx`
- No `var` — `const` by default, `let` when reassignment needed

## Functions
- Arrow functions preferred
- Explicit return types on exported functions
- Destructure props in component signatures

```typescript
// Yes
const formatDate = (date: Date): string => {
  return date.toLocaleDateString("en-US")
}

// Component
const UserCard = ({ name, email }: UserCardProps) => {
  return (
    <div>
      <h2>{name}</h2>
      <p>{email}</p>
    </div>
  )
}
```

## Types
- `interface` for object shapes (extendable, better error messages)
- `type` for unions, intersections, and computed types
- Strict mode always — no `any` unless truly unavoidable
- Prefer `unknown` over `any` when type is uncertain

```typescript
// Interface for object shapes
interface User {
  id: string
  name: string
  email: string
}

// Type for unions/utility types
type Status = "active" | "inactive" | "pending"
type UserWithRole = User & { role: Role }
```

## React Patterns

**Component structure:**
```typescript
// 1. Imports
// 2. Types/interfaces
// 3. Component
// 4. Helpers (if small, otherwise separate file)

interface DashboardProps {
  userId: string
  initialTab?: string
}

const Dashboard = ({ userId, initialTab = "overview" }: DashboardProps) => {
  const [tab, setTab] = useState(initialTab)
  const { data, isLoading } = useQuery(/* ... */)

  if (isLoading) return <Skeleton />

  return (/* ... */)
}

export default Dashboard
```

**Hooks:** extract when logic is reused or component gets complex. Prefix with `use`.

**State management:** start with React state + context. Reach for TanStack Query for server state. Avoid global state libraries unless truly needed.

## File Organization
- Feature-based directories over technical grouping
- Colocate component, test, and styles together
- Shared components in `components/`
- Feature code in `features/` or route-based directories

```
src/
├── components/        # shared UI components
│   ├── button.tsx
│   └── card.tsx
├── features/
│   └── dashboard/
│       ├── dashboard.tsx
│       ├── dashboard.test.tsx
│       ├── use-dashboard-data.ts
│       └── types.ts
├── lib/               # utilities, API clients
└── hooks/             # shared hooks
```

## UI Stack
- **Radix UI** for accessible primitives (dialog, dropdown, tabs, etc.)
- **Tailwind CSS** for styling — utility classes, no CSS modules
- Compose Radix + Tailwind for custom components
- Geist-inspired design: clean, minimal, black backgrounds

## Data Fetching
- TanStack Query for server state (caching, revalidation, optimistic updates)
- Custom hooks wrapping query calls
- Loading/error states handled at the component level

## Error Handling
- Error boundaries for React component trees
- Try/catch in async functions, surface errors to UI
- Toast notifications for user-facing errors
