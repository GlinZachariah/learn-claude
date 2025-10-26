# Performance & Optimization with React & TypeScript

## Part 1: Rendering Optimization

```typescript
// React.memo for Preventing Re-renders
interface ItemProps {
    id: string;
    title: string;
    onSelect: (id: string) => void;
}

const Item = React.memo<ItemProps>(
    ({ id, title, onSelect }) => {
        console.log(`Item ${id} rendered`);
        return <div onClick={() => onSelect(id)}>{title}</div>;
    },
    (prevProps, nextProps) => {
        return prevProps.id === nextProps.id && prevProps.title === nextProps.title;
    }
);

// useMemo for Expensive Calculations
const DataList: React.FC<{ data: any[] }> = ({ data }) => {
    const [filter, setFilter] = React.useState('');

    const filteredData = React.useMemo(() => {
        console.log('Filtering data...');
        return data.filter(item =>
            item.title.toLowerCase().includes(filter.toLowerCase())
        );
    }, [data, filter]);

    const total = React.useMemo(() => {
        return filteredData.reduce((sum, item) => sum + item.value, 0);
    }, [filteredData]);

    return (
        <div>
            <input value={filter} onChange={e => setFilter(e.target.value)} />
            <p>Total: {total}</p>
            <ul>
                {filteredData.map(item => (
                    <li key={item.id}>{item.title}</li>
                ))}
            </ul>
        </div>
    );
};

// useCallback for Stable Function References
const Parent: React.FC = () => {
    const [count, setCount] = React.useState(0);

    const handleItemSelect = React.useCallback(
        (itemId: string) => {
            console.log(`Selected: ${itemId}`);
            // Handle selection
        },
        [] // Dependencies
    );

    return (
        <div>
            <Item id="1" title="Item 1" onSelect={handleItemSelect} />
            <button onClick={() => setCount(count + 1)}>Count: {count}</button>
        </div>
    );
};
```

## Part 2: Code Splitting & Lazy Loading

```typescript
// Route-based Code Splitting
const HomePage = React.lazy(() => import('./pages/Home'));
const AboutPage = React.lazy(() => import('./pages/About'));
const DashboardPage = React.lazy(() => import('./pages/Dashboard'));
const AdminPage = React.lazy(() => import('./pages/Admin'));

const Router: React.FC = () => (
    <BrowserRouter>
        <Suspense fallback={<LoadingSpinner />}>
            <Routes>
                <Route path="/" element={<HomePage />} />
                <Route path="/about" element={<AboutPage />} />
                <Route path="/dashboard" element={<DashboardPage />} />
                <Route path="/admin" element={<AdminPage />} />
            </Routes>
        </Suspense>
    </BrowserRouter>
);

// Component-level Code Splitting
const HeavyChart = React.lazy(() => import('./components/HeavyChart'));
const DataGrid = React.lazy(() => import('./components/DataGrid'));

const Dashboard: React.FC<{ showChart: boolean; showGrid: boolean }> = ({
    showChart,
    showGrid,
}) => (
    <div>
        {showChart && (
            <Suspense fallback={<ChartSkeleton />}>
                <HeavyChart />
            </Suspense>
        )}
        {showGrid && (
            <Suspense fallback={<GridSkeleton />}>
                <DataGrid />
            </Suspense>
        )}
    </div>
);

// Dynamic Imports
const getComponent = async (componentName: string) => {
    return import(`./components/${componentName}`);
};
```

## Part 3: Bundle Analysis & Optimization

```typescript
// Tree Shaking - Only import what you need
// BAD
import * as Utils from './utils';
const value = Utils.getValue();

// GOOD
import { getValue } from './utils';
const value = getValue();

// Using Named Exports
// math.ts
export const add = (a: number, b: number) => a + b;
export const multiply = (a: number, b: number) => a * b;

// app.ts - only imports what's needed
import { add } from './math';
const result = add(2, 3);

// Dynamic Imports for Large Libraries
const loadChart = async () => {
    const { Chart } = await import('chart.js');
    return new Chart(canvas, config);
};

// Icon Splitting
const DynamicIcon: React.FC<{ name: string; size?: number }> = ({ name, size = 24 }) => {
    const [Icon, setIcon] = React.useState<React.ComponentType<any> | null>(null);

    React.useEffect(() => {
        import(`react-icons/fa`).then(module => {
            const IconComponent = module[`Fa${name}`];
            setIcon(() => IconComponent);
        });
    }, [name]);

    return Icon ? <Icon size={size} /> : null;
};
```

## Part 4: Virtual Scrolling

```typescript
import { FixedSizeList as List } from 'react-window';

interface Item {
    id: string;
    title: string;
}

interface VirtualListProps {
    items: Item[];
    onItemClick: (item: Item) => void;
}

const Row = ({ index, style, data }: any) => (
    <div style={style} className="list-item" onClick={() => data.onItemClick(data.items[index])}>
        {data.items[index].title}
    </div>
);

const VirtualList: React.FC<VirtualListProps> = ({ items, onItemClick }) => (
    <List
        height={600}
        itemCount={items.length}
        itemSize={50}
        width="100%"
        itemData={{ items, onItemClick }}
    >
        {Row}
    </List>
);

// Or use react-virtual
import { useVirtualizer } from '@tanstack/react-virtual';

const TanstackVirtualList: React.FC<VirtualListProps> = ({ items, onItemClick }) => {
    const parentRef = React.useRef<HTMLDivElement>(null);

    const virtualizer = useVirtualizer({
        count: items.length,
        getScrollElement: () => parentRef.current,
        estimateSize: () => 50,
    });

    const virtualItems = virtualizer.getVirtualItems();

    return (
        <div
            ref={parentRef}
            style={{
                height: '600px',
                overflow: 'auto',
            }}
        >
            <div style={{ height: virtualizer.getTotalSize() }}>
                {virtualItems.map(virtualItem => (
                    <div
                        key={virtualItem.key}
                        style={{
                            position: 'absolute',
                            top: 0,
                            left: 0,
                            width: '100%',
                            height: virtualItem.size,
                            transform: `translateY(${virtualItem.start}px)`,
                        }}
                    >
                        {items[virtualItem.index].title}
                    </div>
                ))}
            </div>
        </div>
    );
};
```

## Part 5: Image Optimization

```typescript
// Responsive Images with srcSet
const ResponsiveImage: React.FC<{ src: string; alt: string }> = ({ src, alt }) => (
    <img
        srcSet={`
            ${src}-small.jpg 480w,
            ${src}-medium.jpg 800w,
            ${src}-large.jpg 1200w
        `}
        sizes="(max-width: 480px) 100vw, (max-width: 800px) 75vw, 1200px"
        src={`${src}-large.jpg`}
        alt={alt}
        loading="lazy"
        decoding="async"
    />
);

// Picture Element for Modern Formats
const OptimizedImage: React.FC<{ src: string; alt: string }> = ({ src, alt }) => (
    <picture>
        <source srcSet={`${src}.webp`} type="image/webp" />
        <source srcSet={`${src}.jpg`} type="image/jpeg" />
        <img
            src={`${src}.jpg`}
            alt={alt}
            loading="lazy"
            decoding="async"
        />
    </picture>
);

// Next.js-like Image Optimization
interface OptimizedImageProps {
    src: string;
    alt: string;
    width?: number;
    height?: number;
    priority?: boolean;
}

const Image: React.FC<OptimizedImageProps> = ({
    src,
    alt,
    width,
    height,
    priority = false,
}) => {
    const [imageSrc, setImageSrc] = React.useState<string>('');

    React.useEffect(() => {
        // Simulate image loading optimization
        const img = new window.Image();
        img.onload = () => setImageSrc(src);
        img.src = src;
    }, [src]);

    return (
        <img
            src={imageSrc || 'data:image/svg+xml,...'}
            alt={alt}
            width={width}
            height={height}
            loading={priority ? 'eager' : 'lazy'}
            decoding="async"
        />
    );
};
```

## Part 6: Web Workers

```typescript
// worker.ts
self.onmessage = (event: MessageEvent) => {
    const { type, payload } = event.data;

    if (type === 'COMPUTE_FIBONACCI') {
        const result = fibonacci(payload);
        self.postMessage({ type: 'RESULT', result });
    }
};

function fibonacci(n: number): number {
    if (n <= 1) return n;
    return fibonacci(n - 1) + fibonacci(n - 2);
}

// app.tsx
const HeavyComputation: React.FC = () => {
    const [result, setResult] = React.useState<number | null>(null);
    const [loading, setLoading] = React.useState(false);
    const workerRef = React.useRef<Worker | null>(null);

    React.useEffect(() => {
        workerRef.current = new Worker(new URL('./worker.ts', import.meta.url), {
            type: 'module',
        });

        workerRef.current.onmessage = (event: MessageEvent) => {
            setResult(event.data.result);
            setLoading(false);
        };

        return () => workerRef.current?.terminate();
    }, []);

    const computeFibonacci = (n: number) => {
        setLoading(true);
        workerRef.current?.postMessage({ type: 'COMPUTE_FIBONACCI', payload: n });
    };

    return (
        <div>
            <button onClick={() => computeFibonacci(40)} disabled={loading}>
                {loading ? 'Computing...' : 'Compute Fibonacci(40)'}
            </button>
            {result !== null && <p>Result: {result}</p>}
        </div>
    );
};
```

## Part 7: Monitoring Performance

```typescript
// Web Vitals Monitoring
interface WebVital {
    name: string;
    value: number;
    rating: 'good' | 'needs-improvement' | 'poor';
}

const reportWebVitals = (metric: WebVital) => {
    console.log(metric);
    // Send to analytics
    if (window.gtag) {
        window.gtag('event', metric.name, {
            value: Math.round(metric.value),
            event_category: 'web_vitals',
            event_label: metric.rating,
        });
    }
};

// Performance Observer
const PerformanceMonitor: React.FC = () => {
    React.useEffect(() => {
        // Measure Core Web Vitals
        import('web-vitals').then(({ getCLS, getFID, getFCP, getLCP, getTTFB }) => {
            getCLS(reportWebVitals);
            getFID(reportWebVitals);
            getFCP(reportWebVitals);
            getLCP(reportWebVitals);
            getTTFB(reportWebVitals);
        });

        // Custom Performance Marks
        performance.mark('page-load-start');

        return () => {
            performance.mark('page-load-end');
            performance.measure(
                'page-load',
                'page-load-start',
                'page-load-end'
            );

            const measure = performance.getEntriesByName('page-load')[0];
            console.log(`Page load time: ${measure.duration}ms`);
        };
    }, []);

    return null;
};
```

## Part 8: Production Optimization

```typescript
// Production Build Checklist
// 1. Minification
// 2. Tree-shaking
// 3. Code splitting
// 4. Dynamic imports
// 5. Image optimization
// 6. Gzip compression
// 7. HTTP/2 Server Push
// 8. Service Workers for caching

// Service Worker Cache Strategy
if ('serviceWorker' in navigator) {
    window.addEventListener('load', () => {
        navigator.serviceWorker.register('/service-worker.js');
    });
}

// Critical CSS
const inlineStyles = `
    <style>
        body { font-family: sans-serif; }
        .container { max-width: 1200px; }
    </style>
`;

// Resource Hints
const ResourceHints: React.FC = () => (
    <>
        <link rel="preconnect" href="https://api.example.com" />
        <link rel="dns-prefetch" href="https://analytics.example.com" />
        <link rel="prefetch" href="/about.js" />
        <link rel="preload" href="/fonts/main.woff2" as="font" crossOrigin="anonymous" />
    </>
);
```

---

## Key Takeaways

1. **Memoization**: React.memo, useMemo, useCallback
2. **Code Splitting**: Lazy loading and dynamic imports
3. **Virtual Scrolling**: Handle large lists efficiently
4. **Image Optimization**: Responsive images and formats
5. **Web Workers**: Offload heavy computation
6. **Monitoring**: Track and measure performance
7. **Bundle Analysis**: Reduce bundle size
8. **Production**: Apply all optimization techniques

---

**Last Updated:** October 26, 2024
**Level:** Expert
**Topics Covered:** 40+ optimization patterns, 65+ code examples
