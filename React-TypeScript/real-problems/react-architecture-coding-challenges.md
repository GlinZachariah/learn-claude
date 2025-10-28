# React Architecture Coding Challenges

## Challenge 1: Build Scalable State Management System (Intermediate, 3 hours)

### Problem Description
Create a Redux-based state management system with normalization, selectors, and async handling for an e-commerce app.

### Requirements
- Normalize product and order data
- Implement async thunks for API calls
- Create memoized selectors
- Handle loading and error states
- Implement optimistic updates
- Add undo/redo functionality

### Starter Code
```typescript
// store/slices/productSlice.ts
import { createSlice, createAsyncThunk } from '@reduxjs/toolkit';

export const fetchProducts = createAsyncThunk(
    'products/fetchProducts',
    async (_, { rejectWithValue }) => {
        // TODO: Fetch from API
    }
);

const productSlice = createSlice({
    name: 'products',
    initialState: {
        // TODO: Define normalized state
    },
    extraReducers: (builder) => {
        // TODO: Handle async actions
    },
});

// store/selectors/productSelectors.ts
// TODO: Create memoized selectors
```

### Expected Solution
- Normalized state structure
- Async thunks with error handling
- Memoized selectors using reselect
- Loading/error state management
- Optimistic updates with rollback
- DevTools integration

### Bonus Features
- Time-travel debugging
- Action history
- Redux persist for hydration
- Custom middleware for logging
- Snapshot/restore feature

---

## Challenge 2: Build Micro-Frontend Architecture with Module Federation (Advanced, 4 hours)

### Problem Description
Implement micro-frontends using Webpack 5 Module Federation with shared libraries and independent team ownership.

### Requirements
- Host application with routing
- 3 remote micro-applications
- Shared React/routing libraries
- Dynamic loading of remotes
- Error handling and fallbacks
- Version compatibility management

### Starter Code
```typescript
// webpack.config.js - Host
module.exports = {
    plugins: [
        new ModuleFederationPlugin({
            name: 'host',
            remotes: {
                // TODO: Configure remotes
            },
            shared: {
                // TODO: Define shared libraries
            },
        }),
    ],
};

// Bootstrap component
const MicroApp = ({ appName, path }) => {
    // TODO: Load and mount remote app
};
```

### Expected Solution
- Module federation setup for host
- Remote app configuration
- Shared library management
- Dynamic module loading
- Error boundaries for failures
- Version compatibility checks

### Bonus Features
- Service worker caching
- Shared state management
- API gateway integration
- Deployment strategies
- Versioning strategies

---

## Challenge 3: Implement Advanced Form Management (Intermediate, 2.5 hours)

### Problem Description
Build a complex form system with multi-step validation, custom hooks, and state management.

### Requirements
- Multi-step form with validation
- Field-level and form-level validation
- Async validation (email uniqueness)
- Custom input components
- Auto-save functionality
- Error display and recovery

### Starter Code
```typescript
// hooks/useForm.ts
const useForm = (initialValues, onSubmit, validate) => {
    // TODO: Implement form hook
};

// components/FormField.tsx
const FormField = ({ name, label, type }) => {
    // TODO: Create reusable field component
};

// Usage
const MyForm = () => {
    const { values, errors, handleChange, handleSubmit } = useForm(
        { email: '', password: '' },
        async (values) => { /* submit */ },
        validate
    );

    return (
        // TODO: Create form JSX
    );
};
```

### Expected Solution
- Custom form hook
- Field validation logic
- Async validation handling
- Reusable field components
- Error display
- Submit handling
- Auto-save mechanism

### Bonus Features
- Dirty state tracking
- Field dependencies
- Conditional fields
- Field arrays for dynamic fields
- Form reset functionality

---

## Challenge 4: Build Real-time Collaborative Component (Advanced, 3 hours)

### Problem Description
Create a real-time collaborative editor/dashboard using WebSocket and conflict resolution.

### Requirements
- WebSocket connection management
- Real-time data synchronization
- Conflict resolution (last-write-wins or OT)
- User presence awareness
- Optimistic updates
- Offline support with sync

### Starter Code
```typescript
// hooks/useRealtimeSync.ts
const useRealtimeSync = (resourceId, initialData) => {
    // TODO: Implement real-time sync
};

// components/CollaborativeEditor.tsx
const CollaborativeEditor = ({ documentId }) => {
    const { data, users, updateData } = useRealtimeSync(documentId);

    // TODO: Render collaborative UI
};
```

### Expected Solution
- WebSocket integration
- Real-time data sync
- Conflict resolution
- User presence tracking
- Optimistic updates
- Offline queue
- Sync on reconnect

### Bonus Features
- Activity feed
- Change history
- Permissions management
- Version control
- Undo/redo support

---

## Challenge 5: Implement Performance-Optimized Virtual List (Intermediate, 2.5 hours)

### Problem Description
Build a virtual list component with dynamic item sizes, infinite scroll, and search.

### Requirements
- Virtual scrolling for 10K+ items
- Dynamic item sizing
- Infinite scroll pagination
- Search filtering
- Sorting
- Custom item rendering

### Starter Code
```typescript
// components/VirtualList.tsx
interface VirtualListProps<T> {
    items: T[];
    itemSize: number | ((index: number) => number);
    renderItem: (item: T, index: number) => React.ReactNode;
    onLoadMore?: () => void;
}

const VirtualList = <T,>({
    items,
    itemSize,
    renderItem,
    onLoadMore,
}: VirtualListProps<T>) => {
    // TODO: Implement virtual list
};
```

### Expected Solution
- Viewport-based rendering
- Dynamic height calculation
- Scroll position management
- Placeholder for loading
- Infinite scroll trigger
- Item caching
- Scroll restoration

### Bonus Features
- Sticky headers
- Item selection
- Drag and drop
- Accessibility support
- Performance monitoring

---

## Challenge 6: Build Design System Component Library (Intermediate, 3 hours)

### Problem Description
Create a comprehensive component library with Storybook documentation and theming.

### Requirements
- 10+ base components
- Design tokens system
- Theming (light/dark mode)
- Storybook documentation
- Accessibility compliance
- TypeScript types

### Starter Code
```typescript
// components/Button.tsx
interface ButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
    variant?: 'primary' | 'secondary';
    size?: 'small' | 'medium' | 'large';
    isLoading?: boolean;
}

export const Button = forwardRef<HTMLButtonElement, ButtonProps>(
    ({ variant = 'primary', size = 'medium', ...props }, ref) => {
        // TODO: Implement button
    }
);

// components/Button.stories.tsx
export default {
    title: 'Components/Button',
    component: Button,
};

export const Primary = () => <Button variant="primary">Click me</Button>;
```

### Expected Solution
- Reusable components
- Props documentation
- Storybook setup
- Design tokens
- Theme provider
- CSS-in-JS or CSS modules
- Type safety

### Bonus Features
- Visual regression testing
- Accessibility testing
- Performance metrics
- Version management
- Changelog generation

---

## Challenge 7: Implement Advanced Error Handling (Intermediate, 2 hours)

### Problem Description
Create comprehensive error handling with Error Boundaries, error logging, and recovery UI.

### Requirements
- Error Boundary for React errors
- Global error handler
- API error transformation
- User-friendly error messages
- Error reporting service
- Error recovery options
- Logging and monitoring

### Starter Code
```typescript
// components/ErrorBoundary.tsx
interface ErrorBoundaryProps {
    children: React.ReactNode;
    fallback?: (error: Error) => React.ReactNode;
}

export class ErrorBoundary extends React.Component<
    ErrorBoundaryProps,
    { hasError: boolean; error: Error | null }
> {
    // TODO: Implement error boundary
}

// hooks/useAsyncError.ts
const useAsyncError = () => {
    // TODO: Handle async errors
};

// services/errorReporter.ts
export const reportError = (error: Error, context?: any) => {
    // TODO: Report to error tracking service
};
```

### Expected Solution
- Error boundary component
- Try-catch wrapper for async
- Error transformation layer
- User notification system
- Error logging
- Recovery strategies
- Monitoring integration

### Bonus Features
- Error context preservation
- Stack trace capture
- Source map support
- Error analytics
- Recovery suggestions

---

## Challenge 8: Build Data Caching & Revalidation Layer (Advanced, 3 hours)

### Problem Description
Implement advanced data caching with revalidation, background sync, and stale-while-revalidate pattern.

### Requirements
- Request deduplication
- Cache with TTL
- Stale-while-revalidate pattern
- Background revalidation
- Optimistic updates
- Cache invalidation
- Offline support

### Starter Code
```typescript
// hooks/useCachedData.ts
interface UseCachedDataOptions {
    cacheTime?: number;
    staleTime?: number;
    onSuccess?: (data: any) => void;
    onError?: (error: Error) => void;
}

const useCachedData = <T,>(
    key: string,
    fetcher: () => Promise<T>,
    options?: UseCachedDataOptions
) => {
    // TODO: Implement caching logic
};

// Usage
const UserProfile = ({ userId }: { userId: string }) => {
    const { data: user, isLoading, error, refetch } = useCachedData(
        `user-${userId}`,
        () => userService.getUser(userId),
        { staleTime: 5 * 60 * 1000 } // 5 minutes
    );

    // TODO: Render component
};
```

### Expected Solution
- Cache store with TTL
- Request deduplication
- Stale-while-revalidate
- Background revalidation
- Optimistic updates
- Cache invalidation
- Persistence

### Bonus Features
- Prefetching
- Pagination support
- Infinite queries
- Mutation hooks
- DevTools

---

## General Requirements

### Code Quality
- ✅ TypeScript with strict mode
- ✅ Proper error handling
- ✅ Performance optimized
- ✅ Accessible components
- ✅ Unit tests (80%+ coverage)
- ✅ Integration tests
- ✅ Clear documentation

### React Best Practices
- ✅ Hooks over class components
- ✅ Functional components
- ✅ Proper dependency arrays
- ✅ No inline object creation
- ✅ Memoization where needed
- ✅ Custom hooks for logic
- ✅ Clear prop interfaces

### Performance
- ✅ Code splitting
- ✅ Lazy loading
- ✅ Memoization strategy
- ✅ Bundle size limits
- ✅ Render count optimization
- ✅ Memory leak prevention

---

## Evaluation Criteria

| Criteria | Points |
|----------|--------|
| **Functionality** | 30% |
| **Code Quality** | 25% |
| **Performance** | 20% |
| **Testing** | 15% |
| **Documentation** | 10% |

---

## Time Estimates Summary

| Challenge | Difficulty | Time |
|-----------|-----------|------|
| 1 | Intermediate | 3h |
| 2 | Advanced | 4h |
| 3 | Intermediate | 2.5h |
| 4 | Advanced | 3h |
| 5 | Intermediate | 2.5h |
| 6 | Intermediate | 3h |
| 7 | Intermediate | 2h |
| 8 | Advanced | 3h |
| **Total** | **Mixed** | **23h** |

---

## Success Indicators

After completing these challenges, you should be able to:

✅ Design scalable React architectures
✅ Manage complex state efficiently
✅ Implement performance optimizations
✅ Build reusable component systems
✅ Handle real-time data synchronization
✅ Implement error handling and recovery
✅ Build accessible, type-safe components
✅ Optimize bundle size
✅ Write comprehensive tests
✅ Deploy and monitor React apps

